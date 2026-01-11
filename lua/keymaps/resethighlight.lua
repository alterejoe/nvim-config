-- vim.keymap.set("n", "<leader>hh", function()
-- 	local ok, ts = pcall(require, "nvim-treesitter.parsers")
-- 	if not ok then
-- 		print("nvim-treesitter not loaded")
-- 		return
-- 	end
-- 	local lang = ts.get_buf_lang(0)
-- 	if lang then
-- 		vim.treesitter.stop(0)
-- 		vim.treesitter.start(0, lang)
-- 		print("Tree-sitter highlighting restarted for current buffer")
-- 	else
-- 		print("No Tree-sitter language for this buffer")
-- 	end
-- end, { desc = "Restart Tree-sitter highlighting" })
--
-- -- Alternative: More aggressive reset
-- vim.keymap.set("n", "<leader>hh", function()
-- 	-- Stop and start treesitter
-- 	vim.treesitter.stop(0)
-- 	vim.schedule(function()
-- 		local lang = vim.treesitter.language.get_lang(vim.bo.filetype)
-- 		if lang then
-- 			vim.treesitter.start(0, lang)
-- 			print("Tree-sitter highlighting restarted")
-- 		else
-- 			print("No treesitter parser for this filetype")
-- 		end
-- 	end)
-- end, { desc = "Restart Tree-sitter highlighting" })
--
-- Or the simplest working version:
vim.keymap.set("n", "<leader>hh", function()
	vim.cmd("edit!")
	print("Buffer reloaded")
end, { desc = "Reload buffer" })
