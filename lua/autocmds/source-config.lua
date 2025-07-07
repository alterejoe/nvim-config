local project_config_group = vim.api.nvim_create_augroup("ProjectConfigLoader", { clear = true })
vim.api.nvim_create_autocmd({ "DirChanged" }, {
	group = project_config_group,
	callback = function()
		local config_file = vim.fn.getcwd() .. "/config.lua"
		if vim.fn.filereadable(config_file) == 1 then
			local old_python = vim.g.python3_host_prog
			dofile(config_file)
			--
			-- local clients = vim.lsp.get_clients()
			-- for _, client in ipairs(clients) do
			-- 	if client.name == "pyright" then
			-- 		if client.settings then
			-- 			client.settings.python = vim.g.python3_host_prog
			-- 			vim.cmd("LspRestart " .. client.name)
			-- 		else
			-- 			print("No settings for pyright")
			-- 		end
			-- 	end
			-- end
			-- vim.notify("Loaded project config from: " .. config_file, vim.log.levels.INFO)
		end
	end,
	desc = "Load project-specific config.lua when changing directories",
})
