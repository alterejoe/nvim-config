print("Working")
local db = require("base.custom.runner3.db")
db.clearProcesses()
local http = require("base.custom.runner3.http")
local fileExists = function(path)
	return vim.loop.fs_stat(path) ~= nil
end
local function configAtRoot(cwd)
	if fileExists(cwd .. "/config.lua") then
		return true
	end
	return false
end

local function filetypeCommand(filetype, filename)
	if filetype == "python" then
		return "python3 -u " .. filename
	elseif filetype == "go" then
		return "go run " .. filename
	elseif filetype == "http" then
		local cmd = http.createCmd()
		print("cmd", cmd)
		return http.createCmd()
	else
		error("Command not implemented for filetype: " .. filetype)
	end
end

local function getCommand(filename, filetype, isProject)
	local cmd = "stdbuf -oL -eL "
	if db.ignoreProjectExists(filename) then
		isProject = false
	end

	if isProject then
		cmd = "stdbuf -oL -eL "

		if vim.g.runnercommand then
			cmd = cmd .. vim.g.runnercommand
			return cmd
		else
			print("No vim.g.runnercommand")
			cmd = cmd .. filetypeCommand(filetype, filename)
			return cmd
		end
	end
	cmd = cmd .. filetypeCommand(filetype)
	return cmd
end

local function createBuffer()
	local buf = vim.api.nvim_create_buf(false, true)
	--set filetype to outputa
	vim.api.nvim_buf_set_option(buf, "filetype", output)
	--
	-- split to right
	vim.cmd("vsplit")
	vim.api.nvim_win_set_buf(0, buf)
	return buf
end

function getAugroup(dashedname)
	-- if group already created return it
	local success, groupid = pcall(vim.api.nvim_get_augroup, dashedname)

	if success then
		return groupid
	else
		local group = vim.api.nvim_create_augroup(dashedname, { clear = true })
		return group
	end
end

local buffers = {}
vim.keymap.set("n", "E", function()
	SourceConfig()
	vim.cmd("w")
	local currentwindow = vim.api.nvim_get_current_win()
	local isProject = false
	local cwd = vim.fn.getcwd()
	local absolutefilename = vim.fn.expand("%:p")
	-- replace oil:// with "" from filename
	if string.match(absolutefilename, "oil://") then
		absolutefilename = string.gsub(absolutefilename, "oil://", "")
		-- remove last /
		absolutefilename = string.gsub(absolutefilename, "/$", "")
	end

	if configAtRoot(cwd) then
		if not db.ignoreProjectExists(absolutefilename) then
			isProject = true
			absolutefilename = cwd
		end
	end

	local filetype = vim.bo.filetype
	local exclude = { "scratch", "help", "qf", "terminal", "packer", "dashboard", "NvimTree", "", "output" }
	for _, name in ipairs(exclude) do
		if vim.bo.filetype == name then
			print("Filetype is excluded")
			return
		end
	end

	local command = getCommand(absolutefilename, filetype, isProject)

	print(command)
	if command == nil then
		return
	end
	if db.processExists(absolutefilename) then
		local process = db.getProcess(absolutefilename)
		vim.fn.jobstop(process.jobid)
		db.removeProcess(absolutefilename)
	end

	local dashedname = string.gsub(absolutefilename, "/", "-")
	dashedname = string.sub(dashedname, 2)
	dashedname = string.gsub(dashedname, "%..*$", "")

	if buffers[dashedname] == nil then
		if filetype == "http" then
			buffers[dashedname] = createBuffer("http")
		else
			buffers[dashedname] = createBuffer("output")
		end
	else
		if filetype == "http" then
			vim.api.nvim_buf_set_option(buffers[dashedname], "filetype", "http")
		end

		vim.api.nvim_buf_set_lines(buffers[dashedname], 0, -1, false, {})
	end

	local appendData = function(data, trailing)
		-- append lines to buffer
		if buffers[dashedname] == nil then
			return
		end

		local noempty = {}
		for i, line in ipairs(data) do
			if line ~= "" then
				table.insert(noempty, line)
			end
		end
		-- add empty line at the end
		if trailing then
			table.insert(noempty, "")
		end
		vim.api.nvim_buf_set_lines(buffers[dashedname], -1, -1, false, noempty)
	end

	local job = vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			appendData(data)
			print("")
		end,
		on_stderr = function(_, data, _)
			appendData(data)
		end,
		on_exit = function(_, code, _)
			appendData({ "Process exited with code: " .. code })
		end,
	})
	db.newProcess(job, absolutefilename, isProject)
	-- buf write post

	local groupname = getAugroup(dashedname)
	vim.api.nvim_clear_autocmds({ group = groupname })
	--
	vim.api.nvim_create_autocmd("BufWritePost", {
		pattern = vim.fn.getcwd() .. "/*",
		group = groupname,
		callback = function()
			local filepath = vim.fn.expand("%:p")
			if db.ignoreProjectExists(filepath) then
				return
			end
			vim.fn.jobstop(job)
			db.removeProcess(absolutefilename)
			job = vim.fn.jobstart(command, {
				on_stdout = function(_, data, _)
					appendData(data)
				end,
				on_stderr = function(_, data, _)
					appendData(data)
				end,
				on_exit = function(_, code, _)
					appendData({ "Process exited with code: " .. code })
				end,
			})
			db.newProcess(job, absolutefilename, isProject)
		end,
	})
	-- loc
	-- on buffer close
	vim.api.nvim_create_autocmd({ "BufWinLeave" }, {
		buffer = buffers[dashedname],
		group = groupname,
		callback = function()
			vim.fn.jobstop(job)
			db.removeProcess(absolutefilename)
			-- wait for job to stop before removing buffer
			vim.defer_fn(function()
				buffers[dashedname] = nil
			end, 100)
		end,
	})
	-- move cursor back to currentbuffer
	vim.api.nvim_set_current_win(currentwindow)
end, { noremap = true })

vim.keymap.set("n", "I", function()
	local absolutefilename = vim.fn.expand("%:p")
	if db.ignoreProjectExists(absolutefilename) then
		db.removeIgnoreProject(absolutefilename)
		print("Removed ignore project")
	else
		db.newIgnoreProject(absolutefilename)
		print("Added ignore project")
	end
end, { noremap = true })
