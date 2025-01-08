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
vim.filetype.add({
	extension = {
		templ = "templ",
	},
})

lspconfig["gopls"].setup({
	capabilities = capabilities,
	filetypes = { "go", "templ", "html" },
})

--tailwindcss
lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	filetypes = { "templ" },
	--  trigger on class attribute
	settings = {
		tailwindCSS = {
			classAttributes = { "class" },
		},
	},
})

lspconfig["sqlls"].setup({
	capabilities = capabilities,
	filetypes = { "sql" },
})

lspconfig["emmet_language_server"].setup({
	capabilities = capabilities,
	filetypes = { "html", "templ" },
})

lspconfig["templ"].setup({
	capabilities = capabilities,
	filetypes = { "templ" },
	cmd = { "templ", "lsp" },
})

lspconfig["html"].setup({
	capabilities = capabilities,
	filetypes = { "html", "template" },
})

-- markdown - marksman
lspconfig["marksman"].setup({
	capabilities = capabilities,
	filetypes = { "markdown" },
})

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

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

-- godot configuration
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap = true, silent = true, buffer = bufnr }
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
	vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
	vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
	vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set("n", "<space>wl", function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
	vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
	vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
	vim.keymap.set("n", "<space>f", function()
		vim.lsp.buf.format({ async = true })
	end, bufopts)

	local _notify = client.notify

	client.notify = function(method, params)
		if method == "textDocument/didClose" then
			-- Godot doesn't implement didClose yet
			return
		end
		_notify(method, params)
	end
end

-- LSP Config for Godot

local lsp_flags = {
	-- This is the default in Nvim 0.7+
	debounce_text_changes = 50,
}

require("lspconfig").gdscript.setup({
	on_attach = on_attach,
	flags = lsp_flags,
	filetypes = { "gd", "gdscript", "gdscript3" },
})
