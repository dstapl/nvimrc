return {
	dir = "plugins.start-screen",
	main  = "plugins.start-screen.start-screen",
	--event = "VeryLazy",
	lazy = false,
	opts  = require("plugins.start-screen.opts"),
	-- config = true,
	config = function (_, opts)
		if not opts.splash_enabled then
			-- Splash screen is disabled
			return
		end

		local colour_enabled = not not opts.colour

		if colour_enabled then
			require("baleia").setup({})
		end

		require("image").setup(opts.image)

		require("plugins.start-screen.start-screen").setup(opts)
	end,
	priority = 1000,
}
