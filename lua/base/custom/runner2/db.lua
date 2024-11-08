local sqlite = require("lsqlite3")
-- local uuid = require("uuid")

local M = {}
local db = sqlite.open("/home/altjoe/.config/nvim/lua/base/custom/runner2/store.db")

if not db then
	print("Error opening database")
	return
else
	db:exec([[
        CREATE TABLE if not exists processes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cwd TEXT NOT NULL,
            command TEXT NOT NULL,
            UNIQUE(cwd, command)
        )
    ]])

	db:exec([[
        CREATE TABLE if not exists ignorepath(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            process_id INTEGER NOT NULL,
            filepath TEXT NOT NULL,
            FOREIGN KEY(process_id) REFERENCES processes(id)
        )
    ]])
end

function M.close()
	db:close()
end

function M.newProcess(cwd, command)
	local stmt = db:prepare("INSERT INTO processes (cwd, command) VALUES (?, ?)")
	stmt:bind_values(cwd, command)
	stmt:step()
	stmt:finalize()
end

function M.removeProcess(cwd, command)
	local stmt = db:prepare("DELETE FROM processes WHERE cwd = ? AND command = ?")
	stmt:bind_values(cwd, command)
	stmt:step()
	stmt:finalize()
end

function M.getProcess(cwd, command)
	command = table.concat(command, " ")
	local stmt = db:prepare("SELECT * FROM processes WHERE cwd = ? AND command = ?")
	print("CWD: ", cwd)
	print("Command: ", command)
	stmt:bind_values(cwd, command)
	local row = stmt:step()
	stmt:finalize()
	print("Row", vim.inspect(row))
	return row
end

function M.processExists(cwd, command)
	local row = M.getProcess(cwd, command)
	print("Row: ", row)
	return row ~= nil
end

function M.newIgnorePath(process_id, filepath)
	local stmt = db:prepare("INSERT INTO ignorepath (process_id, filepath) VALUES (?, ?)")
	stmt:bind_values(process_id, filepath)
	stmt:step()
	stmt:finalize()
end

function M.removeIgnorePath(process_id, filepath)
	local stmt = db:prepare("DELETE FROM ignorepath WHERE process_id = ? AND filepath = ?")
	stmt:bind_values(process_id, filepath)
	stmt:step()
	stmt:finalize()
end

function M.getIgnorePaths(process_id)
	local stmt = db:prepare("SELECT * FROM ignorepath WHERE process_id = ?")
	stmt:bind_values(process_id)
	local row = stmt:step()
	local ignorepaths = {}
	while row do
		table.insert(ignorepaths, row[3])
		row = stmt:step()
	end
	stmt:finalize()
	return ignorepaths
end

return M
