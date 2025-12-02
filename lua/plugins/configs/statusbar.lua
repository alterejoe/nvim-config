-- Active/Inactive colors
local hl_active = {
	cwd = { fg = "black", bg = "green", style = "bold" },
	file = { fg = "white", bg = "blue", style = "bold" },
	gowork = { fg = "black", bg = "yellow", style = "bold" },
}

local hl_inactive = {
	cwd = { fg = "#444444", bg = "#222222" },
	file = { fg = "#666666", bg = "#333333" },
	gowork = { fg = "#444444", bg = "#222200" },
}

-- Helper to choose active/inactive hls cleanly
local function hl_pick(active_hl, inactive_hl)
	local this = vim.fn.win_getid()
	local active = vim.api.nvim_get_current_win()
	return (this == active) and active_hl or inactive_hl
end

-- Find go.work root by walking upwards
local function find_go_work_root(start)
	local dir = start
	while dir ~= "/" do
		if vim.fn.filereadable(dir .. "/go.work") == 1 then
			return dir
		end
		dir = vim.fn.fnamemodify(dir, ":h")
	end
	return nil
end

-- Components used for BOTH active + inactive
local left_components = {
	-- cwd
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

	-- filename or oil folder
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
		active = {
			left_components,
			{},
			right_components,
		},
		inactive = {
			left_components,
			{},
			right_components,
		},
	},
})
