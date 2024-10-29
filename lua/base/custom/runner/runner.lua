local buffer = require("base.custom.runner.buffer")
local uuid = require("uuid")

local M = {}
function M.uniqueGroup(path)
	-- if group already created return it
	local cleanpath = string.gsub(path, "/", "_")
	print("Cleanpath: " .. cleanpath)
	local success, groupid = pcall(vim.api.nvim_get_augroup, cleanpath)

	if success then
		return groupid
	else
		local group = vim.api.nvim_create_augroup(cleanpath, { clear = true })
		return group
	end
end

function M.start(command, db, sessionid, path, override)
	local environment = {
		UUID = uuid.new(),
	}

	local groupname = M.uniqueGroup(path)
	vim.api.nvim_clear_autocmds({ group = groupname })

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = groupname,
		pattern = vim.fn.getcwd() .. "/*",
		callback = function()
			-- M.start(command, db, sessionid, path, override)
			local p = vim.api.nvim_buf_get_name(0)
			print("On save: ", p)
			if p == path then
				M.start(command, db, sessionid, path, override)
			else
				for i, pattern in ipairs(vim.g.runnerpattern) do
					if string.match(p, pattern) then
						print("Pattern matched: ", pattern)
						M.start(command, db, sessionid, path, override)
						return
					end
				end
			end
		end,
	})

	-- vim.api.nvim_create_autocmd("BufWritePost", {
	-- 	callback = function()
	-- 		print("Should run each time I save")
	-- 	end,
	-- })

	local uniquecommand = command
	-- if curl in command then add -s flag or if make in command do not add unique id
	if not command:find("curl") and not command:find("make") then
		uniquecommand = command .. " --unique-id=" .. environment.UUID
	end
	print("Unique command: ", uniquecommand)
	local bufnr = nil

	local previousBuffer = db.getBuffer(command)
	print("Previous buffer: ", vim.inspect(previousBuffer))
	if previousBuffer then
		if sessionid ~= previousBuffer.sessionid then
			print("Proccess already running in another nvim instance")
			return
		end
		buffer.showBuffer(previousBuffer.bufnr)
		bufnr = previousBuffer.bufnr
	else
		bufnr = buffer.create(command)
		local header = db.newBuffer(command, bufnr, sessionid)
		print("Buffer created")
	end

	print("Command: ", command)
	local oldprocess = db.getProcess(command)
	print("Old process: ", vim.inspect(oldprocess))
	if oldprocess then
		local c = oldprocess.command
		local unique_id = oldprocess.uniqueid
		-- wait for kill to finish before continuing
		M.kill(c, unique_id)
		db.removeProcess(command)
		print("Old process removed")
		-- db.removeProcess(command)
		-- print("Old process removed")
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

		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, cleaned)
		return bufnr
	end

	print("Starting process: " .. uniquecommand)
	local job = vim.fn.jobstart(uniquecommand, {
		env = environment,
		on_stdout = function(_, data, _)
			appendData(data)
		end,
		on_stderr = function(_, data, _)
			appendData(data)
		end,
		on_exit = function(_, code, _)
			-- appendData({ "Process exited with code: " .. code })
			M.kill(command, environment.UUID)
			-- db.removeBuffer(command)
		end,
	})

	-- print("ID: " .. id)

	vim.defer_fn(function()
		vim.api.nvim_create_autocmd("WinClosed", {
			buffer = bufnr,
			callback = function()
				vim.api.nvim_clear_autocmds({ group = groupname })
				M.kill(command, environment.UUID)
				db.removeBuffer(command)
			end,
		})
	end, 10)

	db.newProcess(command, environment.UUID)
	return bufnr
end

function M.kill(c, unique_id)
	-- local printcmd = "ps aux | pgrep -f " .. unique_id
	print("Killing process: " .. c .. " with unique id: " .. unique_id)
	local command = "ps aux | pgrep -f " .. unique_id .. " | xargs kill -9"

	vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			-- print("stdout: ", data)
			-- for i, line in ipairs(data) do
			-- 	print("\t", i, line)
			-- end
		end,
		on_stderr = function(_, data, _)
			-- print("stderr: ", data)
			-- for i, line in ipairs(data) do
			-- 	print("\t", i, line)
			-- end
		end,
	})
end

return M
