print("Working")
local db = require("base.custom.runner3.db")

local function configAtRoot(cwd)
	local configpath = cwd .. "/config.lua"
	print("Config path", configpath)
	if vim.fn.filereadable(configpath) == 1 then
		return true
	end
	return false
end

local function getCommand(filename, filetype, isProject)
	local cmd = "stdbuf -oL -eL "

	if isProject then
		if vim.g.runnercommand then
			cmd = cmd .. vim.g.runnercommand
		else
			error("No runner command found in config.lua (vim.g.runnercommand)")
		end
		return cmd
	end
	if filetype == "python" then
		cmd = cmd .. "python3 " .. filename
	elseif filetype == "go" then
		cmd = cmd .. "go run " .. filename
	else
		error("Command not implemented for filetype: " .. filetype)
	end
	return cmd
end

vim.keymap.set("n", "E", function()
	SourceConfig()
	local isProject = false
	local cwd = vim.fn.getcwd()
	local absolutefilename = vim.fn.expand("%:p")
	if configAtRoot(cwd) then
		if db.ignoreProjectExists(absolutefilename) then
			print("Run file as standalone")
		else
			print("Run file as project")
			isProject = true
		end
	end

	print("Is project", isProject)

	local filetype = vim.bo.filetype
	local command = getCommand(absolutefilename, filetype, isProject)
	print("Command: ", command)
end, { noremap = true })

vim.keymap.set("n", "EI", function()
	local absolutefilename = vim.fn.expand("%:p")
	if db.ignoreProjectExists(absolutefilename) then
		db.removeIgnoreProject(absolutefilename)
		print("Removed ignore project")
	else
		db.newIgnoreProject(absolutefilename)
		print("Added ignore project")
	end
end, { noremap = true })
