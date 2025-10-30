vim.keymap.set("n", "<leader>rm", function()
	vim.cmd([[%s/\r//g]])
end, { desc = "Remove ^M characters" })
