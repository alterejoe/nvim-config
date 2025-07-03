vim.keymap.set("n", "Q", function()
	local buftype = vim.bo.buftype
	local filetype = vim.bo.filetype
	local bufname = vim.fn.expand("%:t")
	local buf = vim.api.nvim_get_current_buf()

	local dap_files = {
		dap_repl = true,
		dapui_breakpoints = true,
		dapui_scopes = true,
	}

	-- Close specific output buffer
	if bufname == "output" then
		vim.api.nvim_buf_delete(buf, { force = true })
		return
	end

	-- DAP special handling
	if dap_files[filetype] then
		CloseDap()
		return
	end

	-- Close terminals forcefully
	if buftype == "terminal" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, true, true), "i", false)
		vim.api.nvim_buf_delete(buf, { force = true })
		return
	end

	-- Prompt or acwrite types (no save needed)
	if buftype == "prompt" or buftype == "acwrite" then
		vim.cmd("q!")
		return
	end

	-- Normal file: try save & quit, else just quit
	if buftype == "" then
		local ok = pcall(vim.cmd, "wq")
		if not ok then
			vim.cmd(bufname == "" and "q!" or "q")
		end
		return
	end

	-- Fallback: just quit
	vim.cmd("q")
end, { desc = "Smart buffer close" })
