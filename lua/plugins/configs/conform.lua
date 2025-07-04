local conform = require("conform")
-----prettier------
-- if you want a specific parser for a filetype set it in the .prettierrc file NOT here
-------------------

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		go = { "goimports" },
		vimwiki = { command = "prettierd", args = { "--markdown-unordered-list-marker", "*" } },
		-- json = { "jq" },
		-- javascript = { "biome" },
		javascript = { "biome" },
		templ = { command = { "templ", "fmt", "." } },
		-- template = { "gohtml" },
		-- template = { "prettierd" },
		json = { "prettierd" },
		typescript = { "prettierd" },
		html = { "prettierd" },
		gdscript = { "gdformat" },
		-- sql = { "sqlfmt" },
	},
	filter = function()
		return true
	end,
	["*"] = { "codespell" },
	-- -- Use the "_" filetype to run formatters on filetypes that don't
	-- -- have other formatters configured.
	format_on_save = {
		-- These options will be passed to conform.format()
		timeout_ms = 500,
		lsp_format = "fallback",
	},
})

conform.formatters.jsonnetfmt = {
	options = {
		args = { "--string-style", "d", "--indent", "4" },
	},
}
