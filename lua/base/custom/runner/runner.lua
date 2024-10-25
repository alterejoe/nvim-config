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

function M.start(command, db, sessionid, path)
	local groupname = M.uniqueGroup(path)
	vim.api.nvim_clear_autocmds({ group = groupname })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = groupname,
		pattern = path,
		callback = function()
			M.start(command, db, sessionid, path)
		end,
	})

	local id = uuid.new()
	local uniquecommand = command .. " --unique-id=" .. id
	local bufnr = nil

	local previousBuffer = db.getBuffer(command)

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

	local oldprocess = db.getProcess(command)
	if oldprocess then
		local c = oldprocess.command
		local unique_id = oldprocess.uniqueid
		M.kill(c, unique_id)
		db.removeProcess(command)
		print("Old process removed")
	end

	local function appendData(data)
		local allempty = true
		for _, v in ipairs(data) do
			if v ~= "" then
				allempty = false
				break
			end
		end

		if allempty then
			return
		end

		vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, data)
		return bufnr
	end

	print("Starting process: " .. uniquecommand)
	local job = vim.fn.jobstart(uniquecommand, {
		on_stdout = function(_, data, _)
			appendData(data)
		end,
		on_stderr = function(_, data, _)
			appendData(data)
		end,
		on_exit = function(_, code, _)
			appendData({ "Process exited with code: " .. code })
			M.kill(command, id) -- not sure if nessicary
			-- db.removeBuffer(command)
		end,
	})

	print("ID: " .. id)

	vim.defer_fn(function()
		print("Defer ran")
		vim.api.nvim_create_autocmd("WinClosed", {
			buffer = bufnr,
			callback = function()
				M.kill(command, id)
				db.removeBuffer(command)
			end,
		})
	end, 10)

	db.newProcess(command, id)
	return bufnr
end

function M.kill(c, unique_id)
	-- local printcmd = "ps aux | pgrep -f " .. unique_id
	local command = "ps aux | pgrep -f " .. unique_id .. " | xargs kill -9"

	vim.fn.jobstart(command, {
		on_stdout = function(_, data, _)
			print("stdout: ", data)
		end,
		on_stderr = function(_, data, _)
			print("stderr: ", data)
		end,
	})
end

return M
