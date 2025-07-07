local dap = require("dap")
vim.keymap.set("n", "<leader>bp", dap.up, { desc = "Debug: DAP Stack UP" })
vim.keymap.set("n", "<leader>bn", dap.down, { desc = "Debug: DAP Stack DOWN" })

local dapui = require("dapui")
function OpenDap(layoutid)
	dapui.open({ layout = layoutid })
end

function CloseDap()
	dapui.close()
end

local dapopen = false
local layout = nil
vim.keymap.set("n", "<leader>d", function()
	if dapopen then
		-- CloseDap()
		-- dapopen = false
		if layout == 1 then
			CloseDap()
			dapopen = false
		else
			OpenDap(1)
			layout = 1
		end
	else
		OpenDap(1)
		vim.cmd("highlight VertSplit guifg=#B6B6B6 guibg=NONE") -- bright white line
		layout = 1
		dapopen = true
	end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader><c-d>", function()
	if dapopen then
		-- CloseDap()
		-- dapopen = false
		-- -- OpenDap(2)
		if layout == 2 then
			CloseDap()
			dapopen = false
		else
			OpenDap(2)
			layout = 2
		end
	else
		OpenDap(2)
		layout = 2
		dapopen = true
	end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>h", function()
	if dapopen then
		if layout == 3 then
			CloseDap()
			dapopen = false
		else
			OpenDap(3)
			layout = 3
		end
	else
		OpenDap(3)
		layout = 3
		dapopen = true
	end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>b", function()
	require("dap").toggle_breakpoint()
end, { noremap = true, silent = true })

-- keybind for continue
local terminate = false

vim.keymap.set("n", "E", function()
	if terminate == true then
		require("dap").terminate()
		return
	else
		require("dap").continue()
		terminate = true
		return
	end
end, { noremap = true, silent = true })

dap.listeners.after.event_terminated["user_listener"] = function()
	terminate = false
end

vim.keymap.set("n", "<c-n>", function()
	vim.cmd("DapNew")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Right>", function()
	require("dap").step_over()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Up>", function()
	require("dap").step_into()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<Left>", function()
	require("dap").step_out()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-Left>", function()
	require("dap").up()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-Right>", function()
	require("dap").down()
end, { noremap = true, silent = true })
