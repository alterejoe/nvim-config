local conform = require("conform")

conform.setup({
	formatters = {},
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "autopep8" },
		go = { "goimports" },
		vimwiki = { "prettier" },
		-- ["*"] = { "codespell" },
		-- -- Use the "_" filetype to run formatters on filetypes that don't
		-- -- have other formatters configured.
		-- ["_"] = { "trim_whitespace" },
	},
	default_formatters = { "efm" },
})

require("conform").formatters.prettier = {
	options = {
		ft_parsers = {
			vimwiki = "markdown",
		},
	},
}

vim.api.nvim_create_augroup("ConformAutogroup", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "ConformAutogroup",
	pattern = "*",
	callback = function()
		conform.format()
	end,
})
