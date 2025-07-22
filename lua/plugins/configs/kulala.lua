require("kulala").setup({
	global_keymaps = false,
	ft = { "http", "rest" },
	contenttypes = {
		["text/html"] = {
			ft = "html",
			formatter = vim.fn.executable("prettierd") == 1 and {
				"prettierd",
				"--stdin-filepath",
				"response.html",
			},
			pathresolver = nil,
		},
	},
})
