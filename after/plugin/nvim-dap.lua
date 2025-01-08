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
			SourceConfig()
			pythonpath = vim.g.python3_host_prog or "/home/altjoe/miniconda3/bin/python"
			return pythonpath
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

local function has_templ_files()
	local result = vim.fn.systemlist('find . -type f -name "*.templ"')
	if #result > 0 then
		print("Found .templ files:")
		print(vim.inspect(result))
		return true
	else
		print("No .templ files found.")
		return false
	end
end

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
		type = "dlv_spawn",
		name = "Debug test (go.mod)",
		request = "launch",
		mode = "debug",
		program = function()
			local cwd = vim.fn.getcwd()
			-- local gofile = vim.fn.expand("%:p")
			print("templ files", has_templ_files())
			if has_templ_files() then
				print("templ files found")
				local result = vim.fn.system("templ generate")
				-- if result is positive
				if result == 0 then
					print("templ generate success")
				else
					print("templ generate failed")
				end
			end
			local relpath = vim.fn.expand("%:p:~:.")
			print("relpath", relpath)
			return "${fileDirname}"
		end,
		cwd = "${workspaceFolder}",
	},
}

dap.configurations.templ = {
	{

		type = "dlv_spawn",
		name = "Debug test (go.mod)",
		request = "launch",
		mode = "debug",
		program = function()
			local cwd = vim.fn.getcwd()
			-- local gofile = vim.fn.expand("%:p")
			if has_templ_files() then
				local result = vim.fn.system("templ generate")
				-- if result is positive
				if result == 0 then
					print("templ generate success")
				else
					print("templ generate failed")
				end
			end

			return vim.g.dap_path or "./cmd/"
		end,
		-- program = vim.g.dap_path or "./cmd/",

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
				args = { "dap", "-l", "127.0.0.1:${port}", "--log" },
				-- detached = vim.fn.has("win32") == 0,
				detached = false,
			},
		})
	end
end
dap.adapters.dlv_spawn = function(callback)
	local stdout = vim.loop.new_pipe(false)
	local handle
	local port = 38697
	local opts = {
		stdio = { nil, stdout },
		args = { "dap", "-l", "127.0.0.1:" .. port },
		detached = true,
	}
	handle = vim.loop.spawn("dlv", opts, function(code)
		stdout:close()
		handle:close()
		if code ~= 0 then
			print("dlv exited with code", code)
		end
	end)
	assert(handle, "Error running dlv")
	stdout:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
			end)
		end
	end)
	-- Wait for delve to start
	vim.defer_fn(function()
		callback({ type = "server", host = "127.0.0.1", port = port })
	end, 100)
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

local dapui = require("dapui")
dapui.setup({
	layouts = {
		{
			elements = {

				-- edit: e
				-- expand: <CR> or left click
				-- open: o
				-- remove: d
				-- repl: r
				-- toggle: t
				{ id = "repl", size = 1.0 },
				-- { id = "stacks", size = 0.25 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "scopes", size = 0.25 },
				-- { id = "watches", size = 0.25 },
			},
			size = 100, -- Height of the bottom panel
			position = "right",
			--
			-- position = "bottom", -- Positions the REPL at the bottom
		},
		--
		-- layouts = {
		-- 	{
		-- 		elements = {
		-- 			{
		-- 				id = "scopes",
		-- 				size = 0.25,
		-- 			},
		-- 			{
		-- 				id = "breakpoints",
		-- 				size = 0.25,
		-- 			},
		-- 			{
		-- 				id = "stacks",
		-- 				size = 0.25,
		-- 			},
		-- 			{
		-- 				id = "watches",
		-- 				size = 0.25,
		-- 			},
		-- 		},
		-- 		position = "left",
		-- 		size = 40,
		-- 	},
		-- 	{
		-- 		elements = {
		-- 			{
		-- 				id = "repl",
		-- 				size = 0.5,
		-- 			},
		-- 			{
		-- 				id = "console",
		-- 				size = 0.5,
		-- 			},
		-- 		},
		-- 		position = "bottom",
		-- 		size = 10,
		-- 	},
	},
})
dap.listeners.after.event_exited["dapui_config"] = function()
	require("dap").close()
end

---- keybinds
local dapopen = false
vim.keymap.set("n", "<leader>d", function()
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
