-- NeoCodeium Configuration
local neocodeium = require("neocodeium")
neocodeium.setup({
	-- If `false`, then would not start windsurf server (disabled state)
	-- You can manually enable it at runtime with `:NeoCodeium enable`
	enabled = true,
	manual = false,
	-- Set to `false` to disable showing the number of suggestions label in the line number column
	show_label = true,
	-- Set to `true` to enable suggestions debounce
	debounce = true,
	-- Maximum number of lines parsed from loaded buffers (current buffer always fully parsed)
	-- Set to `0` to disable parsing non-current buffers (may lower suggestion quality)
	-- Set it to `-1` to parse all lines
	max_lines = 10000,
	-- Set to `true` to disable some non-important messages, like "NeoCodeium: server started..."
	silent = false,
	-- Set to `false` to enable suggestions in special buftypes, like `nofile` etc.
	disable_in_special_buftypes = false,
	-- Sets default log level. One of "trace", "debug", "info", "warn", "error"
	log_level = "warn",
	-- Set `enabled` to `true` to enable single line mode.
	-- In this mode, multi-line suggestions would collapse into a single line and only
	-- shows full lines when on the end of the suggested (accepted) line.
	-- So it is less distracting and works better with other completion plugins.
	single_line = {
		enabled = false,
		label = "...", -- Label indicating that there is multi-line suggestion.
	},
	-- Set to a function that returns `true` if a buffer should be enabled
	-- and `false` if the buffer should be disabled
	-- You can still enable disabled by this option buffer with `:NeoCodeium enable_buffer`
	filter = function(bufnr)
		return true
	end,
	-- Set to `false` to disable suggestions in buffers with specific filetypes
	-- You can still enable disabled by this option buffer with `:NeoCodeium enable_buffer`
	-- List of directories and files to detect workspace root directory for Windsurf Chat
	root_dir = { ".git", "config.lua", "Makefile", ".env" },
})
