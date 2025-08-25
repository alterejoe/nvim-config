local notespath = "~/Notes/_fleeting.md"
vim.keymap.set("n", "<leader>nn", function()
	-- if TODO.md or todo.md in root
	if vim.fn.filereadable("TODO.md") == 1 then
		notespath = vim.fn.getcwd() .. "/TODO.md"
	elseif vim.fn.filereadable("todo.md") == 1 then
		notespath = vim.fn.getcwd() .. "/todo.md"
	end

	if not vim.loop.fs_stat(notespath) then
		notespath = "~/notes/_fleeting.md"
	end
	vim.api.nvim_command("e " .. notespath)
end, { noremap = true, silent = true })
