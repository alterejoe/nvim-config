local M = {}
function M.bufferExists(bufnr)
	return vim.api.nvim_buf_is_valid(bufnr)
end

function M.kill(bufnr)
	if M.bufferExists(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

function M.create(command)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(bufnr, command)
	return bufnr
end
return M
