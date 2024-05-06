return {
	dir = "plugins.start-screen",
	main  = "plugins.start-screen.start-screen",
	--event = "VeryLazy",
	lazy = false,
	config = true,
	opts  = {
		-- URGENT: When true this is enabling lspconfig??
		splash_enabled = true,
		number = 1,
		-- Available (TODO: Make sure this is up to date):
		-- Note: "Random" will find any of the (sub)directories to choose
		-- {"Academics","Aurum", "Logos"}
		category = "Logos" -- TODO: Implement "Random"
	},
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
				{ "m00qek/baleia.nvim", tag = 'v1.4.0' }
			},
			config = function ()
			require('image').setup {
					render = {
						min_padding = 5,
						show_label = true,
						show_image_dimensions = false,
						use_dither = false,
						-- Both options must be enabled for
						-- background_color to work
						foreground_color = true,
						background_color = true
					},
					events = {
						update_on_nvim_resize = false,
					}
				}
			end
		}
	},
}
