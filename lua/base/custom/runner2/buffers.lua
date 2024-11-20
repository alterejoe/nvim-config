local M = {}

M.active = {}

function M.is_visible(processname)
	return M.active[processname] ~= nil
end

function M.add(processname)
	local bufnr = vim.api.nvim_create_buf(false, true)
	M.active[processname] = bufnr
	-- autocmd for when it closes
	print("Buffernumber: " .. bufnr)
	vim.api.nvim_create_autocmd({ "BufDelete" }, {
		buffer = bufnr,
		callback = function()
			print("Buffer deleted")
			M.active[processname] = nil
			M.remove(processname)
		end,
	})
	return bufnr
end

function M.remove(processname)
	M.active[processname] = nil
end

return M
