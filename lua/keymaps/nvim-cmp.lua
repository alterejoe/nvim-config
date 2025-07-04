-- lua/keymaps/nvim-cmp.lua
local cmp = require("cmp")

local mappings = cmp.mapping.preset.insert({
	["<C-b>"] = cmp.mapping.scroll_docs(-4),
	["<C-f>"] = cmp.mapping.scroll_docs(4),
	["<C-space>"] = cmp.mapping.complete(),
	["<esc>"] = cmp.mapping.abort(),
	["<tab>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
	["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
})
