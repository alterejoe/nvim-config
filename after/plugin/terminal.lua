-- vim.keymap.set for <leader>st to open vsplit terminal to the right
vim.keymap.set("n", "<leader>st", function()
	local cwd = vim.fn.expand("%:p:h")
	-- open terminal in the right split at the current working directory
	vim.cmd("rightbelow vsplit | terminal")

	-- go into insert mode
	vim.cmd("startinsert")
	-- feed the keys to the terminal
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cd " .. cwd, true, false, true), "n", true)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
end)
