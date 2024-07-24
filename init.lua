vim.opt.shell = "/usr/bin/fish"
USER = "base"
-- vim.cmd("set verbose=20")

vim.opt.conceallevel = 2
vim.o.foldenable = false -- Disable folding
vim.o.foldmethod = "manual"
-- change working directory to user root
vim.cmd("cd ~/")

function SourceConfig()
	local cwd = vim.fn.getcwd()
	local config = cwd .. "/config.lua"

	if vim.fn.filereadable(config) == 1 then
		vim.cmd("source " .. config)
	end
end
require(USER .. ".core")
require(USER .. ".lazy")
