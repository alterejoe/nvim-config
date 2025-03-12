local dap = require("dap")
--
-- require("dap").defaults.fallback.terminal_win_cmd = "50vsplit new"
-- vim.fn.sign_define("DapStopped", { text = "🔴", texthl = "Error", linehl = "", numhl = "" })

dap.defaults.fallback.terminal_win_cmd = "50vsplit new"
vim.keymap.set("n", "<leader>bp", dap.up, { desc = "Debug: DAP Stack UP" })
vim.keymap.set("n", "<leader>bn", dap.down, { desc = "Debug: DAP Stack DOWN" })

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

-- local function has_templ_files()
-- 	local result = vim.fn.systemlist('find . -type f -name "*.templ"')
-- 	if #result > 0 then
-- 		print("Found .templ files:")
-- 		print(vim.inspect(result))
-- 		return true
-- 	else
-- 		print("No .templ files found.")
-- 		return false
-- 	end
-- end

local goserverdeps = function()
	local cwd = vim.fn.getcwd()
	local result = vim.fn.system("templ generate -path=" .. cwd)
	print("templ generate: ", result)
	result = vim.fn.system("npx @tailwindcss/cli -i ./ui/static/globals.css -o ./ui/static/output.css")
	print("tailwindcss: ", result)
end

local function GetTestFunctionNames(filepath)
	local tests = {}
	local lines = vim.fn.readfile(filepath)
	-- local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(lines) do
		-- print("line: ", line)
		-- local funcfound = string.find(line, "func")
		-- if funcfound then
		-- 	local testfound = string.find(line, "Test")
		-- 	if testfound then
		local testname = string.match(line, "Test[%w_]+")
		-- print("testname: ", testname)
		if testname then
			table.insert(tests, testname)
		end
	end
	if #tests > 0 then
		local pattern = "^(" .. table.concat(tests, "|") .. ")$"
		return { "-test.v", "-test.run", pattern }
	else
		return { "-test.v" }
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
		name = "Run normally",
		request = "launch",
		mode = "debug",
		program = function()
			goserverdeps()
			return vim.g.dap_path or "./cmd/"
		end,
		cwd = "${workspaceFolder}",
	},
	{
		type = "dlv_spawn",
		name = "Debug test current file",
		request = "launch",
		mode = "test",
		program = "${fileDirname}",
		-- program = function() end,
		-- args = { "-v" },
		-- only test current file
		-- args = { "-test.v", "-test.run", "Test" },
		args = function()
			local current_file = vim.fn.expand("%:t")
			local isTestFile = string.match(current_file, "_test.go")
			if isTestFile then
				local current_file_path = vim.fn.expand("%:p")
				return GetTestFunctionNames(current_file_path)
			else
				local currentfile_test = vim.fn.expand("%:p:r") .. "_test.go"
				if vim.fn.filereadable(currentfile_test) == 1 then
					return GetTestFunctionNames(currentfile_test)
				else
					return { "-v" }
				end
			end
		end,
	},
	{
		type = "dlv_spawn",
		name = "Debug test current folder",
		request = "launch",
		mode = "test",
		program = function()
			return "${fileDirname}"
		end,
		args = { "-v" },
	},
}

dap.configurations.templ = {
	{

		type = "dlv_spawn",
		name = "Debug test (go.mod)",
		request = "launch",
		mode = "debug",
		program = function()
			goserverdeps()
			return vim.g.dap_path or "./cmd/"
		end,
		-- program = vim.g.dap_path or "./cmd/",

		cwd = "${workspaceFolder}",
	},
}

dap.configurations.javascript = {
	{

		type = "dlv_spawn",
		name = "Debug test (go.mod)",
		request = "launch",
		mode = "debug",
		program = function()
			-- local cwd = vim.fn.getcwd()
			-- local result = vim.fn.system("templ generate")
			-- print("templ generate: ", result)
			local cwd = vim.fn.getcwd()
			goserverdeps()
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
			options = {
				args = { "--log-output=rpc" }, -- Avoids escape codes in logs
			},
		})
	else
		callback({
			type = "server",
			port = "${port}",
			executable = {
				command = "dlv",
				args = { "dap", "-l", "127.0.0.1:${port}", "--log" },
				detached = vim.fn.has("win32") == 0,
				-- detached = false,
			},
			options = {
				args = { "--log-output=rpc -gcflags='all=-N -l'" }, -- Avoids escape codes in logs
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
				{ id = "repl", size = 1.0 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "scopes", size = 0.25 },
				{ id = "stacks", size = 0.25 },
			},
			size = 100, -- Height of the bottom panel
			position = "right",
		},
		{
			elements = {
				{ id = "repl", size = 1.0 },
				{ id = "breakpoints", size = 0.25 },
				{ id = "scopes", size = 0.25 },
				{ id = "stacks", size = 0.25 },
			},
			size = 25, -- Height of the bottom panel
			position = "bottom",
		},
	},
	element_mappings = {
		stacks = {
			open = "<CR>", -- Open the current frame in the editor
			expand = "o", -- Close the current frame
		},
	},
})
dap.listeners.after.event_exited["dapui_config"] = function()
	require("dap").close()
end

function OpenDap(layoutid)
	dapui.open({ layout = layoutid })
end

function CloseDap()
	dapui.close()
end
---- keybinds
local dapopen = false
vim.keymap.set("n", "<leader>d", function()
	if dapopen then
		CloseDap()
		dapopen = false
	else
		OpenDap(1)
		dapopen = true
	end
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>h", function()
	if dapopen then
		CloseDap()
		-- dapui.close()
		dapopen = false
	else
		OpenDap(2)
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

require("dap").listeners.after.event_terminated["user_listener"] = function()
	terminate = false
end

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

vim.keymap.set("n", "<c-n>", function()
	vim.cmd("DapNew")
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

-- backtrace
vim.keymap.set("n", "<leader>t", function()
	require("dap.ui.variables").scopes()
end, { noremap = true, silent = true })
