local plugin_configs = {}
-- local files = vim.fn.readdir(vim.fn.stdpath("config") .. "/lua/configs/") -- this will be for when nvim is in it's normal spot
local files = vim.fn.readdir("/home/altjoe/worktrees/nvim/lua/plugins/configs/")

-- remember that order of operations DOES matter here
require("paq")({
	"savq/paq-nvim", -- Let Paq manage itself

	-- mason first to install packages
	"williamboman/mason.nvim",
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	"williamboman/mason-lspconfig.nvim",
	-- luarocks first to install packages
	"vhyrro/luarocks.nvim",

	"kevinhwang91/nvim-bqf", -- better quickfix list search/replace/prettier
	"monkoose/neocodeium", -- neocodium for project context chat/suggesions from multiple model sources
	"sainnhe/gruvbox-material", -- color theme
	"numToStr/Comment.nvim", -- nicer comments gcc
	"stevearc/conform.nvim", -- formatter
	--
	-- dadbodui
	"kristijanhusak/vim-dadbod-ui",
	"tpope/vim-dadbod",
	"kristijanhusak/vim-dadbod-completion",
	"olrtg/nvim-emmet", -- quick html templating
	"ThePrimeagen/git-worktree.nvim",

	-- grapple
	"nvim-tree/nvim-web-devicons",
	"nvim-lua/plenary.nvim",
	"cbochs/grapple.nvim",

	"kdheepak/lazygit.nvim", -- simple github interface wrapper over cli

	"folke/neodev.nvim", -- this is for better lua/nvim integration and completions
	"neovim/nvim-lspconfig", -- lsp config

	-- nvim-cmp goes after lspconfig
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/nvim-cmp",
	"L3MON4D3/LuaSnip", -- lua snip engine required as source for nvim-cmp
	"saadparwaiz1/cmp_luasnip",
	"petertriho/cmp-git", -- git source for nvim-cmp

	-- nvim-dap debugger setup
	"mfussenegger/nvim-dap", -- dep
	"nvim-neotest/nvim-nio", -- dep
	"rcarriga/nvim-dap-ui",

	-- oil.nvim text editable file explorer
	"stevearc/oil.nvim",
	"echasnovski/mini.icons",

	"folke/snacks.nvim", -- nice simple tools to fill out nvim
	"feline-nvim/feline.nvim", -- nice status bar
	"lambdalisue/vim-suda", -- very helpful write sudo within underprivalaged nvim
	"mbbill/undotree", -- undo tree to see past changes and update

	-- telescope and extensions
	"nvim-telescope/telescope.nvim", -- telescope searching feature
	"nvim-telescope/telescope-fzf-native.nvim", -- fzf extension ext
	"d4wns-l1ght/telescope-messages.nvim", -- messages ext
	"smartpde/telescope-recent-files", -- recent files ext
	"nvim-telescope/telescope-frecency.nvim", -- frequent files ext

	-- treesitter for highlighting
	"nvim-treesitter/nvim-treesitter",
})

vim.cmd("PaqInstall")

-- require package installation first
require("plugins.configs.treesitter")
require("plugins.configs.mason")
require("plugins.configs.luarocks")
require("plugins.configs.colorscheme")

require("plugins.configs.bqf")
require("plugins.configs.conform")
require("plugins.configs.gitworktree")
require("plugins.configs.lsp-config")
require("plugins.configs.neocodeium")
require("plugins.configs.neodev")
require("plugins.configs.nvim-cmp")
require("plugins.configs.oil")

print("Plugins imported successfully")
