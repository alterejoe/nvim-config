local CurlAttributes = function(buffer)
	local parser = vim.treesitter.get_parser(buffer, "customhttp")
	local tree = parser:parse()[1]:root()
	local row, col = vim.api.nvim_win_get_cursor(0)
	local node = tree:descendant_for_range(row, col, row, col)

	while node and node:type() ~= "request" do
		node = node:parent()
	end

	if not node then
		print("No request node found")
		return
	end

	command = "curl -s -i "
	local method = ""
	local url = ""
	local headers = {}
	local body = ""

	for child in node:iter_children() do
		local childtype = child:type()
		print("Child type: " .. childtype)
		if childtype == "method" then
			method = vim.treesitter.get_node_text(child, buffer)
		elseif childtype == "url" then
			url = vim.treesitter.get_node_text(child, buffer)
		elseif childtype == "header" then
			local header = vim.treesitter.get_node_text(child, buffer)
			header = '-H "' .. header .. '"'
			table.insert(headers, header)
		elseif childtype == "body" then
			local text = vim.treesitter.get_node_text(child, buffer)
			text = text:gsub("\n", "")
			text = text:gsub("\r", "")
			text = text:gsub("\t", "")
			body = "-d '" .. text .. "'"
		end
	end
end
