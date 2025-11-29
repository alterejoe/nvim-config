local task = require("plugins.configs.go-tasks")

local on = false
vim.keymap.set("n", "<leader>ra", function()
	if on then
		vim.cmd("!task clean")
		return
	end
	task.toggle_task()
end, { desc = "Toggle task dev" })
vim.keymap.set("n", "<leader>ro", task.toggle_logs, { desc = "Toggle task dev logs" })
