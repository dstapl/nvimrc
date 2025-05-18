return {
	dir = vim.fn.stdpath("config") .. "/lua/plugins/status-animation",
	main = "plugins.status-animation.status-animation",
	lazy = false,
	opts = require("plugins.status-animation.opts"),
	config = function(_, opts)
		require("plugins.status-animation.status-animation").setup(opts)
	end,
	priority = 1000,
}
