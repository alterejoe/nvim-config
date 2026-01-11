local lspconfig = require("lspconfig")
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
	return nearest(fname, markers) or git_root(fname) or vim.loop.cwd()
end

local ROOT = {
	gopls = function(fname)
		-- go.work > go.mod > git > cwd
		return cwd_fallback(fname, { "go.work", ".git", "go.mod" })
	end,

	ts_ls = function(fname)
		-- prefer local ts/js project roots; avoid jumping to giant monorepo root
		return nearest(fname, { "tsconfig.json", "jsconfig.json", "package.json" }) or git_root(fname) or vim.loop.cwd()
	end,

	html = function(fname)
		return git_root(fname) or vim.loop.cwd()
	end,

	pyright = function(fname)
		return nearest(fname, { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".venv", "venv" })
			or git_root(fname)
			or vim.loop.cwd()
	end,

	lua_ls = function(fname)
		return nearest(fname, { ".luarc.json", ".luarc.jsonc" }) or git_root(fname) or vim.loop.cwd()
	end,

	tailwindcss = function(fname)
		return nearest(fname, {
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.cjs",
		}) or git_root(fname) or vim.loop.cwd()
	end,

	sqlls = function(fname)
		return nearest(fname, { ".sqls.yml", ".sqls.yaml" }) or git_root(fname) or vim.loop.cwd()
	end,

	emmet_language_server = function(fname)
		return git_root(fname) or vim.loop.cwd()
	end,

	marksman = function(fname)
		return nearest(fname, { ".marksman.toml" }) or git_root(fname) or vim.loop.cwd()
	end,

	templ = function(fname)
		-- tie templ to surrounding Go/JS/HTML project if present
		return nearest(fname, { "go.work", "go.mod", "package.json", ".git" }) or vim.loop.cwd()
	end,

	kulala_ls = function(fname)
		return git_root(fname) or vim.loop.cwd()
	end,

	__default = function(fname)
		return git_root(fname) or vim.loop.cwd()
	end,
}

local function root_for(server, fname)
	local f = ROOT[server] or ROOT.__default
	return f(fname)
end

-- ---------- factory ----------
local function setup_lsp_server(server_name, config)
	if not lspconfig[server_name] then
		vim.notify("LSP server not found: " .. server_name, vim.log.levels.ERROR)
		return
	end

	lspconfig[server_name].setup(vim.tbl_deep_extend("force", {
		capabilities = capabilities,
		root_dir = function(fname)
			return root_for(server_name, fname)
		end,
	}, config or {}))
end

-- ---------- filetype for templ ----------
local function add_file_type(filetype, ext)
	vim.filetype.add({ extension = { [ext] = filetype } })
end
add_file_type("templ", "templ")

-- ---------- servers (your list, unchanged where possible) ----------
setup_lsp_server("templ", {
	filetypes = { "templ" },
	cmd = { "templ", "lsp" },
})

setup_lsp_server("kulala_ls", {})

setup_lsp_server("ts_ls", {
	filetypes = { "typescript", "typescriptreact", "javascript" },
})

setup_lsp_server("html", {
	filetypes = { "html", "template" },
})

setup_lsp_server("pyright", {})

setup_lsp_server("lua_ls", {
	settings = {
		Lua = {
			completion = { callSnippet = "Replace" },
			diagnostics = { globals = { "vim" } },
		},
	},
})

setup_lsp_server("tailwindcss", {
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
})

setup_lsp_server("postgres_lsp", {
	filetypes = { "sql" },
})

setup_lsp_server("emmet_language_server", {
	filetypes = { "html", "templ" },
})

setup_lsp_server("gopls", {
	filetypes = { "go", "templ" },
	settings = { templateExtensions = { "templ" } },
})

setup_lsp_server("marksman", {
	filetypes = { "markdown" },
})

setup_lsp_server("terraformls", {
	filetypes = { "terraform", "tf" },
})
