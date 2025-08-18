local MAINFILE = "plugins.weather.weather"
local PREFIX = "Weather"
local command_names = {
	["search"] = PREFIX .. "Search", -- Changes location
	["refresh"] = PREFIX .. "Refresh",
	["toggle"] = PREFIX .. "Toggle",
	["remove"] = PREFIX .. "Remove",
	["enable"] = PREFIX .. "Enable",
	-- TODO: Change locale? or leave that to opts
}


return {
	dir = vim.fn.stdpath("config") .. "/lua/plugins/weather",
	main  = MAINFILE,
	lazy = false,
	opts  = require("plugins.weather.opts"),

	config = function (_, opts)
		if not opts.enabled then
			-- Statusline widget is disabled
			return
		end

		local weather = require(MAINFILE)
		weather.setup(opts)


		-- TODO: Add complete or not?
		vim.api.nvim_create_user_command(command_names.search,
			function (fopts)
				weather.search(fopts.args)
			end,
			{nargs = 1}
		)

		vim.api.nvim_create_user_command(command_names.refresh,
			weather.refresh,
			{nargs = 0}
		)

		vim.api.nvim_create_user_command(command_names.toggle,
			weather.toggle,
			{nargs = 0}
		)

		vim.api.nvim_create_user_command(command_names.remove,
			weather.remove,
			{nargs = 0}
		)
		vim.api.nvim_create_user_command(command_names.enable,
			weather.enable,
			{nargs = 0}
		)

		-- TODO: Command to change default location somehow
		-- + ditto for locale
	end,

	keys = {
		{"<leader>ws", ":" .. command_names.search .." ", desc = "Change current weather location"},
		{"<leader>wr", "<CMD>" .. command_names.refresh .. "<CR>", desc = "Refresh weather at current location"},
		{"<leader>wt", "<CMD>" .. command_names.toggle .. "<CR>", desc = "Toggle weather widget in statusline"},
		-- Enable and Remove should be manual by default
	},

	priority = 1000,
}
