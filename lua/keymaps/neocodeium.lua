local neocodeium = require("neocodeium")

vim.keymap.set("i", "<c-a>", neocodeium.accept)
vim.keymap.set("i", "<c-w>", neocodeium.accept_word)
-- vim.keymap.set("i", "A", neocodeium.accept_line)
vim.keymap.set("i", "<M-]>", neocodeium.cycle_or_complete)

-- leader>cc map to CodeiumChat
vim.keymap.set("n", "<leader>cc", function()
	vim.cmd(":NeoCodeium chat")
end, { noremap = true, silent = true })

-- vim.keymap.set("n", "<leader>co", function()
-- 	vim.cmd("NeoCodeium enable")
-- 	print("Neocodeium enabled")
-- end, { noremap = true, silent = true })
