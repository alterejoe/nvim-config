function root(currentfilepath, skip)
	print("Current path: " .. currentfilepath)
	local originalfilepath = currentfilepath
	local patterns = { ".git/", "config.lua", ".env/", "index.norg" }
	-- if skip nil
	skip = skip or false
	while true do
		-- if patterns are found in the current directory then set the root to that directory
		if not skip then
			for _, pattern in ipairs(patterns) do
				local patternpath = currentfilepath .. "/" .. pattern

				if vim.fn.isdirectory(patternpath) == 1 or vim.fn.filereadable(patternpath) == 1 then
					vim.fn.chdir(currentfilepath)
					print("Changed directory to " .. currentfilepath)
					return
				end
			end
		else
			skip = false
		end
		-- go up one directory
		currentfilepath = vim.fn.fnamemodify(currentfilepath, ":h")
		-- go up one directory
		if currentfilepath == "/" then
			--set to original path
			vim.fn.chdir(originalfilepath)
			print("No patterns found, set to" .. originalfilepath)
			return
		end
	end
end

function fileroot(path)
	root(path, false)
end

function acwriteroot(path)
	-- remove oil:// from the start of the path
	local cleanpath = string.gsub(path, "oil://", "")
	root(cleanpath, false)
end

-- set cwd to root project of the current file  with <C-2>
vim.keymap.set("n", "<leader>2", function()
	local buffertype = vim.api.nvim_buf_get_option(0, "buftype")
	if buffertype == "terminal" then
		-- get the current directory of the terminal
		local term_dir = vim.loop.cwd()
		root(term_dir, false)
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
vim.keymap.set("n", "<leader>1", function()
	vim.fn.chdir("~")
	print("Set cwd to ~/")
end)

-- set cwd to current file directory with <C-3>
vim.keymap.set("n", "<leader>3", function()
	local filedir = vim.fn.expand("%:p:h")
	-- i oil:// in the start of the path
	if string.find(filedir, "oil://") then
		filedir = string.gsub(filedir, "oil://", "")
	end

	-- change cwd
	print("Changed directory to " .. filedir)
	vim.fn.chdir(filedir)
end)

-- ignore the current directory and find the next project directory with <C-4>
vim.keymap.set("n", "<leader>4", function()
	local filedir = vim.fn.expand("%:p:h")
	-- i oil:// in the start of the path
	if string.find(filedir, "oil://") then
		filedir = string.gsub(filedir, "oil://", "")
	end

	-- change cwd
	print("Changed directory to " .. filedir)
	vim.fn.chdir(filedir)
	filedir = vim.fn.fnamemodify(filedir, ":h")
	root(filedir, true)
end)
