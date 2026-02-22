local M = {}
local job = nil
local bufnr = nil

-- Ensure log buffer exists
local function ensure_buf()
	if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
		return bufnr
	end
	bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, "TaskDevLog")
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].swapfile = false
	vim.bo[bufnr].filetype = "taskdevlog"
	return bufnr
end

-- Find window showing our buffer
local function find_win()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return win
		end
	end
	return nil
end

-- Auto-scroll to bottom if window is visible
local function auto_scroll()
	local win = find_win()
	if win then
		local line_count = vim.api.nvim_buf_line_count(bufnr)
		vim.api.nvim_win_set_cursor(win, { line_count, 0 })
	end
end

-- Kill all dev processes using Taskfile clean
local function cleanup_processes()
	vim.fn.system("task clean ")
end

-- PUBLIC: open log buffer in a split (or jump to it if already visible)
function M.open_logs()
	ensure_buf()
	local win = find_win()

	if win then
		-- Already visible, just jump to it
		vim.api.nvim_set_current_win(win)
	else
		-- Open in bottom split
		vim.cmd("botright 12split")
		vim.api.nvim_win_set_buf(0, bufnr)
	end

	auto_scroll()
end

-- PUBLIC: close log buffer window (if visible)
function M.close_logs()
	local win = find_win()
	if win then
		vim.api.nvim_win_close(win, false)
	end
end

-- PUBLIC: toggle log buffer
function M.toggle_logs()
	if find_win() then
		M.close_logs()
	else
		M.open_logs()
	end
end

-- PUBLIC: toggle "task dev" job
function M.toggle_task()
	-- if job exists AND still running → stop it
	if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
		vim.fn.jobstop(job)
		vim.defer_fn(function()
			cleanup_processes()
			vim.notify("Stopped: task dev (cleaned up all processes)")
		end, 100)
		job = nil
	end

	-- Clean up any lingering processes before starting
	cleanup_processes()
	ensure_buf()

	-- Clear the buffer
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	-- Open window if not already visible
	if not find_win() then
		M.open_logs()
	end

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
					auto_scroll()
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
					auto_scroll()
				end
			end
		end,
		on_exit = function(_, exit_code)
			vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {
				"*** task dev exited with code: " .. exit_code .. " ***",
			})
			vim.defer_fn(cleanup_processes, 100)
		end,
	})
	vim.notify("Started: task dev")
end

-- Clean up on Neovim exit
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		if job and vim.fn.jobwait({ job }, 0)[1] == -1 then
			vim.fn.jobstop(job)
		end
		cleanup_processes()
	end,
})

return M
