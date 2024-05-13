return {
	dir = "plugins.start-screen",
	main  = "plugins.start-screen.start-screen",
	--event = "VeryLazy",
	lazy = false,
	opts  = {
		-- URGENT: When true this is enabling lspconfig??
		splash_enabled = false,
		number = 1,
		-- Available (TODO: Make sure this is up to date):
		-- Note: "Random" will find any of the (sub)directories to choose
		-- {"Academics","Aurum", "Logos"}
		category = "Random", -- TODO: Implement "Random"
		colour = true,
	},
	-- config = true,
	config = function (_, opts)
		local colour_enabled = false
		if not opts.splash_enabled then
			-- Splash screen is disabled
			return
		else
			colour_enabled = not not opts.colour

			if colour_enabled then
				require("baleia").setup({})
			end
		end

		require("image").setup({
			render = {
				min_padding = 5,
				show_label = true,
				show_image_dimensions = false,
				use_dither = false,
				-- Both options must be enabled for
				-- background_color to work
				foreground_color = colour_enabled,
				background_color = colour_enabled,
			},
			events = {
				update_on_nvim_resize = false,
			}

		})

		require("plugins.start-screen.start-screen").setup(opts)
	end,
	priority = 1000,
	-- samodostal/image is not maintained
	-- requires TheZoraiz/ascii-image-converter
	dependencies = {
		{
			'samodostal/image.nvim',
			--lazy = false,
			--priority = 1000,
			dependencies = {
				'nvim-lua/plenary.nvim',
			},
			lazy = true,
		}
	},
}
