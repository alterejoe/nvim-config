local telescope = require("telescope")

telescope.setup({
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
})

-- require("telescope").load_extension("fzf")
telescope.load_extension("messages")
telescope.load_extension("recent_files")
telescope.load_extension("frecency")
telescope.load_extension("git_worktree")
telescope.load_extension("grapple")

local builtin = require("telescope.builtin")
local recentfiles = require("telescope").extensions.recent_files

vim.keymap.set("n", "<leader>F", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>ff", recentfiles.pick, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fw", function()
	local word = vim.fn.expand("<cword>")
	require("telescope.builtin").live_grep({ default_text = word })
end)
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })- vim.g.fzf_vim_buffers_jump = 1
--
--
