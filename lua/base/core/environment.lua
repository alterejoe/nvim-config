local function set_python_path()
	local cwd = vim.fn.getcwd()
	local python_path

	if cwd:match("zigbee") then
		python_path = "/home/jmeyer/miniconda3/envs/zigbee/bin/python"
		-- elseif cwd:match("") then
		-- 	python_path = "/path/to/project2/venv/bin/python"
	else
		python_path = "/home/jmeyer/miniconda3/bin/python"
	end

	-- print("Setting python path to: " .. python_path)
	vim.g.python3_host_prog = python_path
end

vim.api.nvim_create_augroup("SetPythonPath", { clear = true })
vim.api.nvim_create_autocmd("DirChanged", {
	group = "SetPythonPath",
	callback = set_python_path,
})
