vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<leader>zf",
	"<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>",
	{ noremap = true, silent = true }
)
