-- SIMPLE GO-TASK TOGGLE + LOG WINDOW (single file)
local M = {}

local job = nil
local bufnr = nil
local winid = nil

-- Ensure log buffer exists
local function ensure_buf()
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		return bufnr
	end
	bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, "TaskDevLog")
	return bufnr
end

-- Open floating window for logs
local function open_win()
	if winid and vim.api.nvim_win_is_valid(winid) then
		return
	end

	local width = vim.o.columns
	local height = 12

	winid = vim.api.nvim_open_win(ensure_buf(), true, {
		relative = "editor",
		row = vim.o.lines - height - 2,
		col = 0,
		width = width,
		height = height,
		style = "minimal",
		border = "single",
	})
end

local function close_win()
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_win_close(winid, true)
	end
	winid = nil
end

-- PUBLIC: toggle log window
function M.toggle_logs()
	if winid and vim.api.nvim_win_is_valid(winid) then
		close_win()
	else
		open_win()
	end
end

-- PUBLIC: toggle "task dev" job
function M.toggle_task()
	-- if job exists AND still running → stop it
	if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
		vim.fn.jobstop(job)
		job = nil
		vim.notify("Stopped: task dev")
		return
	end

	ensure_buf()
	M.toggle_logs()

	job = vim.fn.jobstart("task dev", {
		stdout_buffered = false,
		stderr_buffered = false,

		on_stdout = function(_, data)
			if not data then
				return
			end
			for _, line in ipairs(data) do
				if line ~= "" then
					vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { line })
				end
			end
		end,

		on_stderr = function(_, data)
			if not data then
				return
			end
			for _, line in ipairs(data) do
				if line ~= "" then
					vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "[ERR] " .. line })
				end
			end
		end,

		on_exit = function()
			vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "*** task dev exited ***" })
		end,
	})

	vim.notify("Started: task dev")
end

return M
