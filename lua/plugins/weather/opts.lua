return function()
	return {
		enabled = true,

		default_location = "England, UK",
		-- Two character lang-code
		lang_code = "en",

		-- USCS: u
		-- Metric (SI) (Wind km/h): m
		-- Metric (SI) (Wind m/s): M
		weather_units = "M",

		-- Custom weather format
		custom_format = "%l:+%c+%t",
	}
end
