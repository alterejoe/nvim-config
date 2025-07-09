local dapui = require("dapui")
-- dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
dapui.setup({
	floating = {
		border = "single", -- Border style for floating windows
	},
	-- layouts = {
	-- 	{
	-- 		elements = {
	-- 			{ id = "repl", size = 1.0, position = "left" },
	-- 			{ id = "breakpoints", size = 0.25 },
	-- 			{ id = "scopes", size = 0.25 },
	-- 			{ id = "stacks", size = 0.25 },
	-- 		},
	-- 		size = 100, -- Height of the bottom panel
	-- 		position = "right",
	-- 	},
	-- 	{
	-- 		elements = {
	-- 			{ id = "repl", size = 1.0 },
	-- 			{ id = "breakpoints", size = 0.25 },
	-- 			{ id = "scopes", size = 0.25 },
	-- 			{ id = "stacks", size = 0.25 },
	-- 		},
	-- 		size = 25, -- Height of the bottom panel
	-- 		position = "bottom",
	-- 	},
	-- },
	layouts = {
		{
			elements = {
				{ id = "console", size = 0.5 },
				{ id = "repl", size = 0.5 },
			},
			position = "right",
			size = 100,
		},
		{
			elements = {
				{ id = "scopes", size = 0.50 },
				{ id = "breakpoints", size = 0.20 },
				{ id = "stacks", size = 0.15 },
				{ id = "watches", size = 0.15 },
			},
			position = "right",
			size = 65,
		},
		{
			elements = {
				{ id = "scopes", size = 0.50 },
				{ id = "breakpoints", size = 0.20 },
				{ id = "stacks", size = 0.15 },
				{ id = "watches", size = 0.15 },
			},
			position = "bottom",
			size = 25,
		},
		{
			elements = {
				{ id = "repl" },
			},
			position = "right",
			size = 100,
		},

		{
			elements = {
				{ id = "repl" },
			},
			position = "bottom",
			size = 100,
		},
	},
	element_mappings = {
		stacks = {
			open = "<CR>", -- Open the current frame in the editor
			expand = "o", -- Close the current frame
		},
	},
})
