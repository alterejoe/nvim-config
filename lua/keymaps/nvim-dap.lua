local dapopen = true
local layoutindex = 4
local layouts = { 1, 2, 3, 4 }

local dapui = require("dapui")
local function cycle_layouts()
	print("Layouts: ", layouts, "Current layout: ", layoutindex)
	local current_index = vim.fn.index(layouts, layoutindex) + 1

	local next_index = current_index + 1
	if next_index > #layouts then
		next_index = 1
	end

	print("Dap layout: ", next_index)
	layoutindex = next_index
	if dapopen then
		dapui.close()
		dapui.open({ layout = layouts[layoutindex] })
		-- CloseDap()
		-- OpenDap(layouts[layoutindex])
	else
		-- OpenDap(layouts[layoutindex])
		dapui.open({ layout = layouts[layoutindex] })
		dapopen = true
	end
end

vim.keymap.set("n", "<leader><c-d>", cycle_layouts, { noremap = true, silent = true })

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
	vim.cmd("DapViewToggle")
end, { noremap = true, silent = true })

local dap = require("dap")
vim.keymap.set("n", "<leader>b", function()
	dap.toggle_breakpoint()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<c-n>", function()
	dap.terminate()
	vim.cmd("DapNew")
end, { noremap = true, silent = true })

local terminate = false
vim.keymap.set("n", "E", function()
	if terminate then
		vim.cmd("DapNew")
		terminate = true
	else
		dap.terminate()
		terminate = false
	end
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
