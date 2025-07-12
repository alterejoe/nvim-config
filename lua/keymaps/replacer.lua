function StandardReplacer()
	-- keep false as this causes issues with bqf
	local opts = { save_on_write = false, rename_files = true }
	local replacer = require("replacer")
	return opts, replacer
end

local opts, replacer = StandardReplacer()

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
