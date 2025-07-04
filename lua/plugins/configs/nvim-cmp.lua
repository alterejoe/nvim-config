local cmp = require("cmp")
local mappings

cmp.setup({
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
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
		["<tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
		["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
	}),
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = "luasnip" }, -- For luasnip users.
		{ name = "buffer" },
		{ name = "path" },
		{ name = "treesitter" },
		-- { name = "codium" },
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
			end
			return vim_item
		end,
	},
})

cmp.setup.filetype("gitcommit", {
	sources = cmp.config.sources({
		{ name = "git" },
	}, {
		{ name = "buffer" },
	}),
})

require("cmp_git").setup()

cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
	matching = { disallow_symbol_nonprefix_matching = false },
})
