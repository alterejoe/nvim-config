local M = {}

function M.correctCustomCommand(command, processname)
	local runner = command[1]
	local args = command[#command - 1]

	print("Runner: " .. runner)
	print("Args: " .. vim.inspect(args))
	local command = nil
	if args ~= nil then
		command = {
			"pm2",
			"start",
			runner,
			"--",
		}
		for i, v in ipairs(args) do
			table.insert(command, v)
		end
		command[#command + 1] = "--name"
		command[#command + 1] = processname
	else
		command = {
			"pm2",
			"start",
			runner,
			"--name",
			processname,
		}
	end
	return command
end

function M.createCommand(filetype, filepath, processname)
	if filetype == "python" then
		return {
			"pm2",
			"start",
			"python3",
			"--name",
			processname,
			"--",
			filepath,
		}
	elseif filetype == "lua" then
		return {
			"pm2",
			"start",
			"lua",
			"--",
			filepath,
			"--name",
			processname,
		}
	elseif filetype == "go" then
		local folder = string.match(filepath, "(.+)/[^/]*$")
		return {
			"pm2",
			"start",
			"go",
			"--",
			"run",
			folder,
			"--name",
			processname,
		}
	else
		error("No runner found for " .. filetype)
	end
end

return M
