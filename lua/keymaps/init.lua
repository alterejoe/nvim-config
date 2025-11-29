local keymaps_modules = {
	"keymaps.dadbodui",
	"keymaps.emmet",
	"keymaps.terminal",
	"keymaps.neocodeium",
	"keymaps.everyday",
	"keymaps.rm-m",
	"keymaps.write",
	"keymaps.notes",
	"keymaps.nvim-cmp",
	"keymaps.gitworktree",
	"keymaps.grapple",
	"keymaps.quit",
	"keymaps.telescope",
	"keymaps.lsp-config",
	"keymaps.oil",
	"keymaps.paste-wout-copy",
	"keymaps.resethighlight",
	"keymaps.yank-tree",
	"keymaps.undotree",
	"keymaps.autoroot",
	"keymaps.kulala",
	"keymaps.jump",
	"keymaps.nvim-dap",
	"keymaps.lazygit",
	"keymaps.replacer",
	"keymaps.resize",
	"keymaps.go-tasks",
}

local errors = "Error requiring keymap modules: "
local founderrors = false
for _, module in ipairs(keymaps_modules) do
	local ok, result = pcall(require, module)
	if not ok then
		founderrors = true
		errors = errors .. module .. ", "
	end
end

if founderrors then
	vim.notify(errors, vim.log.levels.ERROR)
else
	vim.notify("Keymaps imported correctly.", vim.log.levels.INFO)
end
