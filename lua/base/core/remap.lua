vim.api.nvim_set_keymap("t", "jk", "<C-\\><C-n>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "nm", "<Esc>", { noremap = true, silent = true })

-- vim.api.nvim_set_keymap("t", "JK", "<C-\\><C-n>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap("i", "JK", "<Esc>", { noremap = true, silent = true })

vim.keymap.set("n", "Q", function()
	local buftype = vim.bo.buftype
	local bufname = vim.fn.expand("%:t")

	if bufname == "output" then
		-- vim.api.nvim_command("q!")
		-- close the buffer without saving
		local bufnumber = vim.fn.bufnr("%")
		vim.api.nvim_buf_delete(bufnumber, { force = true })

		-- vim.api.nvim_command("bd!")
		return
	end
	print("buftype for oil nvim", buftype)
	local function writeSave()
		vim.api.nvim_command("wq")
	end

	local dapfile = { "dap-repl", "dapui_breakpoints", "dapui_scopes" }
	print("Buffer type", buftype)
	if buftype == "acwrite" then
		vim.api.nvim_command("q")
	elseif buftype == "prompt" then
		vim.api.nvim_command("q!")
	elseif buftype == "" then
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
	elseif vim.fn.index(dapfile, vim.bo.filetype) ~= -1 then
		print("Closing dap file")
		CloseDap()
	elseif buftype == "terminal" then
		print("quitting terminal")
		-- start insert mode
		vim.api.nvim_command("startinsert")
		-- send <C-c> to potentially stop any running process
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, true, true), "i", false)

		-- term codes "<C-\\><C-n>"
		-- vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, true, true), "n", true)
		vim.api.nvim_command("bd!")
		-- vim.api.nvim_command("q")
	else --if vim.fn.winnr("$") == 1 or buftype == "dbout" then
		vim.api.nvim_command("q")
	end
end)

vim.keymap.set("n", "W", function()
	local buftype = vim.bo.buftype
	local acceptyedbuf = { "", "acwrite" }
	if vim.fn.index(acceptyedbuf, buftype) ~= -1 then
		vim.api.nvim_command("w!")
		-- print("Written", os.time())
		-- else
		-- 	print("Buftype is", buftype, "so not writing", os.time())
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

vim.keymap.set("n", ">", function()
	-- replicate the comand f> in normal mode
	vim.api.nvim_command("normal! f>")
end)

vim.keymap.set("n", "<", function()
	-- replicate the comand f< in normal mode
	vim.api.nvim_command("normal! F<")
end)

vim.keymap.set("n", "X", function()
	for name, value in pairs(package.loaded) do
		if not name:match("^vim") then
			package.loaded[name] = nil
		end
	end

	-- reload nvim config
	vim.api.nvim_command("source $MYVIMRC")
end)

vim.keymap.set("n", "<Tab>m", ":!make<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-j>", function()
	-- ctrl ww
	vim.cmd("wincmd w")
end)

-- vim.keymap.set("n", "<C-o>", "<c-6>", { noremap = true, silent = true })

vim.keymap.set("n", "<M-o>", "<c-^>", { noremap = true, silent = true })

-- keymap with  tab e it will split a terminal to the right and type the words scrapy crawl vs_spider
vim.keymap.set(
	"n",
	"<Tab>e",
	":botright split term<CR>:term scrapy crawl vs_spider<CR>",
	{ noremap = true, silent = true }
)

vim.keymap.set("n", "<C-w>V", function()
	-- split horizontal
	vim.api.nvim_command("split")
end, { noremap = true, silent = true })
