require("dap-view").setup({
	winbar = {
		default_section = "repl",
	},
	windows = {
		height = 12,
		position = "right",
		terminal = {
			position = "left",
			hide = {},
			width = 0.7,
			start_hidden = true,
		},
	},
})
vim.keymap.set("n", "<leader>d", function()
	-- vim.cmd("<Cmd>DapViewToggle<CR>")
	vim.cmd("DapViewToggle")
	-- vim.cmd("wincmd w")
end, { noremap = true, silent = true })

local terminate = false

local dap = require("dap")
dap.listeners.after.event_terminated["user_listener"] = function()
	terminate = false
end
vim.keymap.set("n", "<leader>b", function()
	dap.toggle_breakpoint()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<c-n>", function()
	dap.terminate()
	vim.cmd("DapNew")
end, { noremap = true, silent = true })

local dap = require("dap")

vim.keymap.set("n", "E", function()
	dap.terminate()
	vim.cmd("DapNew")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Right>", function()
	dap.step_over()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Up>", function()
	dap.step_into()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Left>", function()
	dap.step_out()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-Left>", function()
	dap.up()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-Right>", function()
	dap.down()
end, { noremap = true, silent = true })
