print("It's alive")
-- remove store.db if it exists
local store = "~/.config/nvim/lua/base/custom/runner/store.db"
print("store", store)
if vim.fn.filereadable(store) == 1 then
	vim.fn.delete(store)
	print("Deleted store.db")
end

package.loaded["base.custom.runner.db"] = nil
package.loaded["base.custom.runner.runner"] = nil
package.loaded["base.custom.runner.commands.init"] = nil

local db = require("base.custom.runner.db")
local sessionid = db.newSession()

local runner = require("base.custom.runner.runner")
local commands = require("base.custom.runner.commands.init")

function customCommandOverride(filetype)
	local filetypeexceptions = vim.g.runnerfiletypeexceptions
	if filetypeexceptions then
		print("Filetype exceptions")
		for _, exception in ipairs(filetypeexceptions) do
			if filetype == exception then
				return true
			end
		end
	end
	return false
end

-- oil to normal path
vim.keymap.set("n", "E", function()
	SourceConfig()

	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local path = vim.api.nvim_buf_get_name(0)
	print("Filetype: " .. filetype)
	if filetype == "oil" then
		return
	end

	vim.cmd("noautocmd w")
	print("Path: ", path)

	local command = nil
	print("Path: " .. path)
	local override = false
	if customCommandOverride(filetype) then
		override = true
		if commands.general.inGeneral(filetype) then
			command = commands.general.create(filetype, path)
		elseif filetype == "http" then
			local bufnr = vim.api.nvim_get_current_buf()
			command = commands.http.create(bufnr)
		end
	elseif vim.g.runnercommand then
		command = vim.g.runnercommand
	elseif commands.general.inGeneral(filetype) then
		command = commands.general.create(filetype, path)
	elseif filetype == "http" then
		local bufnr = vim.api.nvim_get_current_buf()
		command = commands.http.create(bufnr)
	end
	print("Command: ", vim.inspect(command))
	--clear autocommands

	local buffer = runner.start(command, db, sessionid, path, override)
	if filetype == "http" then
		vim.api.nvim_buf_set_option(buffer, "filetype", "http")
	end
	if not buffer then
		return
	end
	local printcmd = table.concat(command, " ")
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "Command: " .. printcmd })
end)

-- on vim exit
vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		db.removeAllBuffers(sessionid)
		db.removeSession(sessionid)
		db.close()
	end,
})
