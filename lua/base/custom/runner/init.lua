print("It's alive")

package.loaded["base.custom.runner.db"] = nil
package.loaded["base.custom.runner.runner"] = nil
package.loaded["base.custom.runner.commands.init"] = nil

local db = require("base.custom.runner.db")
local runner = require("base.custom.runner.runner")
local commands = require("base.custom.runner.commands.init")

vim.keymap.set("n", "E", function()
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	print("Filetype: " .. filetype)
	--
	if commands.general.inGeneral(filetype) then
		local path = vim.api.nvim_buf_get_name(0)
		local command = commands.general.create(filetype, path)
		runner.start(command, db)

		-- store id in database for killing processes later
	elseif filetype == "http" then
		local command = commands.http.create(vim.api.nvim_buf_get_name(0))
		print("Starting process: " .. command)
	end
end)
