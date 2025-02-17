-- nil the nvim package

local commands = require("base.custom.runner2.commands")
local pm2 = require("base.custom.runner2.pm2")
local buffers = require("base.custom.runner2.buffers")

local function fileExists(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

local function createProcessName(filename)
	print("Filename: ", filename)
	local processname = string.gsub(filename, "/", "")
	local removeextension = string.match(processname, "(.+)%.") or processname
	processname = removeextension
	local modifiedprocessname = string.sub(processname, 1)
	processname = modifiedprocessname
	return processname
end

local function createCommand(processname, filetype, filename)
	local cwd = vim.fn.getcwd()
	local c = nil
	if fileExists("config.lua") then
		if vim.g.runnercommand then
			c = vim.g.runnercommand
			processname = createProcessName(cwd)
			c = commands.correctCustomCommand(c, processname)
		else
			-- error("No runner command found in config.lua (vim.g.runnercommand)")
			c = commands.createCommand(filetype, filename, processname)
		end
	else
		c = commands.createCommand(filetype, filename, processname)
	end

	if pm2.nameExists(processname) then
		c = { "pm2", "restart", processname }
	else
		print("Process name does not exist")
	end
	return c
end

local jobs = {}
vim.keymap.set("n", "E", function()
	SourceConfig()
	local filename = vim.fn.expand("%:p")
	local filetype = vim.bo.filetype
	print("Filetype: ", filetype)
	local processname = createProcessName(filename)
	local command = createCommand(processname, filetype, filename)

	if command then
		local commandstr = table.concat(command, " ")
		print("Command: ", commandstr)

		local bufnr = nil
		if not buffers.is_visible(processname) then
			bufnr = buffers.add(processname)
			print("Buffer number: ", bufnr)
			vim.cmd("vnew")
			vim.api.nvim_win_set_buf(0, bufnr)
		else
			bufnr = buffers.active[processname]
			-- return
		end

		local function appendData(data)
			local allempty = true
			local cleaned = {}
			for _, v in ipairs(data) do
				if v ~= "" then
					allempty = false
					local vcleaned = string.gsub(v, "\r", "")
					table.insert(cleaned, vcleaned)
				end
			end

			if allempty then
				return
			end

			vim.api.nvim_buf_set_option(bufnr, "wrap", true)
			vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, cleaned)
		end
		--clear buffer
		vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
		commandstr = "pm2 flush > /dev/null " .. processname .. " && " .. commandstr .. " --no-daemon --no-autorestart"
		-- print("Command: ", commandstr)

		if jobs[processname] then
			vim.fn.jobstop(jobs[processname])
		end

		local runJob = function()
			i = vim.fn.jobstart(commandstr, {
				on_exit = function(_, code)
					print("Process exited with code: ", code)
				end,
				on_stdout = function(_, data)
					print("Data: ", vim.inspect(data))
					appendData(data)
				end,
			})
			return i
		end
		jobs[processname] = runJob()

		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = vim.fn.getcwd() .. "/*",
			callback = function()
				print("Buffer write post", vim.inspect(jobs[processname]))
				if job then
					vim.fn.jobstop(jobs[processname])
					vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
					jobs[processname] = runJob()
				end
			end,
		})
	end
end)
