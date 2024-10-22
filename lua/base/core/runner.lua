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

local jobids = {}
vim.api.nvim_create_user_command("AutoExecute", function()
	SourceConfig()
	local currentwindow = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(currentwindow)

	local command = ""
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")
	local extension = vim.fn.expand("%:e")
	local path = vim.api.nvim_buf_get_name(0)

	local outputbuf = createOutputBuffer("output")

	if filetype == "lua" then
		command = "/opt/squashfs-root/usr/bin/nvim -l " .. path
	elseif filetype == "python" or extension == "py" then
		local condapython = vim.g.python3_host_prog or "python"
		command = condapython .. " " .. path
	elseif filetype == "go" or extension == "go" then
		command = "go run " .. path
	elseif filetype == "http" or extension == "http" then
		local parser = vim.treesitter.get_parser(bufnr, "customhttp")
		local tree = parser:parse()[1]:root()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local node = tree:descendant_for_range(row, col, row, col)

		while node and node:type() ~= "request" do
			node = node:parent()
		end

		if not node then
			print("No request node found")
			return
		else
			print("Request node found")
		end

		command = "curl -s -i "
		local method = ""
		local url = ""
		local headers = {}
		local body = ""

		for child in node:iter_children() do
			local childtype = child:type()
			print("Child type: " .. childtype)
			if childtype == "method" then
				method = vim.treesitter.get_node_text(child, bufnr)
			elseif childtype == "url" then
				url = vim.treesitter.get_node_text(child, bufnr)
			elseif childtype == "header" then
				local header = vim.treesitter.get_node_text(child, bufnr)
				header = '-H "' .. header .. '"'
				table.insert(headers, header)
			elseif childtype == "body" then
				local text = vim.treesitter.get_node_text(child, bufnr)
				text = text:gsub("\n", "")
				text = text:gsub("\r", "")
				text = text:gsub("\t", "")
				body = "-d '" .. text .. "'"
			end
		end

		command = command .. " -X " .. method .. " " .. url .. " " .. table.concat(headers, " ") .. " " .. body
		print("Command: " .. command)
		-- command = command .. " | jq ."
		command = command .. " -o -"
	else
		print("No filetype: " .. filetype)
	end

	local pattern = ""
	local attachbuffer = function()
		-- for i, id in pairs(jobids) do
		-- 	print("Jobid: " .. id)
		-- end

		if jobids[outputbuf] then
			print("Killing job: " .. outputbuf)
			-- vim.fn.jobstop(jobids[outputbuf][1])
			vim.defer_fn(function()
				vim.fn.system("kill -9 " .. jobids[outputbuf][2])
				print("Killed job: " .. outputbuf)
			end, 100)
		end

		if not vim.api.nvim_buf_is_valid(outputbuf) then
			return
		end
		local appendData = function(data)
			if data then
				vim.api.nvim_buf_set_lines(outputbuf, -1, -1, false, data)
			end
		end

		local jobid = vim.fn.jobstart(command, {
			-- on_enter = function()
			-- 	appendData({ "___ process exited ___" })
			-- end,
			on_stdout = function(_, data, _)
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
				appendData(data)
			end,
			-- on_exit = function(_, _, _)
			-- 	-- print("Process exited")
			-- 	appendData({ "___ Process exited ___" })
			-- 	-- vim.cmd("normal! G")
			-- end,
		})
		local pid = vim.fn.jobpid(jobid)
		jobids[outputbuf] = { jobid, pid }
	end
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		group = vim.api.nvim_create_augroup("executer", { clear = true }),
		pattern = pattern,
		callback = attachbuffer,
	})

	vim.api.nvim_buf_set_lines(outputbuf, 0, -1, false, {})

	-- vim.fn.matchadd("OutputError", "-----     .*")
	-- vim.fn.matchadd("OutputSuccess", "___ process exited ___.*")
	-- vim.fn.matchadd("OutputInfo", "___ Process started ___.*")
	attachbuffer()
	-- save buffer

	-- focus on orignal window
	vim.api.nvim_set_current_win(currentwindow)
	vim.api.nvim_win_set_cursor(currentwindow, cursor)
end, {})

vim.keymap.set("n", "E", function()
	vim.cmd("AutoExecute")
end, {})
