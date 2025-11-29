vim.keymap.set("n", "<leader><leader>e", function()
	local cmd = "Oil" .. " " .. vim.fn.getcwd()
	vim.api.nvim_command(cmd)
end)
