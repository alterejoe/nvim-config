-- if this is not specified it will default to the current file and cwd
vim.g.runnercommand = "make"

-- this will override the vim.g.runnercommand and use the runner as normal using the filepath
vim.g.runnerfiletypeexceptions = {
	"http",
}
-- for defining which files will trigger a rerun
vim.g.runnerpattern = { "go", "html" }
--
-- ignore these patterns for reruns
vim.g.ignorepattern = { "main.go" }
