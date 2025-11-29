local function YankCwdTree()
	local cmd = "tree -a" -- show all files, including hidden ones
	local handle = io.popen(cmd)
	if not handle then
		vim.notify("Failed to read directory", vim.log.levels.ERROR)
		return
	end

	local output = handle:read("*a")
	handle:close()

	if output == "" then
		vim.notify("No output from tree command", vim.log.levels.WARN)
		return
	end

	vim.fn.setreg("+", output)
	vim.notify("Full directory tree yanked to clipboard.")
end

vim.keymap.set("n", "<leader>yd", YankCwdTree, { desc = "Yank cwd directory tree" })
