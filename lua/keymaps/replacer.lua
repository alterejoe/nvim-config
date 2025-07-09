local opts = { save_on_write = false, rename_files = true }
local replacer = require("replacer")

vim.keymap.set("n", "i", function()
	if vim.bo.buftype == "quickfix" then
		replacer.run(opts)
	else
		vim.cmd("startinsert")
	end
end, { silent = true })

vim.keymap.set("n", "<leader>R", function()
	replacer.save(opts)
end, { silent = true })

-- vim.keymap.set("n", "<Leader>H", ':lua require("replacer").save(opts)<cr>', { silent = true })
