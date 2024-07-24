-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--
-- init.lua
-- 	group = vim.api.nvim_create_augroup("executer"),
-- 	pattern = { "*.c", "*.h" },
-- 	callback = function(ev)
-- 		print(string.format("event fired: %s", vim.inspect(ev)))
-- 	end,
-- })
--
-- local function attach_runner() end
local attach_runner = function(outputbuffer, pattern, command, header)
	local jobid = nil

	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("executer", { clear = true }),
		pattern = pattern,
		callback = function()
			if jobid then
				vim.fn.jobstop(jobid)
			end

			local appenddata = function(_, data)
				if data then
					vim.api.nvim_buf_set_lines(outputbuffer, -1, -1, false, data)
				end
			end
			vim.api.nvim_buf_set_lines(outputbuffer, 0, -1, false, header)
			jobid = vim.fn.jobstart(command, {
				stdout_buffered = true,
				on_stdout = appenddata,
				on_stderr = appenddata,
			})
		end,
	})

	-- save once to run
	vim.api.nvim_command("write")
end

local notify = function(lines)
	local message = table.concat(lines, "\n")
	vim.notify(message, vim.log.levels.INFO)
end

local isBufVisible = function(name)
	local wins = vim.api.nvim_list_wins()
	for _, win in ipairs(wins) do
		if vim.api.nvim_win_get_buf(win) == vim.fn.bufnr(name) then
			return true
		end
	end
	return false
end

local createOutputBuffer = function(name)
	local buffernum = vim.fn.bufnr(name)

	local createBuffer = function()
		vim.cmd("vnew")
		buffernum = vim.fn.bufnr("%")
		vim.api.nvim_buf_set_name(buffernum, name)
		return buffernum
	end

	if not buffernum == -1 then
		buffernum = createBuffer()
	else
		if not isBufVisible(name) then
			-- try catch
			local status, result = pcall(function()
				vim.cmd("vertical sb " .. name)
			end)

			if not status then
				buffernum = createBuffer()
			end
		end
	end

	return buffernum
end

vim.api.nvim_create_user_command("AutoExecute", function()
	SourceConfig()

	local currentwindow = vim.api.nvim_get_current_win()
	local currentbuffer = vim.api.nvim_get_current_buf()

	local currentfile = vim.api.nvim_buf_get_name(currentbuffer)
	local filetype = vim.api.nvim_buf_get_option(currentbuffer, "filetype")

	local outputbuffer = createOutputBuffer("output")
	-- print(outputbuffer)
	vim.api.nvim_set_current_win(currentwindow)

	if filetype == "python" then
		pythonpath = vim.g.python3_host_prog or "python"
		attach_runner(outputbuffer, { "*.py" }, pythonpath .. " " .. currentfile, { "Interpreter:", pythonpath })
	elseif filetype == "lua" then
		attach_runner(outputbuffer, { "*.lua" }, "lua " .. currentfile, { "lua:", "" })

		vim.cmd(":source %")
	elseif filetype == "sh" then
		attach_runner(outputbuffer, { "*.sh" }, "sh " .. currentfile, { "sh:", "" })
	elseif filetype == "go" then
		attach_runner(outputbuffer, { "*.go" }, "go run " .. currentfile, { "go:", "" })
	-- else if makefile
	elseif filetype == "make" then
		attach_runner(outputbuffer, { "Makefile" }, "make", { "make:", "" })
	end
end, {})

vim.keymap.set("n", "<leader>ae", ":AutoExecute<CR>", { noremap = true, silent = true })

-- vim.api.nvim_create_user_command("AutoTest", function() end, {})
