local sqlite = require("lsqlite3")
local M = {}

local db = sqlite.open("/home/altjoe/.config/nvim/lua/base/custom/runner/store.db")
if not db then
	print("Error opening database")
	return
else
	db:exec([[
        CREATE TABLE if not exists processes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            command TEXT NOT NULL,
            uniqueid TEXT NOT NULL
        )
    ]])

	db:exec([[
        CREATE TABLE if not exists buffers(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            command TEXT NOT NULL,
            buffer TEXT NOT NULL,
        )
    ]])
end

-- Processes
function M.newProcess(command, id)
	local stmt = db:prepare("INSERT INTO processes ( command, uniqueid) VALUES ( ?, ?)")
	stmt:bind_values(command, id)
	stmt:step()
	stmt:finalize()
end

function M.getProcess(c)
	local stmt = db:prepare("SELECT * FROM processes WHERE command = ?")
	stmt:bind_values(c)
	local row = stmt:step()
	if row == sqlite.ROW then
		local id = stmt:get_value(0)
		-- local path = stmt:get_value(1)
		local command = stmt:get_value(1)
		local uniqueid = stmt:get_value(2)
		stmt:finalize()
		return { id = id, command = command, uniqueid = uniqueid }
	end
end

function M.removeProcess(command)
	local stmt = db:prepare("DELETE FROM processes WHERE command = ?")
	stmt:bind_values(command)
	stmt:step()
	stmt:finalize()
end

-- Buffers
function M.newBuffer(c, buffer)
	local stmt = db:prepare("INSERT INTO buffers (command, buffer) VALUES (?, ?)")
	stmt:bind_values(c, buffer)
	stmt:step()
	stmt:finalize()
end

function M.getBuffer(c)
	local stmt = db:prepare("SELECT * FROM buffers WHERE command = ?")
	stmt:bind_values(c)
	local row = stmt:step()
	if row == sqlite.ROW then
		local id = stmt:get_value(0)
		local command = stmt:get_value(1)
		local buffer = stmt:get_value(2)
		stmt:finalize()
		return { id = id, command = command, buffer = buffer }
	end
end

function M.removeBuffer(command)
	local stmt = db:prepare("DELETE FROM buffers WHERE command = ?")
	stmt:bind_values(command)
	stmt:step()
	stmt:finalize()
end

return M
