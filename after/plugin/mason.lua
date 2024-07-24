-- local capabilities = require("cmp_nvim_lsp").default_capabilities()

local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

require("mason").setup({
	ensure_installed = { "tree-sitter-cli", "efm", "gopls", "lua_ls" },
})

-- require("mason-lspconfig").setup()
-- require("mason-lspconfig").setup_handlers({
-- 	-- The first entry (without a key) will be the default handler
-- 	-- and will be called for each installed server that doesn't have
-- 	-- a dedicated handler.
-- 	function(server_name) -- default handler (optional)
-- 		require("lspconfig")[server_name].setup({})
-- 	end,
-- 	-- Next, you can provide a dedicated handler for specific servers.
-- 	-- For example, a handler override for the `rust_analyzer`:
-- 	-- ["rust_analyzer"] = function()
-- 	-- 	require("rust-tools").setup({})
-- 	-- end,
-- 	["lua_ls"] = function()
-- 		require("lspconfig")["lua_ls"].setup({
-- 			capabilities = capabilities,
-- 			settings = {
-- 				Lua = {
-- 					diagnostics = {
-- 						globals = { "vim" },
-- 					},
-- 				},
-- 			},
-- 		})
-- 	end,
-- 	["gopls"] = function()
-- 		require("lspconfig")["gopls"].setup({
-- 			capabilities = capabilities,
-- 			cmd = { "gopls", "serve" },
-- 			settings = {
-- 				gopls = {
-- 					analyses = {
-- 						unusedparams = true,
-- 					},
-- 					staticcheck = true,
-- 				},
-- 			},
-- 		})
-- 	end,
-- })
