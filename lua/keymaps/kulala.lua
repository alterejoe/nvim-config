-- {
--   global_keymaps = {
--       ["Send request"] = { -- sets global mapping
--         "<leader>Rs",
--         function() require("kulala").run() end,
--         mode = { "n", "v" }, -- optional mode, default is n
--         desc = "Send request" -- optional description, otherwise inferred from the key
--       },
--       ["Send all requests"] = {
--         "<leader>Ra",
--         function() require("kulala").run_all() end,
--         mode = { "n", "v" },
--         ft = "http", -- sets mapping for *.http files only
--       },
--       ["Replay the last request"] = {
--         "<leader>Rr",
--         function() require("kulala").replay() end,
--         ft = { "http", "rest" }, -- sets mapping for specified file types
--       },
--     ["Find request"] = false -- set to false to disable
--   },
-- }
-- vim.keymap.set("n", "<tab>s", function()
-- 	require("kulala").scratchpad()
-- end)

vim.keymap.set("n", "<tab>s", function()
	require("kulala").run()
end)
vim.keymap.set("n", "<tab>a", function()
	require("kulala").run_all()
end)
vim.keymap.set("n", "<tab>o", function()
	require("kulala").open()
end)
-- ["Manage Auth Config"] = { "u", function() require("lua.kulala.ui.auth_manager").open_auth_config() end, ft = { "http", "rest" }, },
vim.keymap.set("n", "<tab>A", function()
	require("kulala.ui.auth_manager").open_auth_config()
end)

-- ["Select environment"] = { "e", function() require("kulala").set_selected_env() end, ft = { "http", "rest" }, },
vim.keymap.set("n", "<tab>E", function()
	require("kulala").set_selected_env()
end)
