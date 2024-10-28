if you want to have a custom script to use as a runner such as if you need to generate files before a run.
As you would if you were using templ. You can create custom commands.
The only caveat is if you need to kill a continuous portion of the script you will need to add a --unique-id=<id>
to the command within the custom script, and a vim.g.uniqueid = <id> to a config.lua so that the runner can kill previous processes

-  command
vim.g.runnercommand = <custom command> eg: make
vim.g.uniqueid = 12345678

Makefile:
run: 
    templ generate
    go run ./cmd/web/ --unique-id=12345678

This will successfully kill the previous go web server 
