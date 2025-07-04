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
-- require(USER .. ".custom")

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
local notespath = "/_fleeting.md"
if vim.fn.isdirectory("~/Notes") == 1 then
	vim.cmd("e ~/Notes/" .. notespath)
else
	vim.cmd("e ~/notes/" .. notespath)
end
vim.o.timeoutlen = 1000
