local MAINFILE = "plugins.strudel.lua.strudel"
local PREFIX = "Strudel"
local command_names = {
	["start"] = PREFIX .. "Start", -- Start audio server
	["stop"] = PREFIX .. "Stop", -- Stop audio server + Animations
}


return {
	dir = vim.fn.stdpath("config") .. "/lua/plugins/strudel",
	main  = MAINFILE,
	lazy = false,
	opts  = require("plugins.strudel.opts"),

	config = function (_, opts)
		if not opts.enabled then
			-- Don't load plugin
			return
		end

		local strudel = require(MAINFILE)
		strudel.setup(opts)


		vim.api.nvim_create_user_command(command_names.start,
			strudel.start,
			{nargs = 0}
		)


		vim.api.nvim_create_user_command(command_names.stop,
			strudel.stop,
			{nargs = 0}
		)
	end,

	keys = {
		{"<leader>sp", "<CMD>" .. command_names.start .. "<CR>", desc = "(Play)Start audio server"},
		{"<leader>ss", "<CMD>" .. command_names.stop .. "<CR>", desc = "(S)top audio server and any animations"},
		-- Enable and Remove should be manual by default
	},

	priority = 1000,
}
