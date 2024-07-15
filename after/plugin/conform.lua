local conform = require("conform")

conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
	},
	default_formatters = { "efm" },
})

vim.api.nvim_create_augroup("ConformAutogroup", {})
vim.api.nvim_create_autocmd("BufWritePre", {
	group = "ConformAutogroup",
	pattern = "*",
	callback = function()
		conform.format()
	end,
})
