local ls = require("luasnip")
-- Load all generated snippet files
-- Add both to "templ" and "go" filetypes since you use both
local snippet_files = {
	"structs",
	"linkbutton",
	"button",
	"div",
	"checkbox",
	"chevron",
	"form",
	"input",
	"link",
	"notice",
	"radio",
	"select",
	"textarea",
}

for _, file in ipairs(snippet_files) do
	local ok, snippets = pcall(require, "snippets." .. file)
	if ok then
		ls.add_snippets("templ", snippets)
		ls.add_snippets("go", snippets)
		print("✅ Loaded: " .. file)
	else
		-- snippets contains the error when ok is false
		vim.notify("Failed to load snippet file: " .. file .. "\nError: " .. tostring(snippets), vim.log.levels.ERROR)
		print("❌ Error loading " .. file .. ": " .. tostring(snippets))
	end
end
