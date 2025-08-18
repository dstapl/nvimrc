-- Weather plugin using https://github.com/chubin/wttr.in
-- Requires cURL to function (See weather_request)
local PLUGIN_NAME = "weather"
local M = {}

M.widget_enabled = false
M.default_location = ""
M.location = nil -- Replace with location names
M.weather_report = "" -- Local copy

M.opts = {
	language = "en",
	weather_units = "M",

	-- Formats:
	-- 1
	-- 2
	-- 3: "%l:+%c+%t"
	format = "3",

	-- custom_format = "%l:+%c+%t",
	custom_format = "", -- Overides `format` if set
}



local function _change_location(location)
	-- Check if location is unset/empty
	if (location == nil) or (location == '') then
		location = nil
	end
	M.location = location or M.default_location
end

local function _update_weather(weather_report)
	M.weather_report = weather_report
	Statusline.change_weather(M.weather_report)

	-- Force update of statusline
	vim.opt_local.statusline = "%!v:lua.Statusline.active()"
end

function M.enable(location)
	if M.widget_enabled then return end

	-- If not enabled, search for the weather at current set location
	-- If no argument is specified, use the current set location
	if location ~= M.location then
		_change_location(location)
	end

	-- Use local copy if available
	if (Statusline.weather == "") and (M.weather_report ~= "") then
		print("restoring local copy on enable")
		_update_weather(M.weather_report)
	else
		-- Set default text if currently unset
		print("Default text on enable")
		_update_weather("Refresh weather data")
	end

	M.widget_enabled = true
end

function M.search(location, format)
	location = location or M.location -- Default

	if not M.widget_enabled then
		-- Enable default widget
		-- TODO: Merge these two function calls?
		M.enable(location)
		-- print("Search refreshing")
		M.refresh()
	else
		-- Already enabled so just change location
		_change_location(location)
		-- print("Search refreshing (disable)")
		M.refresh()
	end


end

local function url_encode(s)
	s = tostring(s or "")
	s = s:gsub("\r\n", "\n")

	return s:gsub("([^%w%-_%.~])",
	-- Escape characters with their byte representations
	function(c)
		return string.format("%%%02X", string.byte(c))
	end
	)
end


local function process_location_string(location)
	location = location:gsub("[\r\n]+", "") -- Remove linebreaks
	return url_encode(location)
end

local function process_url_args()
	local arg_format = M.opts.format
	if not ((M.opts.custom_format == "") or (M.opts.custom_format == nil)) then
		arg_format = M.opts.custom_format
	end

	-- Join with keys & and values with =
	local args_list = {
		"" .. M.opts.weather_units,
		"lang=" .. M.opts.language,
		"format=" .. arg_format,
	}
	local args_string =	table.concat(args_list, "&")

	return args_string
end

-- NOTE: Requires cURL
local function weather_request(location)
	local weather_report = nil


	local location_url = process_location_string(location)
	local weather_args = process_url_args()


	-- Quick fail on errors and silent mode to supress error outputs
	print("Doing weather request")
	local request_url = "https://wttr.in/" .. location_url .. "?".. weather_args
	local request = io.popen("curl -fs \"" .. request_url .. "\"")
	if (request == nil) or (request == "") then return nil end

	local raw_string = request:read("all")
	request:close()

	-- Process string (Removing newline character at end)
	weather_report = string.gsub(raw_string, "\n+", "")

	return weather_report
end



-- TODO: Remove formatting text when printing out location
--	e.g. ~Eiffel-Tower, France --> Eiffel Tower, France
-- TODO: Limit display text to only first two components?
--	(e.g. Splitting by comma)
function M.refresh()
	if (M.location == nil) or (M.location == "") then
		print("Refreshing on empty location")
		_update_weather("Refreshing...")
	else
		-- print("Refreshing for non-empty location " .. M.location)
		_update_weather("Refreshing for " .. M.location .. "...")

		local weather_report = weather_request(M.location)
		if (weather_report == nil) or (weather_report == "") then
			error("Error retrieving weather for " .. M.location)
			_update_weather("ERROR: NO DATA")
		else
			_update_weather(weather_report)
		end
	end
end

function M.remove()
	-- Keep existing weather data in case it's re-enabled
	M.widget_enabled = false
	Statusline.change_weather("") -- Remove while keeping internal copy

	-- Force update of statusline
	vim.opt_local.statusline = "%!v:lua.Statusline.active()"
end

function M.toggle()
	if M.widget_enabled then
		M.remove()
	else
		M.enable()
	end
end


-- Replace M.opts with given opts
local function update_opts(opts)
	M.opts.language = opts.lang_code or M.opts.language
	M.opts.weather_units = opts.weather_units or M.opts.weather_units
	M.opts.custom_format = opts.custom_format or M.opts.custom_format
end

function M.setup(opts)
	M.default_location = opts.default_location
	if opts.enabled then
		update_opts(opts)
		M.enable()
	end
end

return M
