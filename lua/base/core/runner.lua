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
		vim.cmd("highlight OutputSuccess guifg=Green ctermfg=Green")
		vim.cmd("highlight OutputInfo guifg=Cyan ctermfg=Cyan")
		buffernum = vim.fn.bufnr("%")
		vim.api.nvim_buf_set_name(buffernum, name)

		vim.cmd("setlocal wrap")
		vim.cmd("w!")
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
	local current
	cursor = vim.api.nvim_win_get_cursor(currentwindow)

	local jobid = nil
	local outputbuf = createOutputBuffer("output")
	local command = ""
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local path = vim.api.nvim_buf_get_name(0)
	if filetype == "lua" then
		command = "/opt/squashfs-root/usr/bin/nvim -l " .. path
	elseif filetype == "python" then
		condapython = vim.g.python3_host_prog or "python"
		command = condapython .. " " .. path
	end

	local pattern = ""
	local partial_line = ""
	local started = false
	local attachbuffer = function()
		if jobid then
			print("Jobid: " .. jobid)
			-- kill
			vim.fn.jobstop(jobid)

			-- vimfn.chanclose(job_id, "stdin")
		end

		-- if outputbuffer not exists return
		if not vim.api.nvim_buf_is_valid(outputbuf) then
			return
		end
		local appendData = function(data)
			-- vim.api.nvim_buf_set_lines(outputbuf, -1, -1, false, data)
			-- if partial_line ~= "" then
			-- 	data[1] = partial_line .. data[1]
			-- 	partial_line = ""
			-- end
			-- if #data > 0 then
			-- 	vim.api.nvim_buf_set_lines(outputbuf, -1, -1, false, data)
			-- end
			if data then
				vim.api.nvim_buf_set_lines(outputbuf, -1, -1, false, data)
			end

			-- vim.api.nvim_command("normal! G")

			-- update window to see colors
			-- vim.api.nvim_command("redraw")
		end

		jobid = vim.fn.jobstart(command, {
			on_enter = function()
				appendData({ "___ process exited ___" })
			end,
			on_stdout = function(_, data, _)
				if not started then
					appendData({ "___ Process started ___" })
					started = true
				end

				local regexline = {}
				for i, line in ipairs(data) do
					regexline[i] = "---     " .. line
				end
				appendData(data)
			end,
			on_stderr = function(_, data, _)
				for i, line in ipairs(data) do
					data[i] = "-----     " .. line
				end
				-- print("Here is error")
				-- print(data)
				-- -- print("Error: " .. data)
				-- -- print("----------------")
				-- for i, line in ipairs(data) do
				-- 	print(i, line)
				-- end
				appendData(data)
			end,
			on_exit = function(_, _, _)
				-- print("Process exited")
				appendData({ "___ Process exited ___" })
				vim.cmd("normal! G")
			end,
		})
	end
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("executer", { clear = true }),
		pattern = pattern,
		callback = attachbuffer,
	})

	vim.api.nvim_buf_set_lines(outputbuf, 0, -1, false, {})

	vim.fn.matchadd("OutputError", "-----     .*")
	vim.fn.matchadd("OutputSuccess", "___ process exited ___.*")
	vim.fn.matchadd("OutputInfo", "___ Process started ___.*")
	attachbuffer()
	-- save buffer

	-- focus on orignal window
	vim.api.nvim_set_current_win(currentwindow)
	vim.api.nvim_win_set_cursor(currentwindow, cursor)
end, {})

vim.keymap.set("n", "E", function()
	vim.cmd("AutoExecute")
end, {})
