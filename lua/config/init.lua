vim.cmd("source " .. vim.fn.stdpath("config") ..
	"/lua/config/transwrd.vim"
)

return {
	require("config.options"),
	require("config.keymaps"),
	require("config.statusline"),
}

