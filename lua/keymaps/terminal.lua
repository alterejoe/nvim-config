vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("v", "nm", "<Esc>", { noremap = true, silent = true })
--
-- after/plugin/terminal.lua
local function open_terminal(split_cmd)
	SourceConfig()

	local condaname
	-- Check if python is a conda env and get the name of the conda env
	if vim.g.python3_host_prog ~= nil and vim.g.python3_host_prog:find("conda") then
		condaname = vim.g.python3_host_prog:match("/envs/(.-)/bin/python")
	end

	local pwd = vim.fn.getcwd()

	-- Open terminal with the specified split command
	vim.cmd(split_cmd .. " | terminal")

	-- Go into insert mode and change directory to pwd
	vim.cmd("startinsert")
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cd " .. pwd .. "<CR>", true, false, true), "n", true)

	-- If conda env is present then activate it
	if condaname ~= nil then
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes("conda activate " .. condaname .. "<CR>", true, false, true),
			"n",
			true
		)
	end
end

vim.keymap.set("n", "<leader>st", function()
	open_terminal("rightbelow vsplit")
end)

vim.keymap.set("n", "<leader>sh", function()
	open_terminal("botright split")
end)
