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

function root(currentfilepath)
	print("Current path: " .. currentfilepath)

	local patterns = { ".git/", "config.lua", ".env/" }
	while true do
		-- if patterns are found in the current directory then set the root to that directory
		for _, pattern in ipairs(patterns) do
			local patternpath = currentfilepath .. "/" .. pattern

			if vim.fn.isdirectory(patternpath) == 1 or vim.fn.filereadable(patternpath) == 1 then
				vim.fn.chdir(currentfilepath)
				print("Changed directory to " .. currentfilepath)
				return
			end
		end

		-- go up one directory
		currentfilepath = vim.fn.fnamemodify(currentfilepath, ":h")
		print("Looking at " .. currentfilepath)
		if currentfilepath == "/" then
			print("No root directory found")
			return
		end
	end
end

function fileroot(path)
	root(path)
end

function acwriteroot(path)
	-- remove oil:// from the start of the path
	local cleanpath = string.gsub(path, "oil://", "")
	root(cleanpath)
end
-- keybind for <leader>to use autodefault
vim.keymap.set("n", "<leader>1", function()
	local buffertype = vim.api.nvim_buf_get_option(0, "buftype")
	if buffertype == "terminal" then
		-- get the current directory of the terminal
		local term_dir = vim.loop.cwd()
		root(term_dir)
		return
	end
	if buffertype == "acwrite" then
		local path = vim.api.nvim_buf_get_name(0)
		local pathdir = vim.fn.fnamemodify(path, ":h")
		acwriteroot(pathdir)
		return
	end
	local filedir = vim.fn.expand("%:p:h")
	fileroot(filedir)
end, { noremap = true, silent = true })

-- set cwd to ~  with <C-2>
vim.keymap.set("n", "<leader>2", function()
	vim.fn.chdir("~")
	print("Set cwd to ~/")
end)
