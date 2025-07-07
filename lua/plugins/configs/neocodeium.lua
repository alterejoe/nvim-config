-- NeoCodeium Configuration
local neocodeium = require("neocodeium")
neocodeium.setup({
	enabled = true,
	root_dir = { ".git", "config.lua", "Makefile", ".env" },
	debounce = 150,
	-- filetypes = {
	-- 	help = false,
	-- 	gitcommit = false,
	-- 	gitrebase = false,
	-- 	["."] = true,
	-- },
	-- log_level = "info",
	-- silent = false,
	-- disable_in_special_buftypes = false,
})
