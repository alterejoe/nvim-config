local notespath = "~/Notes/_fleeting.md"
vim.keymap.set("n", "<leader>nn", function()
	if not vim.loop.fs_stat(notespath) then
		notespath = "~/notes/_fleeting.md"
	end
	vim.api.nvim_command("e " .. notespath)
end, { noremap = true, silent = true })
