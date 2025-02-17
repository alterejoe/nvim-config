-- return {
-- 	{
-- 		"junegunn/fzf",
-- 		run = function()
-- 			vim.fn["fzf#install"]()
-- 		end,
-- 	},
-- 	{
-- 		"junegunn/fzf.vim",
-- 		requires = { "junegunn/fzf" },
-- 	},
-- 	 }
return {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },
	-- or if using mini.icons/mini.nvim
	-- dependencies = { "echasnovski/mini.icons" },
	opts = {},
}
