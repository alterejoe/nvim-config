local lspconfig = require("lspconfig")
---
local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)

local function setup_lsp_server(server_name, config)
	lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
		capabilities = capabilities,
	}, config))
end

local function add_file_type(filetype, ext)
	vim.filetype.add({
		extension = {
			[ext] = filetype,
		},
	})
end

add_file_type("templ", "templ")

setup_lsp_server("templ", {
	filetypes = { "templ" },
	cmd = { "templ", "lsp" },
})

setup_lsp_server("ts_ls", {
	filetypes = { "typescript", "typescriptreact", "javascript" },
})

setup_lsp_server("html", {
	filetypes = { "html", "template" },
})

setup_lsp_server("pyright", {})

setup_lsp_server("lua_ls", {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
		},
	},
})

setup_lsp_server("tailwindcss", {
	filetypes = { "templ" },
	settings = {
		tailwindCSS = {
			classAttributes = { "class" },
			experimental = {
				classRegex = {
					"(?<=class=[\"'`])[^\"'\\s]+",
					[[(?<=Class:%s*")[^"]+]],
				},
			},
		},
	},
})

setup_lsp_server("sqlls", {
	filetypes = { "sql" },
})

setup_lsp_server("emmet_language_server", {
	filetypes = { "html", "templ" },
})

setup_lsp_server("gopls", {
	filetypes = { "go", "templ" },
	settings = {
		templateExtensions = {
			"templ",
		},
	},
})

setup_lsp_server("marksman", {
	filetypes = { "markdown" },
})
