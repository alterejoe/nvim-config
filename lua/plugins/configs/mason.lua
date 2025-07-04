local mason = require("mason")
mason.setup()

local masontoolinstaller = require("mason-tool-installer")
masontoolinstaller.setup({
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
