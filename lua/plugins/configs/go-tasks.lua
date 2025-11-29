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
	vim.bo[bufnr].buftype = "nofile"
	vim.bo[bufnr].bufhidden = "hide"
	vim.bo[bufnr].swapfile = false
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
	-- Auto-scroll to bottom
	vim.api.nvim_create_autocmd("BufWritePost", {
		buffer = bufnr,
		callback = function()
			if winid and vim.api.nvim_win_is_valid(winid) then
				local line_count = vim.api.nvim_buf_line_count(bufnr)
				vim.api.nvim_win_set_cursor(winid, { line_count, 0 })
			end
		end,
	})
end

local function close_win()
	if winid and vim.api.nvim_win_is_valid(winid) then
		vim.api.nvim_win_close(winid, true)
	end
	winid = nil
end

-- Kill all dev processes
local function cleanup_processes()
	-- Kill all related processes
	vim.fn.system("task clean 2>/dev/null")

	-- Fallback: kill specific processes if task clean doesn't exist
	vim.fn.system("killall -9 main air templ tailwindcss 2>/dev/null")

	-- Kill anything on port 4444
	vim.fn.system("lsof -ti:4444 | xargs kill -9 2>/dev/null")
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

		-- Clean up all child processes
		vim.defer_fn(function()
			cleanup_processes()
			vim.notify("Stopped: task dev (cleaned up all processes)")
		end, 100)

		job = nil
		return
	end

	-- Clean up any lingering processes before starting
	cleanup_processes()

	ensure_buf()

	-- Clear the buffer
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})

	-- Open window if not already open
	if not (winid and vim.api.nvim_win_is_valid(winid)) then
		open_win()
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
					-- Auto-scroll to bottom
					if winid and vim.api.nvim_win_is_valid(winid) then
						local line_count = vim.api.nvim_buf_line_count(bufnr)
						vim.api.nvim_win_set_cursor(winid, { line_count, 0 })
					end
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
					-- Auto-scroll to bottom
					if winid and vim.api.nvim_win_is_valid(winid) then
						local line_count = vim.api.nvim_buf_line_count(bufnr)
						vim.api.nvim_win_set_cursor(winid, { line_count, 0 })
					end
				end
			end
		end,
		on_exit = function(_, exit_code)
			vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {
				"*** task dev exited with code: " .. exit_code .. " ***",
			})
			-- Clean up processes even on exit
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
