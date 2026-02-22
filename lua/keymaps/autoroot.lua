vim.keymap.set("n", "<leader>1", function()
	-- this will be a function to set cwd to root ~/
	vim.fn.chdir("~")
	print("Changed directory to ~")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>!", function()
	-- this will be a function to set cwd to root ~/
	vim.cmd("Oil ~")
	print("Changed directory to ~")
end, { noremap = true, silent = true })

local patterns = { ".git", "config.lua", ".env", "Makefile", "go.mod" }

local juststarting = true
local notify = require("notify")
ClosestPattern = function(cwd, times, max)
	if cwd == "." then
		print("Reached root dir")
		return
	end

	local files = vim.fn.readdir(cwd)

	for _, pattern in ipairs(patterns) do
		for _, file in ipairs(files) do
			if file == pattern then
				vim.fn.chdir(cwd)
				print("Changed directory to " .. cwd)
				-- notify

				return
			end
		end
	end
	local parent = vim.fn.fnamemodify(cwd, ":h")
	times = times + 1
	if times > max then
		return
	end
	ClosestPattern(parent, times, max)
end

vim.keymap.set("n", "<leader>2", function()
	-- this will set the cwd to the closest pattern
	local filepath = vim.api.nvim_buf_get_name(0)
	local filedir = vim.fn.fnamemodify(filepath, ":h")

	if string.find(filedir, "oil://") then
		filedir = string.gsub(filedir, "oil://", "")
	end
	vim.fn.chdir(filedir)
	ClosestPattern(filedir, 0, 10)
	-- print("Changed directory to " .. filedir)
end, { noremap = true, silent = true })

vim.keymap.set("n", "<leader>3", function()
	-- this will set the cwd to the closest pattern
	local filepath = vim.api.nvim_buf_get_name(0)
	local filedir = vim.fn.fnamemodify(filepath, ":h")
	print("filedir: ", filedir)
	if string.find(filedir, "oil://") then
		filedir = string.gsub(filedir, "oil://", "")
	end
	vim.fn.chdir(filedir)
	print("Changed directory to " .. filedir)
end, { noremap = true, silent = true })

-- up a single dir
vim.keymap.set("n", "<leader>4", function()
	-- this will set the cwd to the closest pattern
	local currentdir = vim.fn.getcwd()
	local uponedir = vim.fn.fnamemodify(currentdir, ":h")
	print("filedir: ", uponedir)
	if string.find(uponedir, "oil://") then
		uponedir = string.gsub(uponedir, "oil://", "")
	end
	vim.fn.chdir(uponedir)
	print("Changed directory to " .. uponedir)
end, { noremap = true, silent = true })

-- leader 5: root to project root (where go.work lives)
vim.keymap.set("n", "<leader>5", function()
	local filepath = vim.api.nvim_buf_get_name(0)
	local filedir = vim.fn.fnamemodify(filepath, ":h")
	if string.find(filedir, "oil://") then
		filedir = string.gsub(filedir, "oil://", "")
	end

	local function rootToGoWork(cwd, depth, max)
		if cwd == "." then
			print("Reached root dir, no go.work found")
			return
		end
		local files = vim.fn.readdir(cwd)
		for _, file in ipairs(files) do
			if file == "go.work" or file == "root.lua" then
				vim.fn.chdir(cwd)
				print("Changed directory to project root: " .. cwd)
				return true
			end
		end
		if depth >= max then
			return
		end
		local parent = vim.fn.fnamemodify(cwd, ":h")
		return rootToGoWork(parent, depth + 1, max)
	end

	if not rootToGoWork(filedir, 0, 10) then
		print("No go.work found up the tree")
	end
end, { noremap = true, silent = true })
