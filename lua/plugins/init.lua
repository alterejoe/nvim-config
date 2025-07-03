local plugin_configs = {}
local files = vim.fn.readdir("./configs/")

for _, file in ipairs(files) do
	if file:match("%.lua$") then
		local file_name = file:gsub("%.lua$", "")
		plugin_configs[file_name] = require("configs." .. file_name)
	end
end

print(plugin_configs)

require("paq")({
	"savq/paq-nvim", -- Let Paq manage itself
	"kevinhwang91/nvim-bqf", -- better quickfix window
})
