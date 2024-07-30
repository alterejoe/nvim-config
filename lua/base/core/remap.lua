vim.api.nvim_set_keymap("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })

-- vim.api.nvim_set_keymap("t", "JK", "<C-\\><C-n>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "JK", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "Q", function()
	local buftype = vim.bo.buftype
	local bufname = vim.fn.expand("%:t")
	print("buftype", buftype)
	if bufname == "output" then
		vim.api.nvim_command("q!")
	end

	local function writeSave()
		vim.api.nvim_command("wq")
	end

	if buftype == "" then
		if pcall(writeSave) then
			print("Written and Quit")
		else
			local filename = vim.fn.expand("%:t")
			if filename == "" then
				vim.api.nvim_command("q!")
			else
				vim.api.nvim_command("q")
			end
		end
	elseif buftype == "terminal" then
		print("quitting terminal")
		-- start insert mode
		vim.api.nvim_command("startinsert")
		-- send <C-c> to potentially stop any running process
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, true, true), "i", false)

		-- term codes "<C-\\><C-n>"
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "n", true)
		vim.api.nvim_command("bd!")
	else --if vim.fn.winnr("$") == 1 or buftype == "dbout" then
		vim.api.nvim_command("q")
	end
end)

vim.keymap.set("n", "W", function()
	local buftype = vim.bo.buftype
	local acceptyedbuf = { "", "acwrite" }
	if vim.fn.index(acceptyedbuf, buftype) ~= -1 then
		vim.api.nvim_command("w")
		print("Written", os.time())
	else
		print("Buftype is", buftype, "so not writing", os.time())
	end
end)

vim.keymap.set("n", "<leader>e", function()
	vim.api.nvim_command("Oil")
	-- <c-p> to open preview every time
end)

vim.keymap.set("n", "<leader>x", function()
	vim.api.nvim_command("source %")
	-- print("Sourced", os.time())
end)
