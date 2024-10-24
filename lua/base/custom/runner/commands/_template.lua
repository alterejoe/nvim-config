print("General commands")

local M = {}

function M.create(filename)
	print("Creating command for: " .. filename)
	return "echo 'No runner for this filetype'"
end

return M
