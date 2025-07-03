vim.keymap.set("n", "<leader>e", function()
	vim.api.nvim_command("Oil")
end)

vim.keymap.set("n", "<leader>x", function()
	vim.api.nvim_command("source %")
end)

vim.keymap.set("n", ">", function()
	vim.api.nvim_command("normal! f>")
end)

vim.keymap.set("n", "<", function()
	vim.api.nvim_command("normal! F<")
end)

vim.keymap.set("n", "<C-j>", function()
	-- ctrl ww
	vim.cmd("wincmd w")
end)

-- this is to switch between buffers
vim.keymap.set("n", "<M-o>", "<c-^>", { noremap = true, silent = true })

-- reload file for external changes
vim.keymap.set("n", "L", function()
	vim.cmd("edit!")
end, { noremap = true, silent = true })
