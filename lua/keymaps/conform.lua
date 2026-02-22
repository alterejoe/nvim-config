-- Add this to your config
vim.keymap.set("n", "<leader>tf", function()
	vim.b.disable_autoformat = not vim.b.disable_autoformat
	if vim.b.disable_autoformat then
		print("Autoformat disabled for this buffer")
	else
		print("Autoformat enabled for this buffer")
	end
end, { desc = "Toggle autoformat for buffer" })
