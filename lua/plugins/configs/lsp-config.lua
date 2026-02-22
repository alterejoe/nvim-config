local util = require("lspconfig.util")

-- ---------- capabilities ----------
local capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)

-- ---------- root strategies ----------
local function nearest(fname, markers)
	return util.root_pattern(unpack(markers))(fname)
end

local function git_root(fname)
	return util.find_git_ancestor(fname)
end

local function cwd_fallback(fname, markers)
	return nearest(fname, markers) or git_root(fname) or vim.uv.cwd()
end

local ROOT = {
	gopls = function(fname)
		return cwd_fallback(fname, { "go.work", ".git", "go.mod" })
	end,
	ts_ls = function(fname)
		return nearest(fname, { "tsconfig.json", "jsconfig.json", "package.json" }) or git_root(fname) or vim.uv.cwd()
	end,
	html = function(fname)
		return git_root(fname) or vim.uv.cwd()
	end,
	pyright = function(fname)
		return nearest(fname, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".venv", "venv" })
			or git_root(fname)
			or vim.uv.cwd()
	end,
	lua_ls = function(fname)
		return nearest(fname, { ".luarc.json", ".luarc.jsonc" }) or git_root(fname) or vim.uv.cwd()
	end,
	tailwindcss = function(fname)
		return nearest(fname, {
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.cjs",
		}) or git_root(fname) or vim.uv.cwd()
	end,
	sqlls = function(fname)
		return nearest(fname, { ".sqls.yml", ".sqls.yaml" }) or git_root(fname) or vim.uv.cwd()
	end,
	emmet_language_server = function(fname)
		return git_root(fname) or vim.uv.cwd()
	end,
	marksman = function(fname)
		return nearest(fname, { ".marksman.toml" }) or git_root(fname) or vim.uv.cwd()
	end,
	templ = function(fname)
		return nearest(fname, { "go.work", "go.mod", "package.json", ".git" }) or vim.uv.cwd()
	end,
	kulala_ls = function(fname)
		return git_root(fname) or vim.uv.cwd()
	end,
	__default = function(fname)
		return git_root(fname) or vim.uv.cwd()
	end,
}

local function root_for(server, fname)
	local f = ROOT[server] or ROOT.__default
	return f(fname)
end

-- ---------- filetype for templ ----------
vim.filetype.add({ extension = { templ = "templ" } })

-- ---------- server configs ----------
local servers = {
	templ = {
		filetypes = { "templ" },
		cmd = { "templ", "lsp" },
	},
	kulala_ls = {},
	ts_ls = {
		filetypes = { "typescript", "typescriptreact", "javascript" },
	},
	html = {
		filetypes = { "html", "template" },
	},
	pyright = {},
	lua_ls = {
		settings = {
			Lua = {
				completion = { callSnippet = "Replace" },
				diagnostics = { globals = { "vim" } },
			},
		},
	},
	tailwindcss = {
		filetypes = { "templ" },
		settings = {
			tailwindCSS = {
				classAttributes = { "class" },
				experimental = {
					classRegex = {
						[[(?<=class=["'`])[^"'%s]+]],
						[[(?<=Class:%s*")[^"]+]],
					},
				},
			},
		},
	},
	postgres_lsp = {
		filetypes = { "sql" },
	},
	emmet_language_server = {
		filetypes = { "html", "templ" },
	},
	gopls = {
		filetypes = { "go", "templ" },
		settings = { templateExtensions = { "templ" } },
	},
	marksman = {
		filetypes = { "markdown" },
	},
	terraformls = {
		filetypes = { "terraform", "tf" },
	},
}

-- ---------- register and enable all servers ----------
for name, config in pairs(servers) do
	vim.lsp.config(
		name,
		vim.tbl_deep_extend("force", {
			capabilities = capabilities,
			root_dir = function(bufnr, on_dir)
				local fname = vim.api.nvim_buf_get_name(bufnr)
				on_dir(root_for(name, fname))
			end,
		}, config)
	)
end

vim.lsp.enable(vim.tbl_keys(servers))
