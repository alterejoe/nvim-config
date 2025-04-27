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
	-- local cwd = vim.fn.getcwd()
	-- local result = vim.fn.system("templ generate -path=" .. cwd)
	-- print("templ generate: ", result)
	-- -- needed if not using local
	-- result = vim.fn.system("npx @tailwindcss/cli -i ./ui/static/globals.css -o ./ui/static/output.css --cwd " .. cwd)
	-- print("tailwindcss: ", result)
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
	{
		type = "dlv_spawn",
		name = "Test main.go w/ deps",
		request = "launch",
		mode = "debug",
		program = function()
			-- local cwd = vim.fn.getcwd()
			-- return "${workspaceFolder}"
			print("dap_path: ", vim.g.dap_path)
			goserverdeps()
			return vim.g.dap_path or "./cmd/"
		end,
		args = { "-v" },
	},
	{
		type = "dlv_spawn",
		name = "Test main.go w/o tailwind and templ",
		request = "launch",
		mode = "debug",
		program = function()
			return "./cmd/"
		end,
		args = { "-v" },
	},
}

dap.configurations.templ = {
	{
		type = "dlv_spawn",
		name = "Test main.go w/ deps",
		request = "launch",
		mode = "debug",
		program = function()
			-- local cwd = vim.fn.getcwd()
			-- return "${workspaceFolder}"
			print("dap_path: ", vim.g.dap_path)
			goserverdeps()
			return vim.g.dap_path or "./cmd/"
		end,
		args = { "-v" },
	},
}

dap.configurations.javascript = {
	{
		type = "dlv_spawn",
		name = "Test main.go w/ deps",
		request = "launch",
		mode = "debug",
		program = function()
			-- local cwd = vim.fn.getcwd()
			-- return "${workspaceFolder}"
			print("dap_path: ", vim.g.dap_path)
			goserverdeps()
			return vim.g.dap_path or "./cmd/"
		end,
		args = { "-v" },
	},
}

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
-- vim.keymap.set("n", "<leader>t", function()
-- 	require("dap.ui.variables").scopes()
-- end, { noremap = true, silent = true })

-- control left
vim.keymap.set("n", "<C-Left>", function()
	require("dap").up()
end, { noremap = true, silent = true })

-- control right
vim.keymap.set("n", "<C-Right>", function()
	require("dap").down()
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>t", function()
	local frames = require("dap.ui.widgets").frames
	print(vim.inspect(frames))
end, { noremap = true, silent = true })
