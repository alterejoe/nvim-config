vim.api.nvim_set_keymap("n", "<Leader>ff", ":Files<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>fg', ':GFiles<CR>', { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<Leader>fb', ':Buffers<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>fg", ":Ag<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>fl", ":Lines<CR>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("n", "<Leader>ft", ":Tags<CR>", { noremap = true, silent = true })
