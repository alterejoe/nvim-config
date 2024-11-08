***The structure of this is important, I want to have multiple processes running but not under specific conditions ***
**Conditions**
*Management*
    [ ] when starting a project (a directory with config.lua in the root) register the project in the local sqlite db
        [ ] hold disabled files for nvim restarts (allows for test files to be separated from the project runner to run on their own without having to disable on every nvim reboot)
    <!-- [ ] not nessicary right now but eventually i could have a keyboard shortcut like grapple to open and start project configurations -->
    <!--     [ ] open a project -->
    <!--     [ ] run the project command -->
    <!--     [ ] set the current owrking directory to the project -->

*Starting* 
    [ ] use a keymap to start a process in pm2
        [ ] this will start project commands defined in config.lua or the default runner for the current file
            [ ] this will start a project command if there is a config.lua at the root of the cwd and the file isn't disabled for the project
            [ ] else it will run the curernt file with the default runner

*Restarting*
    [ ] on any file within project unless disabled on 'change' (not just on save) restart project
    [ ] restart file on change 
        [ ] check if file has changed before restarting
    [ ] kill previous file with pm2 before starting new process


*Closing*
    [ ] when buffer is closed kill the process
    [ ] when nvim is closed kill all processes
    


