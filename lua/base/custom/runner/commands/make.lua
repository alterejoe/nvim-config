local M = {}

function M.create(bufnr)
	-- read buffer
	local parser = vim.treesitter.get_parser(bufnr, "make")
	local tree = parser:parse()[1]
	if not tree then
		return
	end
	local node = tree:root()
	print(vim.inspect(tree))
end

return M
