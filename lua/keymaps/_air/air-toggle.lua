-- live Air runner + log viewer (multi-project safe)
local sessions = {} -- key = cwd: { job, bufnr, lines }

local function get_session()
	local cwd = vim.fn.getcwd()
	if not sessions[cwd] then
		sessions[cwd] = { job = nil, bufnr = nil, lines = {} }
	end
	return sessions[cwd]
end

local function clean_lines(batch)
	if not batch then
		return {}
	end
	local out = {}
	for _, s in ipairs(batch) do
		if s and s ~= "" then
			table.insert(out, (s:gsub("\r", "")))
		end
	end
	return out
end

local function ensure_buf(session)
	if session.bufnr and vim.api.nvim_buf_is_valid(session.bufnr) then
		return session.bufnr
	end
	local bufnr = vim.api.nvim_create_buf(false, true)
	session.bufnr = bufnr
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "log"
	return bufnr
end

local function append(session, data)
	local chunk = clean_lines(data)
	if #chunk == 0 then
		return
	end

	for _, l in ipairs(chunk) do
		table.insert(session.lines, l)
	end

	if session.bufnr and vim.api.nvim_buf_is_valid(session.bufnr) then
		local last = vim.api.nvim_buf_line_count(session.bufnr)
		vim.api.nvim_buf_set_lines(session.bufnr, last, last, false, chunk)

		for _, win in ipairs(vim.fn.win_findbuf(session.bufnr)) do
			pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(session.bufnr), 0 })
		end
	end
end

local function make_callbacks(session)
	return {
		on_stdout = function(_, data, _)
			vim.schedule(function()
				append(session, data)
			end)
		end,
		on_stderr = function(_, data, _)
			vim.schedule(function()
				append(session, data)
			end)
		end,
		on_exit = function(_, code, _)
			vim.schedule(function()
				append(session, { ("[air exited %d]"):format(code) })
				session.job = nil
			end)
		end,
	}
end

-- Toggle
vim.keymap.set("n", "<leader>ra", function()
	local s = get_session()

	if s.job then
		print("stopping air")
		pcall(vim.fn.jobstop, s.job)
		s.job = nil
		return
	end

	print("starting air")
	s.lines = {}
	ensure_buf(s)
	vim.api.nvim_buf_set_lines(s.bufnr, 0, -1, false, {})

	local opts = make_callbacks(s)
	opts.cwd = vim.fn.getcwd()
	opts.stdout_buffered = false
	opts.stderr_buffered = false

	s.job = vim.fn.jobstart({ "air" }, opts)
	if s.job <= 0 then
		print("failed to start air")
		s.job = nil
	else
		append(s, { "[air started]" })
	end
end, { silent = true })

-- Open logs
vim.keymap.set("n", "<leader>ro", function()
	local s = get_session()
	if not s.job then
		return
	end
	ensure_buf(s)
	vim.api.nvim_buf_set_lines(s.bufnr, 0, -1, false, s.lines)
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, s.bufnr)
	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(s.bufnr), 0 })
end, { silent = true })
