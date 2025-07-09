local replacer = require("replacer")
vim.keymap.set("n", "W", function()
	local buftype = vim.bo.buftype
	local acceptyedbuf = { "", "acwrite", "quickfix" }
	if vim.fn.index(acceptyedbuf, buftype) ~= -1 then
		if buftype == "quickfix" then
			replacer.save()
		else
			vim.api.nvim_command("w!")
		end
		-- print("Written", os.time())
		-- else
		-- 	print("Buftype is", buftype, "so not writing", os.time())
	end
end)
