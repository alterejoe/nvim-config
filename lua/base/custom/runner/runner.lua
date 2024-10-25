local buffer = require("base.custom.runner.buffer")
local uuid = require("uuid")
local M = {}
function M.start(command, db, sessionid)
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
		end,
	})

	print("ID: " .. id)

	vim.defer_fn(function()
		print("Defer ran")
		vim.api.nvim_create_autocmd("WinClosed", {
			buffer = bufnr,
			callback = function()
				M.kill(command, id)
			end,
		})
	end, 10)

	db.newProcess(command, id)
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
