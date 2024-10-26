print("It's alive")

package.loaded["base.custom.runner.db"] = nil
package.loaded["base.custom.runner.runner"] = nil
package.loaded["base.custom.runner.commands.init"] = nil

local db = require("base.custom.runner.db")
local sessionid = db.newSession()

local runner = require("base.custom.runner.runner")
local commands = require("base.custom.runner.commands.init")

vim.keymap.set("n", "E", function()
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	print("Filetype: " .. filetype)
	local path = vim.api.nvim_buf_get_name(0)
	local command = nil
	if commands.general.inGeneral(filetype) then
		command = commands.general.create(filetype, path)
	elseif filetype == "http" then
		local bufnr = vim.api.nvim_get_current_buf()
		command = commands.http.create(bufnr)
		print("Starting process: " .. command)
	end

	--clear autocommands
	local buffer = runner.start(command, db, sessionid, path)
	if filetype == "http" then
		vim.api.nvim_buf_set_option(buffer, "filetype", "http")
	end
	if not buffer then
		return
	end
	vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
end)

-- on vim exit
vim.api.nvim_create_autocmd("VimLeave", {
	callback = function()
		db.removeAllBuffers(sessionid)
		db.removeSession(sessionid)
		db.close()
	end,
})
