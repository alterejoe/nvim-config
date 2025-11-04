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
-- -- live Air runner + log viewer
-- local job, bufnr = nil, nil
-- local lines = {}
--
-- local function clean_lines(batch)
-- 	if not batch then
-- 		return {}
-- 	end
-- 	local out = {}
-- 	for _, s in ipairs(batch) do
-- 		if s and s ~= "" then
-- 			-- true carriage return is "\r"; "^M" is how Vim displays it
-- 			s = s:gsub("\r", "")
-- 			table.insert(out, s)
-- 		end
-- 	end
-- 	return out
-- end
--
-- local function ensure_buf()
-- 	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
-- 		return bufnr
-- 	end
-- 	bufnr = vim.api.nvim_create_buf(false, true)
-- 	vim.bo[bufnr].buftype = "nofile"
-- 	vim.bo[bufnr].bufhidden = "hide"
-- 	vim.bo[bufnr].swapfile = false
-- 	vim.bo[bufnr].modifiable = true
-- 	vim.bo[bufnr].filetype = "log"
-- 	return bufnr
-- end
--
-- local function append(data)
-- 	local chunk = clean_lines(data)
-- 	if #chunk == 0 then
-- 		return
-- 	end
-- 	for _, l in ipairs(chunk) do
-- 		table.insert(lines, l)
-- 	end
-- 	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
-- 		local last = vim.api.nvim_buf_line_count(bufnr)
-- 		vim.api.nvim_buf_set_lines(bufnr, last, last, false, chunk)
-- 		-- autoscroll if any window shows this buffer
-- 		for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
-- 			pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(bufnr), 0 })
-- 		end
-- 	end
-- end
--
-- local function on_stdout(_, data, _)
-- 	vim.schedule(function()
-- 		append(data)
-- 	end)
-- end
--
-- local function on_stderr(_, data, _)
-- 	vim.schedule(function()
-- 		append(data)
-- 	end)
-- end
--
-- local function on_exit(_, code, _)
-- 	vim.schedule(function()
-- 		append({ ("[air exited with code %d]"):format(code) })
-- 		job = nil
-- 	end)
-- end
--
-- -- Toggle "air"
-- vim.keymap.set("n", "<leader>ra", function()
-- 	if job then
-- 		print("stopping air")
-- 		pcall(vim.fn.jobstop, job)
-- 		job = nil
-- 		return
-- 	end
--
-- 	print("starting air")
-- 	lines = {}
-- 	ensure_buf()
-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {}) -- clear
--
-- 	job = vim.fn.jobstart({ "air" }, {
-- 		cwd = vim.fn.getcwd(),
-- 		on_stdout = on_stdout,
-- 		on_stderr = on_stderr,
-- 		on_exit = on_exit,
-- 		stdout_buffered = false,
-- 		stderr_buffered = false,
-- 	})
--
-- 	if job <= 0 then
-- 		print("failed to start air")
-- 		job = nil
-- 	else
-- 		append({ "[air started]" })
-- 	end
-- end, { noremap = true, silent = true })
--
-- -- Open/focus live log
-- vim.keymap.set("n", "<leader>ro", function()
-- 	if not job then
-- 		return
-- 	end
-- 	ensure_buf()
-- 	-- seed with history
-- 	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
-- 	vim.cmd("vsplit")
-- 	vim.api.nvim_win_set_buf(0, bufnr)
-- 	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(bufnr), 0 })
-- end, { noremap = true, silent = true })
