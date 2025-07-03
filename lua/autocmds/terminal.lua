vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "*",
	callback = function()
		local bufname = vim.fn.bufname()
		if not bufname:match("lazygit") then
			vim.keymap.set("t", "jk", "<C-\\><C-n>", { buffer = true, noremap = true, silent = true })
		else
			vim.keymap.set("t", "nm", "<C-\\><C-n>", { buffer = true, noremap = true, silent = true })
		end
	end,
})
