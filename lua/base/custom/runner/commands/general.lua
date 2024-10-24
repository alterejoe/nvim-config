print("General commands")

local M = {}

function M.inGeneral(filetype)
	local expected = { "python", "lua", "go" }
	for _, v in ipairs(expected) do
		if v == filetype then
			return true
		end
	end
	return false
end

function M.create(filetype, filename)
	if filetype == "python" then
		return "python3 " .. filename
	elseif filetype == "lua" then
		return "lua " .. filename
	elseif filetype == "go" then
		return "go run " .. filename
	else
		return "echo 'No runner for this filetype'"
	end
end

return M
