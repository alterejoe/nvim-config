local cmp = require("cmp")

-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..

-- An example for configuring `clangd` LSP to use nvim-cmp as a completion engine
-- require('lspconfig').clangd.setup {
--   capabilities = capabilities,
--   ...  -- other lspconfig configs
-- }
cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			-- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.

			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			-- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		-- completion = cmp.config.window.bordered(),
		-- documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-space>"] = cmp.mapping.complete(),
		["<esc>"] = cmp.mapping.abort(),
		["<Tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },

		-- { name = "copilot" },
		{ name = "luasnip" }, -- For luasnip users.
		{ name = "buffer" },
		{ name = "path" },
		{ name = "treesitter" },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- Apply only for Markdown files
			local completion_item = entry:get_completion_item()
			if vim.bo.filetype == "markdown" and completion_item then
				if completion_item.detail == nil then
					return vim_item
				end
				completion_item.textEdit.newText = "[[" .. completion_item.detail .. "]]"
				-- if entry.source.name == "nvim_lsp" then
				-- 	vim_item.abbr = completion_item.detail
				-- 	vim_item.word = completion_item.detail
				-- 	vim_item.insertText = completion_item.detail
				-- end
			end
			print(vim.inspect(vim_item))
			return vim_item
		end,
	},
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
	}, {
		{ name = "buffer" },
	}),
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})
