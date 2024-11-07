***The structure of this is important, I want to have multiple processes running but not under specific conditions ***
**Conditions**
*Management*
    [ ] when starting a project (a directory with config.lua in the root) register the project in the local sqlite db
        [ ] hold disabled files for nvim restarts (allows for test files to be separated from the project runner to run on their own without having to disable on every nvim reboot)
    
*Starting* 
    [ ] use a keymap to start a process 
        [ ] this will start project commands defined in config.lua or the default runner for the current file
            [ ] this will start a project command if there is a config.lua at the root of the cwd and the file isn't disabled for the project
            [ ] else it will run the curernt file with the default runner

*Restarting*
    [ ] on project change
        - use a second keymap to disable files in the project
        - when working within the project toggle off 
    [ ] on file change

*Closing*
    [ ] 


