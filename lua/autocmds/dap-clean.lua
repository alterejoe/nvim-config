vim.api.nvim_create_autocmd("BufWinEnter", {
	pattern = "*",
	callback = function(args)
		local bufnr = args.buf
		local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
		if ft == "dap-view-term" then
			vim.schedule(function()
				vim.api.nvim_buf_delete(bufnr, { force = true })
			end)
		end
	end,
})
