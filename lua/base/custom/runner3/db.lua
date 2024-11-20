-- sqlite
local sqlite = require("lsqlite3")

print("Sqlite", sqlite)
local db = sqlite.open("/home/altjoe/.config/nvim/lua/base/custom/runner3/store.db")

if not db then
	print("Error opening database")
	return
else
	db:exec([[
        CREATE TABLE if not exists processes(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jobid INTEGER NOT NULL,
            filepath TEXT NOT NULL,
            isProject BOOLEAN NOT NULL
        )
    ]])

	db:exec([[
        CREATE TABLE if not exists ignoreproject(
            filepath TEXT NOT NULL
        )
    ]])
end

local M = {}

M.newProcess = function(jobid, filepath, isProject)
	local stmt = db:prepare("INSERT INTO processes (jobid, filepath, isProject) VALUES (?, ?, ?)")
	stmt:bind_values(jobid, filepath, isProject)
	stmt:step()
	stmt:finalize()
end

-- the filepath will either be the standalone file or the cwd
M.processExists = function(filepath)
	local stmt = db:prepare("SELECT * FROM processes WHERE filepath = ?")
	stmt:bind_values(filepath)
	local result = stmt:step()
	stmt:finalize()
	return result == sqlite.ROW
end

M.removeProcess = function(filepath)
	local stmt = db:prepare("DELETE FROM processes WHERE filepath = ?")
	stmt:bind_values(filepath)
	stmt:step()
	stmt:finalize()
end

M.getProcess = function(filepath)
	local stmt = db:prepare("SELECT * FROM processes WHERE filepath = ?")
	stmt:bind_values(filepath)
	local result = stmt:step()
	stmt:finalize()
	return result
end

M.newIgnoreProject = function(filepath)
	local stmt = db:prepare("INSERT INTO ignoreproject (filepath) VALUES (?)")
	stmt:bind_values(filepath)
	stmt:step()
	stmt:finalize()
end

M.ignoreProjectExists = function(filepath)
	local stmt = db:prepare("SELECT * FROM ignoreproject WHERE filepath = ?")
	stmt:bind_values(filepath)
	local result = stmt:step()
	stmt:finalize()
	return result == sqlite.ROW
end

M.removeIgnoreProject = function(filepath)
	local stmt = db:prepare("DELETE FROM ignoreproject WHERE filepath = ?")
	stmt:bind_values(filepath)
	stmt:step()
	stmt:finalize()
end

return M
