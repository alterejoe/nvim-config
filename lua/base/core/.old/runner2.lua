local Job = require("plenary.job")
local randomId = function(charactercount)
	return vim.fn.system("head -c " .. charactercount .. " /dev/urandom | base64 | head -c " .. charactercount)
end

local createBuffer = function(filetype)
	local buf = vim.api.nvim_create_buf(false, true)
	local name = "tmp_" .. randomId(8)

	print("Buffer name: " .. name)
	vim.api.nvim_buf_set_option(buf, "filetype", filetype)
	return buf
end

local delteBuffer = function(buf)
	vim.api.nvim_buf_delete(buf, { force = true })
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
-- what do i want here
-- I want a runner that will only append data on save and reset the output on E
-- I want to be able to cycle through multiple buffer outputs
-- On buffer close I want to kill the process
-- On E restart i want to kill the previous process

local commandArgs = function(filetype, buffer)
	SourceConfig()
	local appendData = function(data)
		vim.schedule(function()
			vim.api.nvim_buf_set_lines(buffer, -1, -1, true, { data })
		end)
	end

	local args = {
		on_stdout = function(_, data, _)
			appendData(data)
		end,
		on_stderr = function(_, data, _)
			appendData(data)
		end,
		on_start = function(_, _)
			appendData("")
			appendData("___ Process started ___")
		end,
		on_exit = function(_, _)
			appendData("___ Process ended ___")
		end,
	}
	if filetype == "python" then
		local environment = vim.g.python3_host_prog or "python3"
		args.command = environment
		args.args = { "%:p" }
		return args
	elseif filetype == "lua" then
		local filepath = vim.api.nvim_buf_get_name(0)
		args.vimcommand = "source " .. filepath
		return args
	elseif filetype == "go" then
		local filepath = vim.api.nvim_buf_get_name(0)
		args.command = "go"
		args.args = { "run", filepath }
		return args
	elseif filetype == "http" then
	end
	error("Filetype has not been configured: " .. filetype)
end

local showIfNotVisible = function(buf)
	if not isBufVisible(buf) then
		vim.api.nvim_command("vsplit")

		if vim.api.nvim_buf_is_valid(buf) then
			vim.api.nvim_command("buffer " .. buf)
		else
			buf = createBuffer("output")
		end

		vim.cmd("normal! G")
		vim.cmd("normal! zz")
		--switch back to the previous buffer
		vim.cmd("wincmd p")
		vim.api.nvim_buf_set_option(buf, "wrap", true)
	end
end

local runNvimCommand = function(vimcommand)
	local success, output = xpcall(function()
		return vim.api.nvim_command_output(args.vimcommand)
	end, debug.traceback)

	local outputsplit = vim.split(output, "[\r\n]+")

	table.insert(outputsplit, 1, "___ Process started ___")
	table.insert(outputsplit, 1, "")
	table.insert(outputsplit, "___ Process ended ___")

	vim.api.nvim_buf_set_lines(buf, -1, -1, true, outputsplit)
	showIfNotVisible(buf)
	-- switch to buf without replacing the current file
	-- error
	return
end

local jobmap = {}
local runner = function(filetype, filepath, jobdata)
	local args = commandArgs(filetype, jobdata.buf)

	if args.vimcommand then
		runNvimCommand(args.vimcommand)
		return
	end
	-- local job = jobdata.job
	--
	-- if job then
	-- 	print("Shutting down previous job")
	-- 	job:shutdown(0, function()
	-- 		print("Job shutdown")
	-- 		job = Job:new(args)
	-- 		job:start()
	-- 		jobdata.job = job
	-- 		jobmap[filepath] = jobdata
	-- 		showIfNotVisible(jobdata.buf)
	-- 	end)
	-- 	return
	-- end
	--
	-- job = Job:new(args)
	-- job:start()
	-- jobdata.job = job
	-- jobmap[filepath] = jobdata
	-- showIfNotVisible(jobdata.buf)
end

vim.keymap.set("n", "E", function()
	local filepath = vim.api.nvim_buf_get_name(0)
	local jobdata = {
		buf = nil,
		job = nil,
	}

	if jobmap[filepath] then
		jobdata = jobmap[filepath]
	else
		jobdata.buf = createBuffer("output")
	end
	local filetype = vim.api.nvim_buf_get_option(0, "filetype")

	runner(filetype, filepath, jobdata)
end)
