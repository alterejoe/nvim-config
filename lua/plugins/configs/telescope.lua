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
	},
	defaults = {
		cache_picker = {
			num_pickers = 5,
		},
	},
})
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension("fzf")
telescope.load_extension("messages")
telescope.load_extension("recent_files")
telescope.load_extension("frecency")
telescope.load_extension("grapple")
telescope.load_extension("egrepify")
