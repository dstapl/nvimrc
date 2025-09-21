-- Options file so git doesn't update splash_enabled value every commit
return function()
	local splash_enabled = false
	local colour_enabled = true

	return {
		-- URGENT: When true this is enabling lspconfig??
		splash_enabled = splash_enabled,
		number = 1,
		-- Available (TODO: Make sure this is up to date):
		-- Note: "Random" will find any of the (sub)directories to choose
		-- {"Academics","Aurum", "Logos"}
		category = "Logos", -- TODO: Implement "Random"
		colour = colour_enabled,
		-- samodostal/image is not maintained
		-- requires TheZoraiz/ascii-image-converter
		image = { -- Need to load before
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
		},
	}
end
