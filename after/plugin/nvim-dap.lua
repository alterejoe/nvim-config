local dap = require("dap")
-- listeners

-- configurations
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = function()
			return "/home/altjoe/miniconda3/bin/python"
		end,
	},
}

dap.configurations.gdscript = {
	{
		type = "godot",
		request = "launch",
		name = "Launch scene",
		project = "${workspaceFolder}",
		-- launch_scene = true,
	},
}
dap.configurations.rust = {
	{
		name = "Launch",
		type = "gdb",
		request = "launch",
		program = function()
			SourceConfig()
			-- defer until build is done

			local cwd = vim.fn.getcwd()
			if vim.g.rust_exe == nil then
				-- vim.g.rust_exe = "Please create a config.lua and put rust executable name for vim.g.rust_exe"
				error("Please create a config.lua and put rust executable name for vim.g.rust_exe")
			end
			-- local input = vim.fn.input("Enter executable name: ", vim.g.rust_exe)
			local executable = cwd .. "/target/debug/" .. vim.g.rust_exe

			return executable
		end,
		cwd = "${workspaceFolder}",
		stopAtBeginningOfMainSubprogram = false,
	},
}

-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
dap.configurations.go = {
	-- {
	-- 	type = "delve",
	-- 	name = "Debug",
	-- 	request = "launch",
	-- 	program = "${file}",
	-- },
	-- {
	-- 	type = "delve",
	-- 	name = "Debug test", -- configuration for debugging test files
	-- 	request = "launch",
	-- 	mode = "test",
	-- 	program = "${file}",
	-- },
	-- works with go.mod packages and sub packages
	{
		type = "delve",
		name = "Debug test (go.mod)",
		request = "launch",
		mode = "debug",
		program = function()
			local cwd = vim.fn.getcwd()
			-- local gofile = vim.fn.expand("%:p")

			return cwd .. "/..." -- this will debug the whole package
		end,
		cwd = "${workspaceFolder}",
	},
}

--- adapters
dap.adapters.delve = function(callback, config)
	if config.mode == "remote" and config.request == "attach" then
		callback({
			type = "server",
			host = config.host or "127.0.0.1",
			port = config.port or "38697",
		})
	else
		callback({
			type = "server",
			port = "${port}",
			executable = {
				command = "dlv",
				args = { "dap", "-l", "127.0.0.1:${port}" }, -- "--log", "--log-output=dap" },
				detached = vim.fn.has("win32") == 0,
			},
		})
	end
end

dap.adapters.python = {
	type = "executable",
	command = "python", -- Adjust this to your Python path
	args = { "-m", "debugpy.adapter" },
}

dap.adapters.godot = {
	type = "server",
	host = "127.0.0.1",
	port = 6006,
}
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on", "--quiet" },
}
--
-- setup
require("neodev").setup({
	library = { plugins = { "nvim-dap-ui" }, types = true },
	...,
})

require("dapui").setup()

dap.listeners.after.event_exited["dapui_config"] = function()
	require("dap").close()
end

---- keybinds
local dapopen = false
vim.keymap.set("n", "<leader>d", function()
	local dapui = require("dapui")
	if dapopen then
		dapui.close()
		dapopen = false
	else
		dapui.open()
		dapopen = true
	end
end, { noremap = true, silent = true })

-- keybind for toggling breakpoint
--
vim.keymap.set("n", "<leader>b", function()
	require("dap").toggle_breakpoint()
end, { noremap = true, silent = true })

-- keybind for continue

local terminate = false
vim.keymap.set("n", "E", function()
	if terminate then
		require("dap").terminate()
		terminate = false
	end

	require("dap").continue()
	terminate = true
end, { noremap = true, silent = true })

-- keybind for step over
-- arrow right

vim.keymap.set("n", "<Right>", function()
	require("dap").step_over()
end, { noremap = true, silent = true })

-- keybind for step into
-- arrow up

vim.keymap.set("n", "<Up>", function()
	require("dap").step_into()
end, { noremap = true, silent = true })

-- keybind for step out
-- arrow left

vim.keymap.set("n", "<Left>", function()
	require("dap").step_out()
end, { noremap = true, silent = true })

-- local function closeAlldapSessions()
-- -- 	print("trying to close all sessions")
-- 	for i, session in ipairs(dap.sessions()) do
-- 		dap.disconnect(session)
-- 		print("session closed")
-- 	end
-- end

-- vim.keymap.set("n", "<leader>D", function()
-- 	closeAlldapSessions()
-- 	print("All sessions closed")
-- end, { noremap = true, silent = true })

-- vim.api.nvim_create_autocmd({ "VimPreLeave" }, {
-- 	callback = function()
-- 		for i, session in ipairs(dap.list()) do
-- 			dap.disconnect(session)
-- 		end
-- 	end,
-- })
