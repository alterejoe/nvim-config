-- live Air runner + log viewer
local job, bufnr = nil, nil
local lines = {}

local function clean_lines(batch)
	if not batch then
		return {}
	end
	local out = {}
	for _, s in ipairs(batch) do
		if s and s ~= "" then
			-- true carriage return is "\r"; "^M" is how Vim displays it
			s = s:gsub("\r", "")
			table.insert(out, s)
		end
	end
	return out
end

local function ensure_buf()
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		return bufnr
	end
	bufnr = vim.api.nvim_create_buf(false, true)
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].modifiable = true
	vim.bo[bufnr].filetype = "log"
	return bufnr
end

local function append(data)
	local chunk = clean_lines(data)
	if #chunk == 0 then
		return
	end
	for _, l in ipairs(chunk) do
		table.insert(lines, l)
	end
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		local last = vim.api.nvim_buf_line_count(bufnr)
		vim.api.nvim_buf_set_lines(bufnr, last, last, false, chunk)
		-- autoscroll if any window shows this buffer
		for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
			pcall(vim.api.nvim_win_set_cursor, win, { vim.api.nvim_buf_line_count(bufnr), 0 })
		end
	end
end

local function on_stdout(_, data, _)
	vim.schedule(function()
		append(data)
	end)
end

local function on_stderr(_, data, _)
	vim.schedule(function()
		append(data)
	end)
end

local function on_exit(_, code, _)
	vim.schedule(function()
		append({ ("[air exited with code %d]"):format(code) })
		job = nil
	end)
end

-- Toggle "air"
vim.keymap.set("n", "<leader>ra", function()
	if job then
		print("stopping air")
		pcall(vim.fn.jobstop, job)
		job = nil
		return
	end

	print("starting air")
	lines = {}
	ensure_buf()
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {}) -- clear

	job = vim.fn.jobstart({ "air" }, {
		cwd = vim.fn.getcwd(),
		on_stdout = on_stdout,
		on_stderr = on_stderr,
		on_exit = on_exit,
		stdout_buffered = false,
		stderr_buffered = false,
	})

	if job <= 0 then
		print("failed to start air")
		job = nil
	else
		append({ "[air started]" })
	end
end, { noremap = true, silent = true })

-- Open/focus live log
vim.keymap.set("n", "<leader>ro", function()
	if not job then
		return
	end
	ensure_buf()
	-- seed with history
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, bufnr)
	vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(bufnr), 0 })
end, { noremap = true, silent = true })
