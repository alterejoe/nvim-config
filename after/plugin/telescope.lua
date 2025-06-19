-- vim.api.nvim_set_keymap("n", "<Leader>ff", ":FzfLua <CR>", { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap('n', '<Leader>fg', ':GFiles<CR>', { noremap = true, silent = true })
-- -- vim.api.nvim_set_keymap('n', '<Leader>fb', ':Buffers<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<Leader>fg", ":FzfLua grep<CR>", { noremap = true, silent = true })
--
-- -- g:fzf_vim.buffers_jump = 1
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })- vim.g.fzf_vim_buffers_jump = 1
--
require("telescope").setup({
	defaults = {
		layout_strategy = "vertical",
		layout_config = {
			anchor = "W",
			height = vim.o.lines, -- maximally available lines
			width = 0.6, -- maximally available columns
			prompt_position = "top",
			preview_height = 0.6, -- 60% of available lines
		},
	},
})

require("telescope").load_extension("git_worktree")

vim.keymap.set(
	"n",
	"<leader>tc",
	-- "<CMD>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>",
	function()
		require("telescope").extensions.git_worktree.git_worktrees()
	end,
	{ desc = "Telescope Git Worktrees" }
)
vim.keymap.set(
	"n",
	"<leader>ts",
	-- "<CMD>lua require('git-worktree').extensions.git_worktree.switch_worktree()<CR>",
	function()
		require("git-worktree").extensions.git_worktree.switch_worktree()
	end,

	{ desc = "Switch Git Worktree" }
)
