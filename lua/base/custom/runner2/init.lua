print("Working!")

-- package.loaded["base.custom.runner.commands.init"] = nil

local commands = require("base.custom.runner2.commands")

print("General commands", commands)

vim.keymap.set("n", "E", function()
	local cwd = vim.fn.getcwd()
	print("Current working directory: " .. cwd)
end)
