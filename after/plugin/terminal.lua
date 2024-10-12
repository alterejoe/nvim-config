-- vim.keymap.set for <leader>st to open vsplit terminal to the right
vim.keymap.set("n", "<leader>st", function()
	SourceConfig()

	-- if python is conda env then get the name of the conda env
	if vim.g.python3_host_prog ~= nil then
		if vim.g.python3_host_prog:find("conda") then
			-- split at last / and get the last element
			-- condaname = vim.g.python3_host_prog
			condaname = vim.g.python3_host_prog:match("/envs/(.-)/bin/python")
		end
	end

	local pwd = vim.fn.getcwd()

	-- open terminal in the right split at the current working directory
	vim.cmd("rightbelow vsplit | terminal")

	-- go into insert mode
	vim.cmd("startinsert")
	-- feed the keys to the terminal
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("cd " .. pwd, true, false, true), "n", true)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)

	-- if conda env is present then activate it
	if condaname ~= nil then
		vim.api.nvim_feedkeys(
			vim.api.nvim_replace_termcodes("conda activate " .. condaname, true, false, true),
			"n",
			true
		)
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", true)
	end
end)
