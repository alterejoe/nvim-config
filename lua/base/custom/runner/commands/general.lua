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

function M.create(filetype, filepath)
	local cwd = vim.fn.getcwd()
	filepath = string.gsub(filepath, cwd, "")
	if cwd ~= "/" then
		filepath = "." .. filepath
	end
	print("Creating file: " .. filepath)

	if filetype == "python" then
		return "python3 " .. filepath
	elseif filetype == "lua" then
		return "lua " .. filepath
	elseif filetype == "go" then
		local folder = string.match(filepath, "(.+)/[^/]*$")
		print("Folder: " .. folder)
		return "go run " .. folder
	else
		return "echo 'No runner for this filetype'"
	end
end

return M
