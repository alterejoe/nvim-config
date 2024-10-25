local M = {}
-- function M.bufferExists(bufnr)
-- 	return vim.api.nvim_buf_is_valid(bufnr)
-- end

function M.kill(bufnr)
	if M.bufferExists(bufnr) then
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end
end

function M.create(command)
	local buffer = vim.api.nvim_create_buf(false, true)
	M.showBuffer(buffer)

	return buffer
end

function M.bufferIsVisible(bufnr)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			return true
		end
	end
	return false
end

function M.showBuffer(bufnr)
	if not M.bufferIsVisible(bufnr) then
		vim.api.nvim_command("botright vsplit")
		vim.api.nvim_command("buffer " .. bufnr)
		vim.api.nvim_command("wincmd p")
	else
		print("Buffer is already visible")
	end
end

return M
