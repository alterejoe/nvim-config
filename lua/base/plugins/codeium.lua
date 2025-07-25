-- return {
-- 	"Exafunction/windsurf.nvim",
-- 	config = function()
-- 		-- initialize plugin with workspace_root and key mappings
-- 		require("codeium").setup({
-- 			workspace_root = {
-- 				use_lsp = true,
-- 				find_root = nil,
-- 				paths = { ".git", "config.lua", "Makefile" },
-- 			},
--
-- 			enable_cmp_source = false,
-- 			virtual_text = {
-- 				enabled = true,
-- 				-- accept: key binding for accepting a completion, default is <Tab>
-- 				-- accept_word: key binding for accepting only the next word, default is not set
-- 				-- accept_line: key binding for accepting only the next line, default is not set
-- 				-- clear: key binding for clearing the virtual text, default is not set
-- 				-- next: key binding for cycling to the next completion, default is <M-]>
-- 				-- prev: key binding for cycling to the previous completion, default is <M-[>
-- 				key_bindings = {
-- 					accept = "<c-a>",
-- 					accept_word = false,
-- 					accept_line = false,
-- 					clear = false,
-- 					next = "<M-]>",
-- 					prev = "<M-[>",
-- 				},
-- 			},
-- 		})
-- 	end,
-- }
--
return {
	"monkoose/neocodeium",
	event = "VeryLazy",
	config = function()
		local neocodeium = require("neocodeium")
		neocodeium.setup({
			root_dir = { ".git", "Makefile", ".env", "config.lua" },
		})

		vim.keymap.set("i", "<A-f>", neocodeium.accept)
	end,
}
