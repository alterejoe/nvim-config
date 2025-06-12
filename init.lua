--vim.opt.shell = "/usr/bin/fish"
USER = "base"
-- vim.cmd("set verbose=20")

vim.opt.conceallevel = 2
vim.o.foldenable = false -- Disable folding
vim.o.foldmethod = "manual"
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- conceal level 0
vim.opt.conceallevel = 0

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
-- set opening window to ~/Notes/_todo.md and scroll to bottom of the screen
-- if Notes is unavailable, open ~/notes/_fleeting.md
if vim.fn.isdirectory("~/Notes") == 1 then
	vim.cmd("e ~/Notes/_todo.md")
else
	vim.cmd("e ~/notes/_fleeting.md")
end
-- scroll to bottom of the screen

-- vim enter autocmd

vim.api.nvim_create_augroup("VimEnter", { clear = true })
-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
-- 	group = "VimEnter",
-- 	callback = function()
-- 		local _todopath = "~/Notes/_todo.md"
-- 		vim.bo.filetype = "markdown"
--
-- 		vim.cmd("wincmd w")
-- 	end,
-- })

-- vim.cmd("AWStart")
-- vim.cmd("AWStatus")
vim.o.timeoutlen = 1000
