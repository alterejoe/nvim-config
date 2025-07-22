require("kulala").setup({
	contenttypes = {
		["application/json"] = {
			ft = "json",
			formatter = vim.fn.executable("jq") == 1 and { "jq", "." },
			pathresolver = function(...)
				return require("kulala.parser.jsonpath").parse(...)
			end,
		},
		["application/xml"] = {
			ft = "xml",
			formatter = vim.fn.executable("xmllint") == 1 and { "xmllint", "--format", "-" },
			pathresolver = vim.fn.executable("xmllint") == 1 and { "xmllint", "--xpath", "{{path}}", "-" },
		},
		["text/html"] = {
			ft = "html",
			formatter = vim.fn.executable("prettierd") == 1 and {
				"prettierd",
				"--stdin-filepath",
				"response.html", -- this filename determines the parser
			},
			pathresolver = nil,
		},
	},
})
