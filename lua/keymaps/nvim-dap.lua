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

local terminate = false

-- local dap = require("dap")
-- dap.listeners.after.event_terminated["user_listener"] = function()
-- 	terminate = false
-- end
-- vim.keymap.set("n", "E", function()
-- 	if terminate == true then
-- 		dap.terminate()
-- 		return
-- 	else
-- 		require("dap").continue()
-- 		terminate = true
-- 		return
-- 	end
-- end, { noremap = true, silent = true })
