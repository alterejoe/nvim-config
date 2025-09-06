require("conform").setup({
	-- Map of filetype to formatters
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		-- python = { "pyproject-fmt" },
		go = { "goimports", "gofmt" },
		vimwiki = { command = "prettierd", args = { "--markdown-unordered-list-marker", "*" } },
		-- json = { "jq" },
		-- javascript = { "biome" },
		javascript = { "biome" },
		templ = { "templ" },
		-- template = { "gohtml" },
		-- template = { "prettierd" },
		json = { "prettierd" },
		typescript = { "prettierd" },
		html = { "prettierd" },
		gdscript = { "gdformat" },
		sql = { "pg_format" },
		http = { "kulala-fmt" },
		css = { "prettierd" },
	},
	format_on_save = {
		timeout_ms = 2500,
		lsp_fallback = true,
	},
	-- -- If this is set, Conform will run the formatter asynchronously after save.
	-- -- It will pass the table to conform.format().
	-- -- This can also be a function that returns the table.
	-- format_after_save = {
	-- 	lsp_format = "fallback",
	-- },
	log_level = vim.log.levels.ERROR,
	notify_on_error = true,
	notify_no_formatters = true,
})

-- -- You can set formatters_by_ft and formatters directly
-- require("conform").formatters_by_ft.lua = { "stylua" }
-- require("conform").formatters.my_formatter = {
-- 	command = "my_cmd",
-- }
