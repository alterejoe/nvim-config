-- Active/Inactive colors
local hl_active = {
	cwd = { fg = "black", bg = "green", style = "bold" },
	root = { fg = "black", bg = "magenta", style = "bold" },
	file = { fg = "white", bg = "blue", style = "bold" },
	gowork = { fg = "black", bg = "yellow", style = "bold" },
}
local hl_inactive = {
	cwd = { fg = "#444444", bg = "#222222" },
	root = { fg = "#555555", bg = "#222233" },
	file = { fg = "#666666", bg = "#333333" },
	gowork = { fg = "#444444", bg = "#222200" },
}

local function hl_pick(a, b)
	local this = vim.fn.win_getid()
	local active = vim.api.nvim_get_current_win()
	return (this == active) and a or b
end

-- Find "project root" for the *open buffer*
-- Rule: nearest parent containing `cmd/` or `config.lua`
-- Find "project root" for the *open buffer*
-- Rule: nearest parent containing `cmd/` or `config.lua`
local function find_buffer_root(filepath, is_directory)
	-- If filepath is already a directory (oil buffer), start from it
	-- Otherwise, get the file's directory
	local dir = is_directory and filepath or vim.fn.fnamemodify(filepath, ":h")

	while dir ~= "/" do
		-- Preferred patterns
		if vim.fn.isdirectory(dir .. "/cmd") == 1 then
			return dir
		end
		if vim.fn.filereadable(dir .. "/config.lua") == 1 then
			return dir
		end
		-- Fallback: .git/
		if vim.fn.isdirectory(dir .. "/.git") == 1 then
			return dir
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end
	return nil
end

-- Find go.work root
local function find_go_work_root(start)
	local dir = start
	while dir ~= "/" do
		if vim.fn.filereadable(dir .. "/go.work") == 1 then
			return dir
		end
		local parent = vim.fn.fnamemodify(dir, ":h")
		if parent == dir then
			break
		end
		dir = parent
	end
	return nil
end

-- Components used for BOTH active + inactive
local left_components = {
	-- 1. CWD - just the folder name
	{
		provider = function()
			return vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
		end,
		hl = function()
			return hl_pick(hl_active.cwd, hl_inactive.cwd)
		end,
		left_sep = "block",
		right_sep = "block",
	},
	-- 2. Path from CWD to buffer's project root
	{
		provider = function()
			local buf_path
			if vim.bo.filetype == "oil" then
				-- Oil buffers have names like "oil:///path/to/dir"
				-- Get the actual directory path
				buf_path = vim.fn.expand("%"):gsub("^oil://", "")
			else
				buf_path = vim.fn.expand("%:p")
			end

			-- Guard against empty/invalid paths
			if buf_path == "" or buf_path == "about:blank" then
				return ""
			end

			-- For oil, buf_path is already a directory; for files, we need the parent
			local is_oil = vim.bo.filetype == "oil"
			local root = find_buffer_root(buf_path, is_oil)
			if not root then
				return ""
			end

			local cwd = vim.fn.getcwd()
			-- Ensure both paths end without trailing slash for comparison
			cwd = cwd:gsub("/$", "")
			root = root:gsub("/$", "")

			-- If root is under cwd, show relative path
			if vim.startswith(root, cwd .. "/") then
				return root:sub(#cwd + 2) -- +2 to skip cwd and the /
			elseif root == cwd then
				return "." -- Root is the cwd itself
			else
				-- Root is outside cwd, just show the folder name
				return vim.fn.fnamemodify(root, ":t")
			end
		end,
		hl = function()
			return hl_pick(hl_active.root, hl_inactive.root)
		end,
		left_sep = "block",
		right_sep = "block",
	},
	{
		provider = function()
			if vim.bo.filetype == "oil" then
				return vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":t")
			end
			return vim.fn.expand("%:t")
		end,
		hl = function()
			return hl_pick(hl_active.file, hl_inactive.file)
		end,
		left_sep = "block",
		right_sep = "block",
	},
}

local right_components = {
	-- 4. Go.work root
	{
		provider = function()
			local root = find_go_work_root(vim.fn.getcwd())
			return root and (vim.fn.fnamemodify(root, ":t") .. " (go.work)") or ""
		end,
		hl = function()
			return hl_pick(hl_active.gowork, hl_inactive.gowork)
		end,
		left_sep = "block",
		right_sep = "block",
	},
}

require("feline").setup({
	components = {
		active = { left_components, {}, right_components },
		inactive = { left_components, {}, right_components },
	},
})
