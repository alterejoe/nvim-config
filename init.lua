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
vim.o.foldenable = false
vim.o.foldmethod = "manual"
vim.o.foldlevel = 999
vim.o.foldlevelstart = 999
vim.o.foldcolumn = "0"

require("settings")
require("plugins")
require("keymaps")
require("autocmds")
-- require("usercmds")

-- defer fn
