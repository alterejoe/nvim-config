local sqlite = require("lsqlite3")
local M = {}
M.uuid = require("uuid")
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
            bufnr INTEGER NOT NULL,
            sessionid TEXT NOT NULL
        )
    ]])

	db:exec([[
        CREATE TABLE if not exists logs(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            command TEXT NOT NULL,
            data TEXT NOT NULL
        )
    ]])

	db:exec([[
        CREATE TABLE if not exists sessions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            sessionid TEXT NOT NULL
        )
    ]])
end

-- db
function M.close()
	db:close()
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
function M.newBuffer(c, buffer, sessionid)
	if string.find(c, "curl") then
		c = "curl"
	end
	local stmt = db:prepare("INSERT INTO buffers (command, bufnr, sessionid) VALUES ( ?, ?, ?)")
	local header = "Command: " .. c .. "\n"
	stmt:bind_values(c, buffer, sessionid)
	stmt:step()
	stmt:finalize()
	return header
end

function M.getBuffer(c)
	-- if curl in c
	if string.find(c, "curl") then
		c = "curl"
	end
	local stmt = db:prepare("SELECT * FROM buffers WHERE command = ? ")
	if not stmt then
		error("Error preparing statement: getBuffer")
	end
	stmt:bind_values(c)
	local row = stmt:step()
	if row == sqlite.ROW then
		local id = stmt:get_value(0)
		local command = stmt:get_value(1)
		local bufnr = stmt:get_value(2)
		local sessionid = stmt:get_value(3)
		stmt:finalize()
		bufnr = tonumber(bufnr)

		return { id = id, command = command, bufnr = bufnr, sessionid = sessionid }
	end
end

function M.updateBuffer(c, text)
	local stmt = db:prepare("UPDATE buffers SET data = ? WHERE command = ?")
	stmt:bind_values(text, c)
	stmt:step()
	stmt:finalize()
end

function M.removeBuffer(command)
	local stmt = db:prepare("DELETE FROM buffers WHERE command = ?")
	stmt:bind_values(command)
	stmt:step()
	stmt:finalize()
end

function M.removeAllBuffers(sessionid)
	local stmt = db:prepare("DELETE FROM buffers WHERE sessionid = ?")
	stmt:bind_values(sessionid)
	stmt:step()
	stmt:finalize()
end

-- Sessions
function M.newSession(sessionid)
	local uniqueid = M.uuid.new()
	local stmt = db:prepare("INSERT INTO sessions (sessionid) VALUES (?)")
	stmt:bind_values(uniqueid)
	stmt:step()
	stmt:finalize()
	return uniqueid
end

function M.removeSession(sessionid)
	local stmt = db:prepare("DELETE FROM sessions WHERE sessionid = ?")
	stmt:bind_values(sessionid)
	stmt:step()
	stmt:finalize()
end

------- future development historical logs
function M.newLog(command, data)
	local stmt = db:prepare("INSERT INTO logs (command, data) VALUES (?, ?)")
	stmt:bind_values(command, data)
	stmt:step()
	stmt:finalize()
end

function M.getLogs(command)
	local stmt = db:prepare("SELECT * FROM logs WHERE command = ?")
	stmt:bind_values(command)
	local logs = {}
	for row in stmt:rows() do
		table.insert(logs, row[2])
	end
	return logs
end

function M.removeOldestLog(command)
	local stmt = db:prepare("SELECT * FROM logs WHERE command = ? ORDER BY id DESC")
	stmt:bind_values(command)
	local logs = {}
	for row in stmt:rows() do
		table.insert(logs, row[1])
	end

	for i = 1, #logs - 10 do
		local st = db:prepare("DELETE FROM logs WHERE id = ?")
		st:bind_values(logs[i].id)
		st:step()
		st:finalize()
	end
end

return M
