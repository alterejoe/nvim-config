local telescope = require("telescope")
local builtin = require("telescope.builtin")

-- vim.keymap.set("n", "<leader>F", builtin.find_files, { desc = "Telescope find files" })
-- vim.keymap.set("n", "<leader>rf", telescope.extensions.recent_files.recent_files, { desc = "Telescope find files" })
-- vim.keymap.set("n", "<leader>ff", telescope.extensions.recent_files.pick, { desc = "Telescope find files" })
-- vim.keymap.set("n", "<leader>fg", telescope.extensions.egrepify.egrepify, { desc = "Telescope live grep" })
-- vim.keymap.set("n", "<leader>mm", telescope.extensions.messages.messages, { desc = "Telescope messages" })

vim.keymap.set("n", "<leader>rf", function()
	telescope.extensions.recent_files.recent_files({ cwd = vim.fn.getcwd() })
end, { desc = "Telescope find recent files" })

vim.keymap.set("n", "<leader>ff", function()
	require("telescope.builtin").find_files({
		cwd = vim.fn.getcwd(),
		hidden = true,
		max_depth = 3,
	})
end, { desc = "Telescope pick a file" })

vim.keymap.set("n", "<leader>fg", function()
	telescope.extensions.egrepify.egrepify({ cwd = vim.fn.getcwd(), qflist = true })
end, { desc = "Telescope live grep" })

vim.keymap.set("n", "<leader>mm", function()
	telescope.extensions.messages.messages({ cwd = vim.fn.getcwd() })
end, { desc = "Telescope messages" })

vim.keymap.set("n", "<leader>fw", function()
	local word = vim.fn.expand("<cword>")
	builtin.live_grep({ default_text = word, qflist = true })
end)
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })

vim.keymap.set("n", "<leader>fp", builtin.pickers, { desc = "Telescope resume" })
