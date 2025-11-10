local osc52 = require("vim.ui.clipboard.osc52")
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Send yank to Windows clipboard using OSC52",
	callback = function()
		local ev = vim.v.event

		if ev.operator ~= "y" then
			return
		end -- only on yank

		-- osc52.copy expects a LIST (table of lines)
		local lines = ev.regcontents -- ← already a table

		require("vim.ui.clipboard.osc52").copy("+")(lines)
	end,
})
