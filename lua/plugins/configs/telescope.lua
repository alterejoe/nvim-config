local telescope = require("telescope")
local builtin = require("telescope.builtin")

-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
telescope.setup({
	extensions = {
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
		frecency = {
			db_root = vim.fn.stdpath("data") .. "/telescope-frecency", -- safe place
			show_scores = false,
			show_filter_column = false,
			ignore_patterns = { "*.git/*", "*/tmp/*" },
		},
		egrepify = {
			max_lines = 50000,
			lnum = true,
			shorten_path = true,
			additional_args = { "--max-columns=200", "--max-columns-preview" },
			file_ignore_patterns = {
				"node_modules",
				".git",
				"dist",
				"build",
				".terraform",
			},
		},
	},
	defaults = {
		cache_picker = {
			num_pickers = 3,
		},
		layout_strategy = "bottom_pane",
		layout_config = {
			height = 0.25, -- smaller so more of your screen remains visible
		},
	},
})
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension("messages")
telescope.load_extension("recent_files")
telescope.load_extension("egrepify")

-- telescope.load_extension("frecency")
telescope.load_extension("fzf")
