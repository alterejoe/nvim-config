--vim.opt.shell = "/usr/bin/fish"
USER = "base"
-- vim.cmd("set verbose=20")

vim.opt.conceallevel = 2
vim.o.foldenable = false -- Disable folding
vim.o.foldmethod = "manual"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
--
-- change working directory to user root
vim.cmd("cd ~/")

function SourceConfig()
	local cwd = vim.fn.getcwd()
	local config = cwd .. "/config.lua"

	if vim.fn.filereadable(config) == 1 then
		vim.cmd("source " .. config)
	end
end

require(USER .. ".lazy")
require(USER .. ".core")
require(USER .. ".custom")

vim.api.nvim_create_augroup("SetRelativeNumber", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead" }, {
	group = "SetRelativeNumber",
	callback = function()
		if vim.wo.relativenumber == false then
			vim.wo.relativenumber = true
		end
	end,
})
