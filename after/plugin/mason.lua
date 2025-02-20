-- local capabilities = require("cmp_nvim_lsp").default_capabilities()

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("mason").setup({
	-- ensure_installed = { "tree-sitter-cli", "efm", "gopls", "lua_ls" },
	ensure_installed = {
		"biome",
		"black",
		"codelldb",
		"cpptools",
		"debugpy",
		"delve",
		"emmet-language-server",
		"eslint-lsp",
		"gdtoolkit",
		"go-debug-adapter",
		"goimports",
		"gopls",
		"html-lsp",
		"jsonnetfmt",
		"lua-language-server",
		"marksman",
		"prettier",
		"prettierd",
		"pyright",
		"sqlfmt",
		"sqlls",
		"stylua",
		"tailwindcss-language-server",
		"templ",
		"typescript-language-server",
	},
})
