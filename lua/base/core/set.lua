vim.opt.guicursor = ""

vim.o.splitright = true
-- vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 1000

vim.opt.colorcolumn = "80"
vim.opt.clipboard = "unnamedplus"

-- vim.opt.hidden = true
--
-- Disable line wrapping
vim.o.wrap = false

-- Ensure file encoding is UTF-8
vim.o.encoding = "utf-8"

-- Ensure hidden characters (like tabs) are displayed consistently
vim.o.list = true
vim.o.listchars = "tab:>-,trail:."

vim.g.netrw_browsex_viewer = "/mnt/c/Program Files/BraveSoftware/Brave-Browser/Application/brave.exe"
