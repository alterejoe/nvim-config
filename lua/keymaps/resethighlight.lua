vim.keymap.set("n", "<leader>hh", function()
	local ok, ts = pcall(require, "nvim-treesitter.parsers")
	if not ok then
		print("nvim-treesitter not loaded")
		return
	end
	local lang = ts.get_buf_lang(0)
	if lang then
		ts.reload(lang)
		vim.treesitter.stop(0)
		vim.treesitter.start(0, lang)
		print("Tree-sitter highlighting restarted for current buffer")
	else
		print("No Tree-sitter language for this buffer")
	end
end, { desc = "Restart Tree-sitter highlighting" })
