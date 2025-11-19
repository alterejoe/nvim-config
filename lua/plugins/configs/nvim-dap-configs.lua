local dap = require("dap")
dap.configurations.python = {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		pythonPath = function()
			SourceConfig()
			local pythonpath = vim.g.python3_host_prog or "/home/altjoe/miniconda3/bin/python"
			print("Python path: " .. pythonpath)
			return pythonpath
		end,
	},
	{
		type = "python",
		request = "launch",
		name = "Launch root/main.py",
		program = function()
			return vim.fn.getcwd() .. "/" .. "main.py"
		end,
		pythonPath = function()
			SourceConfig()
			local pythonpath = vim.g.python3_host_prog or "/home/altjoe/miniconda3/bin/python"
			return pythonpath
		end,
	},
	{
		type = "python",
		name = "run fastapi app",
		request = "launch",
		module = "uvicorn",
		args = {
			"main:app", -- Adjust this to your FastAPI app entry point
			"--host",
			"127.0.0.1",
			"--port",
			"8000",
		},
		pythonPath = function()
			SourceConfig()
			local pythonpath = vim.g.python3_host_prog or "/home/altjoe/miniconda3/bin/python"
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

local function GetTestFunctionNames(filepath)
	local tests = {}
	local lines = vim.fn.readfile(filepath)
	for _, line in ipairs(lines) do
		local testname = string.match(line, "Test[%w_]+")
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
	-- Dynamic: Debug the cmd/* directory containing current file
	{
		type = "dlv_spawn",
		name = "Debug current cmd package",
		request = "launch",
		mode = "debug",
		program = function()
			local filepath = vim.fn.expand("%:p:h") -- :h gets directory, not file
			local cwd = vim.fn.getcwd()
			-- Find the cmd/runner* directory containing this file
			local cmd_dir = filepath:match("(.*cmd/[^/]+)")
			if cmd_dir then
				print("Debugging: ", cmd_dir)
				return cmd_dir
			end
			-- Fallback to ./cmd/ if not in a cmd subdirectory
			return cwd .. "/cmd/"
		end,
		cwd = function()
			return vim.fn.getcwd()
		end,
		args = { "-v" },
	},
	-- Interactive: Choose which runner to debug
	{
		type = "dlv_spawn",
		name = "Select cmd runner to debug",
		request = "launch",
		mode = "debug",
		program = function()
			local cwd = vim.fn.getcwd()
			local cmd_dirs = vim.fn.glob(cwd .. "/cmd/*/", false, true)

			if #cmd_dirs == 0 then
				return cwd .. "/cmd/"
			end

			-- Strip trailing slashes and make relative for display
			local choices = vim.tbl_map(function(dir)
				return dir:gsub("/$", ""):gsub(cwd .. "/", "")
			end, cmd_dirs)

			local choice = vim.fn.inputlist(vim.list_extend(
				{ "Select runner to debug:" },
				vim.tbl_map(function(i)
					return i .. ". " .. choices[i]
				end, vim.fn.range(1, #choices))
			))

			if choice > 0 and choice <= #choices then
				local selected = cmd_dirs[choice]:gsub("/$", "")
				print("Debugging: ", selected)
				return selected
			end
			return cwd .. "/cmd/"
		end,
		cwd = function()
			return vim.fn.getcwd()
		end,
		args = { "-v" },
	},

	-- Test current file
	{
		type = "dlv_spawn",
		name = "Test current file",
		request = "launch",
		mode = "test",
		program = function()
			return vim.fn.expand("%:p:h")
		end,
		args = function()
			local filepath = vim.fn.expand("%:p")
			print("filepath: ", filepath)
			local args = GetTestFunctionNames(filepath)
			print("args: ", args)
			return args
		end,
	},

	-- Debug from current working directory
	{
		type = "dlv_spawn",
		name = "Run main.go within current directory",
		request = "launch",
		mode = "debug",
		program = function()
			local cwd = vim.fn.getcwd()
			print("Current working directory: ", cwd)
			return cwd .. "/"
		end,
		cwd = function()
			local filedir = vim.fn.expand("%:p:h")
			return filedir
		end,
	},
}
--
-- dap.configurations.go = {
-- 	{
-- 		type = "dlv_spawn",
-- 		name = "cmd/main.go w/ deps",
-- 		request = "launch",
-- 		mode = "debug",
-- 		program = function()
-- 			return vim.g.dap_path or "./cmd/"
-- 		end,
-- 		args = { "-v" },
-- 	},
-- 	{
-- 		type = "dlv_spawn",
-- 		name = "cmd/main.go w/o tailwind and templ",
-- 		request = "launch",
-- 		mode = "debug",
-- 		program = function()
-- 			return "./cmd/"
-- 		end,
-- 		args = { "-v" },
-- 	},
-- 	{
-- 		type = "dlv_spawn",
-- 		name = "Test current file",
-- 		request = "launch",
-- 		mode = "test",
-- 		program = function()
-- 			return vim.fn.expand("%:p:h")
-- 		end,
-- 		args = function()
-- 			local filepath = vim.fn.expand("%:p")
-- 			print("filepath: ", filepath)
-- 			local args = GetTestFunctionNames(filepath)
-- 			print("args: ", args)
-- 			return args
-- 		end,
-- 	},
-- 	{
-- 		type = "dlv_spawn",
-- 		name = "Run single file",
-- 		request = "launch",
-- 		mode = "debug",
-- 		program = function()
-- 			print(vim.fn.expand("%:p:h"))
-- 			local cwd = vim.fn.getcwd()
-- 			print("cwd: ", cwd)
-- 			return vim.fn.expand("%:p:h")
-- 		end,
-- 	},
-- 	{
-- 		type = "dlv_spawn",
-- 		name = "Run main.go within current directory",
-- 		request = "launch",
-- 		mode = "debug",
-- 		program = function()
-- 			local cwd = vim.fn.getcwd()
-- 			print("Current working directory: ", cwd)
-- 			return cwd .. "/"
-- 		end,
-- 		cwd = function()
-- 			local filedir = vim.fn.expand("%:p:h")
-- 			return filedir
-- 		end,
-- 	},
-- }

dap.configurations.templ = {
	{
		type = "dlv_spawn",
		name = "Test main.go w/ deps",
		request = "launch",
		mode = "debug",
		program = function()
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
			return vim.g.dap_path or "./cmd/"
		end,
		args = { "-v" },
	},
}

--
-- setup
-- require("neodev").setup({
-- 	library = { plugins = { "nvim-dap-ui" }, types = true },
-- 	...,
-- })
--
-- dap.listeners.after.event_exited["dapui_config"] = function()
-- 	require("dap").close()
-- end
