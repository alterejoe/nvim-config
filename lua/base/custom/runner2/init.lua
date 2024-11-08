local commands = require("base.custom.runner2.commands")
local db = require("base.custom.runner2.db")

local function fileExists(filename)
	local f = io.open(filename, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local function getCommand()
	local command = {}
	if fileExists("config.lua") then
		SourceConfig()
		if vim.g.runnercommand == nil then
			print(
				"No runner command found for project. Please add vim.g.runnercommand = {'your', 'command'} to your config.lua"
			)
			error()
			return
		else
			command = vim.g.runnercommand
			print("Command: ", vim.inspect(command))
		end
	else
		local filename = vim.api.nvim_buf_get_name(0)
		local filetype = vim.api.nvim_buf_get_option(0, "filetype")

		print("Filetype: ", filetype)
		if commands.general.inGeneral(filetype) then
			command = commands.general.create(filetype, filename)
		else
			print("No runner for this filetype")
			error()
		end
	end
	return command
end

vim.keymap.set("n", "E", function()
	local cwd = vim.fn.getcwd()
	local command = getCommand()

	local processExists = db.processExists(cwd, command)
	print("Process exists: ", processExists)

	-- local job = vim.fn.jobstart(command, {
	-- 	on_stdout = function(_, data, _)
	-- 		print("stdout:", data)
	-- 	end,
	-- 	on_exit = function(_, code)
	-- 		print("Exited with code:", code)
	-- 	end,
	-- })

	-- print("Command:", vim.inspect(command))
end)
