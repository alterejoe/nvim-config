vim.keymap.set("n", "<leader>gc", function()
	require("telescope").extensions.git_worktree.create_git_worktree()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
end, { desc = "Create worktree" })

vim.keymap.set("n", "<leader>gs", function()
	require("telescope").extensions.git_worktree.git_worktrees()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>", true, false, true), "n", true)
end, { desc = "Switch worktree" })
