local grapple = require("grapple")
local scope_type = "cwd"

vim.keymap.set("n", "<leader>a", function()
	grapple.toggle({ scope = scope_type })
end)

vim.keymap.set("n", "<M-e>", function()
	require("telescope").extensions.grapple.tags({ scope = scope_type })
end)

vim.keymap.set("n", "<c-e>", function()
	grapple.toggle_tags({ scope = scope_type })
end)

vim.keymap.set("n", "<leader>j", function()
	grapple.select({ index = 1, scope = scope_type })
end, { desc = "Select first tag" })

vim.keymap.set("n", "<leader>k", function()
	grapple.select({ index = 2, scope = scope_type })
end, { desc = "Select second tag" })

vim.keymap.set("n", "<leader>l", function()
	grapple.select({ index = 3, scope = scope_type })
end, { desc = "Select third tag" })

vim.keymap.set("n", "<leader>;", function()
	grapple.select({ index = 4, scope = scope_type })
end, { desc = "Select fourth tag" })

vim.keymap.set("n", "<leader>J", function()
	grapple.select({ index = 5, scope = scope_type })
end, { desc = "Select first tag" })

vim.keymap.set("n", "<leader>K", function()
	grapple.select({ index = 6, scope = scope_type })
end, { desc = "Select second tag" })

vim.keymap.set("n", "<leader>L", function()
	grapple.select({ index = 7, scope = scope_type })
end, { desc = "Select third tag" })

vim.keymap.set("n", "<leader>:", function()
	grapple.select({ index = 8, scope = scope_type })
end, { desc = "Select fourth tag" })

vim.keymap.set("n", "<c-n>", function()
	grapple.cycle_tags({ direction = "next", scope = scope_type })
end, { desc = "Go to next tag" })

vim.keymap.set("n", "<c-m>", function()
	grapple.cycle_tags({ direction = "prev", scope = scope_type })
end, { desc = "Go to previous tag" })
