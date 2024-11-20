local M = {}

function M.nameExists(name)
	local cmd = "pm2 list"
	local handle = io.popen(cmd)
	local result = handle:read("*a")

	if result == nil then
		return false
	end

	for i, line in ipairs(vim.split(result, "\n")) do
		if string.find(line, " " .. name .. " ", 1, true) then
			return true
		end
	end
	handle:close()
end

return M
