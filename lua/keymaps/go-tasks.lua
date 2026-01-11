local task = require("plugins.configs.go-tasks")

vim.keymap.set("n", "<leader>ra", task.toggle_task, { desc = "Toggle task dev" })
vim.keymap.set("n", "<leader>ro", task.toggle_logs, { desc = "Toggle task dev logs" })
