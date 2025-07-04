vim.keymap.set("n", "<leader>a", "<cmd>Grapple toggle<cr>", { desc = "Tag a file" })
vim.keymap.set("n", "<c-e>", "<cmd>Grapple toggle_tags<cr>", { desc = "Toggle tags menu" })

vim.keymap.set("n", "<leader>j", "<cmd>Grapple select index=1<cr>", { desc = "Select first tag" })
vim.keymap.set("n", "<leader>k", "<cmd>Grapple select index=2<cr>", { desc = "Select second tag" })
vim.keymap.set("n", "<leader>l", "<cmd>Grapple select index=3<cr>", { desc = "Select third tag" })
vim.keymap.set("n", "<leader>;", "<cmd>Grapple select index=4<cr>", { desc = "Select fourth tag" })
vim.keymap.set("n", "<leader>J", "<cmd>Grapple select index=5<cr>", { desc = "Select first tag" })
vim.keymap.set("n", "<leader>K", "<cmd>Grapple select index=6<cr>", { desc = "Select second tag" })
vim.keymap.set("n", "<leader>L", "<cmd>Grapple select index=7<cr>", { desc = "Select third tag" })
vim.keymap.set("n", "<leader>:", "<cmd>Grapple select index=8<cr>", { desc = "Select fourth tag" })

vim.keymap.set("n", "<c-n>", "<cmd>Grapple cycle_tags next<cr>", { desc = "Go to next tag" })
vim.keymap.set("n", "<c-m>", "<cmd>Grapple cycle_tags prev<cr>", { desc = "Go to previous tag" })
