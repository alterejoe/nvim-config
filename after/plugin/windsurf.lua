-- leader>cc map to CodeiumChat
vim.keymap.set("n", "<leader>cc", function()
	vim.cmd(":Codeium Chat")
end, { noremap = true, silent = true })
