local dapopen = true
local layoutindex = 4
local layouts = { 1, 2, 3, 4 }

local function toggle_layout()
	if dapopen then
		CloseDap()
		dapopen = false
	else
		OpenDap(layouts[layoutindex])
		dapopen = true
	end
end

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
		CloseDap()
		OpenDap(layouts[layoutindex])
	else
		OpenDap(layouts[layoutindex])
		dapopen = true
	end
end

vim.keymap.set("n", "<leader>d", function()
	toggle_layout()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader><c-d>", cycle_layouts, { noremap = true, silent = true })
