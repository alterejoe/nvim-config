-- Setup language servers.

local lspconfig = require("lspconfig")
---
local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)
---
---- installed lsp servers
lspconfig["pyright"].setup({})

lspconfig["lua_ls"].setup({
	diagnostics = {
		-- Get the language server to recognize the `vim` global
		globals = {
			"vim",
			"require",
		},
	},
})
-- lspconfig["tsserver"].setup({
-- 	capabilities = capabilities,
-- 	filetypes = {
-- 		"javascript",
-- 		"templ",
-- 		"javascriptreact",
-- 		"javascript.js",
-- 		"typescript",
-- 		"typescriptreact",
-- 		"typescript.ts",
-- 	},
-- })
-- lspconfig["rust_analyzer"].setup({ capabilities = capabilities })
-- lspconfig["gdscript"].setup({ capabilities = capabilities })
lspconfig["gopls"].setup({
	capabilities = capabilities,
	filetypes = { "go", "templ" },
})
-- lspconfig["typos_lsp"].setup({ capabilities = capabilities })
-- lspconfig["docker_compose_language_service"].setup({
-- 	capabilities = capabilities,
-- 	cmd = { "docker-compose-langserver", "--stdio" },
-- 	filetypes = { "yaml", "yml" },
-- 	rootdir = lspconfig.util.root_pattern("docker-compose.yaml", "docker-compose.prod.yaml", "docker-compose.dev.yaml"),
-- })
-- lspconfig["dockerls"].setup({
-- 	capabilities = capabilities,
-- 	cmd = { "docker-langserver", "--stdio" },
-- 	filetypes = { "Dockerfile", "dockerfile" },
-- 	root_dir = lspconfig.util.root_pattern("Dockerfile.dev", "Dockerfile.prod", "Dockerfile"),
-- })
--
-- lspconfig["templ"].setup({
-- 	capabilities = capabilities,
-- 	filetypes = { "templ" },
-- 	cmd = { "templ", "lsp" },
-- })

-- lspconfig["tailwindcss"].setup({ -- tailwind lsp requries there to be a tailwind.config.js file in the root of the project, will have to restart nvim to get it to work
--
-- 	capabilities = capabilities,
-- 	filetypes = { "css", "scss", "html", "templ" },
-- })
--
lspconfig["html"].setup({
	capabilities = capabilities,
	filetypes = { "html", "template" },
})
--
-- lspconfig["cssls"].setup({
-- 	capabilities = capabilities,
-- 	filetypes = { "css", "scss" },
-- 	cmd = { "vscode-css-language-server", "--stdio" },
-- })
--
-- -- lspconfig["unocss"].setup({
-- --
-- -- 	cmd = { "unocss-language-server", "--stdio" },
-- -- 	filetypes = { "html", "templ", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
-- -- 	root_dir = lspconfig.util.root_pattern(".git", ".env", "config.lua"),
-- -- })
-- lspconfig["clangd"].setup({
-- 	capabilities = capabilities,
-- 	cmd = { "clangd", "--background-index" },
-- 	filetypes = { "c", "cpp", "h", "hpp" },
-- })
--
-- lspconfig["cmake"].setup({
-- 	capabilities = capabilities,
-- 	filetypes = { "cmake" },
-- })
--
-- lspconfig["ansiblels"].setup({
-- 	capabilities = capabilities,
-- 	cmd = { "ansible-language-server", "--stdio" },
-- 	filetypes = { "yaml", "yml" },
-- 	-- root_dir = lspconfig.util.root_pattern("ansible.cfg"),
-- })

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
-- vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
-- vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("UserLspConfig", {}),
	callback = function(ev)
		-- Enable completion triggered by <c-x><c-o>
		vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local opts = { buffer = ev.buf }
		vim.keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "<leader>gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)
		vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
		vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)
	end,
})
