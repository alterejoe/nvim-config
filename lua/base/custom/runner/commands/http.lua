local M = {}

function M.create(bufnr)
	local parser = vim.treesitter.get_parser(bufnr, "customhttp")
	local tree = parser:parse()[1]
	if not tree then
		return
	end
	local node = tree:root()
	-- print(vim.inspect(tree))
	-- for i in child count
	local command = "curl -i  -s -L "

	local request = nil
	local closestRequest = nil
	local cursorpos = vim.api.nvim_win_get_cursor(0)
	for child in node:iter_children() do
		-- print(child:type())
		if child:type() == "request" then
			local position = child:range()
			local distance = math.abs(position - cursorpos[1])
			if not closestRequest or distance < closestRequest then
				closestRequest = distance
				request = child
			end
		end
	end
	for c in request:iter_children() do
		print(c:type())
		if c:type() == "method" then
			method = vim.treesitter.get_node_text(c, bufnr)
			if not method then
				error("Method not found")
			end

			command = command .. "-X " .. method .. " "
		elseif c:type() == "url" then
			url = vim.treesitter.get_node_text(c, bufnr)
			if not url then
				error("Path not found")
			end
			command = command .. url .. " "
		elseif c:type() == "header" then
			local text = vim.treesitter.get_node_text(c, bufnr)
			print("Headers", text)
			command = command .. "-H " .. text .. " "
		elseif c:type() == "body" then
			body = vim.treesitter.get_node_text(c, bufnr)
			if not body then
				--continue
				body = ""
			end
			body = string.gsub(body, '"', "'") -- replace double quotes with single quotes
			body = string.gsub(body, "\n", "") -- remove newlines
			body = string.gsub(body, "\t", "") -- remove tabs
			body = string.gsub(body, " ", "") -- remove spaces
			command = command .. "-d '" .. body .. "' "
		end
	end
	return command
end

return M
