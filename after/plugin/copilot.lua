vim.keymap.set("n", "<leader>co", function()
	-- Copilot !toggle
	-- true if not initialized
	if vim.g.copilot_enabled == nil then
		vim.g.copilot_enabled = true
	else
		vim.g.copilot_enabled = not vim.g.copilot_enabled
	end

	if vim.g.copilot_enabled then
		vim.api.nvim_command("Copilot! attach")
		print("Copilot attached")
	else
		vim.api.nvim_command("Copilot! detach")
		print("Copilot detached")
	end

	vim.api.nvim_command("Copilot status")
end)
