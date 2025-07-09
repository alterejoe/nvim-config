function SourceConfig()
	local cwd = vim.fn.getcwd()
	local config = cwd .. "/config.lua"

	if vim.fn.filereadable(config) == 1 then
		vim.cmd("source " .. config)
	end
end
vim.diagnostic.config({
	virtual_text = true,
})

require("settings")
require("plugins")
require("autocmds")
require("keymaps")

-- defer fn
