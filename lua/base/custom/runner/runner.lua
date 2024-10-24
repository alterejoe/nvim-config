local buffer = require("base.custom.runner.buffer")

local M = {}
M.uuid = require("uuid")
function M.start(command, db)
	local oldprocess = db.getProcess(command)
	if oldprocess then
		local c = oldprocess.command
		local unique_id = oldprocess.uniqueid
		M.kill(c, unique_id)
		db.removeProcess(command)
		print("Old process removed")
	end

	local id = M.uuid.new()
	local uniquecommand = command .. " --unique-id=" .. id

	local bufnr = db.getBuffer(command)
	if not bufnr then
		bufnr = buffer.create(command)
		db.newBuffer(command, bufnr)
	end

	print("Buffer number: " .. bufnr)

	print("Starting process: " .. uniquecommand)
	local job = vim.fn.jobstart(uniquecommand, {
		on_stdout = function(_, data, _)
			-- print("stdout: ", data)
		end,
		on_stderr = function(_, data, _)
			-- print("stderr: ", data)
		end,
		on_exit = function(_, code, _)
			-- print("exit code: ", code)
		end,
	})

	db.newProcess(command, id)
end

function M.kill(c, unique_id, db)
	local bufnr = db.getBuffer(c)
	if bufnr then
		buffer.kill(bufnr)
		db.removeBuffer(c)
	end

	local printcmd = "ps aux | pgrep -f " .. unique_id
	vim.fn.jobstart(printcmd, {
		on_stdout = function(_, data, _)
			-- print("stdout: ", data)
		end,
	})
	local command = "ps aux | pgrep -f " .. unique_id .. " | xargs kill -9"

	vim.fn.jobstart(command)
end

return M
