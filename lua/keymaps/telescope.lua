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
