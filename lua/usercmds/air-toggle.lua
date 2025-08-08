-- user command that runs golangs "air" within the current directory as a toggle

local function clean_lines(lines)
	local cleaned = {}
	-- remove ^M
	for _, line in ipairs(lines) do
		line = line:gsub("^M", "") -- remove carriage returns
		table.insert(cleaned, line)
	end
	return cleaned
end

local lines = {}
local function stdout(_, data, _)
	for _, line in ipairs(data) do
		-- table.insert(lines, line)
		-- extend
		for _, l in ipairs(clean_lines({ line })) do
			table.insert(lines, l)
		end
	end
end

local function stderr(_, data, _)
	for _, line in ipairs(data) do
		for _, l in ipairs(clean_lines({ line })) do
			table.insert(lines, l)
		end
	end
end

local function stdexit(_, code, _)
	if code ~= 0 then
		table.insert(lines, "Job exited with error code: " .. code)
	else
		table.insert(lines, "Job completed successfully.")
	end
end

local job = nil
vim.keymap.set("n", "<tab><tab>a", function()
	if job ~= nil then
		print("stopping air")
		vim.fn.jobstop(job)
		lines = {}
		job = nil
		return
	else
		print("starting air")
		job =
			vim.fn.jobstart("air", { cwd = vim.fn.getcwd(), on_stdout = stdout, on_stderr = stderr, on_exit = stdexit })
	end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<tab><tab>o", function()
	if job ~= nil then
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

		vim.cmd("vsplit")
		vim.api.nvim_win_set_buf(0, bufnr)
	end
end, { noremap = true, silent = true })
