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
