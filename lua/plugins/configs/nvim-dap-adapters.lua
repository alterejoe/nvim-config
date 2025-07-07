local dap = require("dap")
--
-- require("dap").defaults.fallback.terminal_win_cmd = "50vsplit new"
-- vim.fn.sign_define("DapStopped", { text = "🔴", texthl = "Error", linehl = "", numhl = "" })

dap.defaults.fallback.terminal_win_cmd = "50vsplit new"

dap.adapters.dlv_spawn = function(callback)
	local stdout = vim.loop.new_pipe(false)
	local handle
	local port = 38697
	local opts = {
		stdio = { nil, stdout },
		args = { "dap", "-l", "127.0.0.1:" .. port },
		detached = true,
	}
	handle = vim.loop.spawn("dlv", opts, function(code)
		stdout:close()
		handle:close()
		if code ~= 0 then
			print("dlv exited with code", code)
		end
	end)
	assert(handle, "Error running dlv")
	stdout:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
			end)
		end
	end)
	-- Wait for delve to start
	vim.defer_fn(function()
		callback({ type = "server", host = "127.0.0.1", port = port })
	end, 100)
end

dap.adapters.python = {
	type = "executable",
	command = "python", -- Adjust this to your Python path
	args = { "-m", "debugpy.adapter" },
}

dap.adapters.godot = {
	type = "server",
	host = "127.0.0.1",
	port = 6006,
}
dap.adapters.gdb = {
	type = "executable",
	command = "gdb",
	args = { "--interpreter=dap", "--eval-command", "set print pretty on", "--quiet" },
}
--

dap.listeners.after.event_exited["dapui_config"] = function()
	require("dap").close()
end
