function AutoRoot()
	-- if there are no text files in the current directory then it is not a project
	-- we can get the current folders in the directory and if it one of the directories has the current
	-- file then we can set the root to that directory

	-- get the current directory
	local currentpath = vim.fn.expand("%:p")
	print("Current path: " .. currentpath)

	if vim.fn.isdirectory(currentpath) == 0 then
		currentpath = vim.fn.fnamemodify(currentpath, ":h")
	end

	local files_and_folders = vim.fn.readdir(currentpath)
	local cwd = vim.fn.getcwd()
	if currentpath == cwd then
		print("Already in root directory: " .. cwd)
		return
	end

	local lookfor = { ".git", "config.lua", ".env" }
	local count = 0
	while #files_and_folders ~= 0 do
		files_and_folders = vim.fn.readdir(currentpath)
		print("Looking at " .. currentpath)
		for _, file in ipairs(files_and_folders) do
			local filename = vim.fn.fnamemodify(file, ":t")

			-- if filename in lookfor then set root to currentpath
			for _, look in ipairs(lookfor) do
				if filename == look then
					vim.cmd("cd " .. currentpath)
					print("Changed directory to " .. currentpath)
					return
				end
			end
		end

		if currentpath == "/" then
			print("No root directory found")
			return
		end
		currentpath = vim.fn.fnamemodify(currentpath, ":h")
		count = count + 1
		if count >= 5 then
			print("No root directory found")
			return
		end
	end
end

function Autoroot_v2()
	local buffertype = vim.api.nvim_buf_get_option(0, "buftype")
	local buffername = vim.api.nvim_buf_get_name(0)

	local patterns = { ".git/", "config.lua", ".env/" }

	local currentfilepath = vim.fn.expand("%:p")
	print("Current path: " .. currentfilepath)
	while true do
		-- if patterns are found in the current directory then set the root to that directory
		for _, pattern in ipairs(patterns) do
			local patternpath = currentfilepath .. "/" .. pattern

			if vim.fn.isdirectory(patternpath) == 1 or vim.fn.filereadable(patternpath) == 1 then
				vim.api.nvim_command("cd " .. currentfilepath)
				print("Changed directory to " .. currentfilepath)
				return
			end
		end

		-- go up one directory
		currentfilepath = vim.fn.fnamemodify(currentfilepath, ":h")

		if currentfilepath == "/" then
			print("No root directory found")
			return
		end
	end
end

-- keybind for <leader>to use autodefault
vim.keymap.set("n", "<leader>1", function()
	Autoroot_v2()
end, { noremap = true, silent = true })

-- set cwd to ~  with <C-2>
vim.keymap.set("n", "<leader>2", function()
	vim.api.nvim_command("cd ~")
	print("Set cwd to ~/")
end)
