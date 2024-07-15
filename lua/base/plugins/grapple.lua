return {
	"cbochs/grapple.nvim",
	dependencies = {
		{ "nvim-tree/nvim-web-devicons", lazy = true },
	},

	keys = {
		{ "<leader>a", "<cmd>Grapple toggle<cr>", desc = "Tag a file" },
		{ "<c-e>", "<cmd>Grapple toggle_tags<cr>", desc = "Toggle tags menu" },

		{ "<leader>j", "<cmd>Grapple select index=1<cr>", desc = "Select first tag" },
		{ "<leader>k", "<cmd>Grapple select index=2<cr>", desc = "Select second tag" },
		{ "<leader>l", "<cmd>Grapple select index=3<cr>", desc = "Select third tag" },
		{ "<leader>;", "<cmd>Grapple select index=4<cr>", desc = "Select fourth tag" },
		-- { "<c-M-u>", "<cmd>Grapple select index=5<cr>", desc = "Select fifth tag" },
		-- { "<c-M-p>", "<cmd>Grapple select index=6<cr>", desc = "Select sixth tag" },
		-- { "<c-M-n>", "<cmd>Grapple select index=7<cr>", desc = "Select seventh tag" },
		-- { "<c-M-m>", "<cmd>Grapple select index=8<cr>", desc = "Select eighth tag" },

		{ "<c-n>", "<cmd>Grapple cycle_tags next<cr>", desc = "Go to next tag" },
		{ "<c-m>", "<cmd>Grapple cycle_tags prev<cr>", desc = "Go to previous tag" },
	},
}
