local conform = require("conform")
-----prettier------
-- if you want a specific parser for a filetype set it in the .prettierrc file NOT here
-------------------

conform.setup({
	formatters = {},
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "autopep8" },
		go = { "goimports" },
		vimwiki = { command = "prettierd", args = { "--markdown-unordered-list-marker", "*" } },
		-- json = { "jq" },
		javascript = { "prettierd" },
		template = { "prettierd" },
		json = { "prettierd" },
	},
	-- ["*"] = { "codespell" },
	-- -- Use the "_" filetype to run formatters on filetypes that don't
	-- -- have other formatters configured.
	-- ["_"] = { "trim_whitespace" },
	default_formatters = { "efm" },
})

require("conform").formatters.prettierd = {
	options = {
		ft_parsers = {
			vimwiki = "markdown",
			template = "html",
		},
	},
}

require("conform").formatters.jsonnetfmt = {
	options = {
		args = { "--string-style", "d", "--indent", "4" },
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

-- autocommand for json files 	vim.cmd(":%!jq" .. personaPath .. personaFilename .. ".json")

-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	group = "ConformAutogroup",
-- 	pattern = "*.json",
-- 	callback = function()
-- 		vim.cmd(":%!jq")
-- 	end,
-- })
