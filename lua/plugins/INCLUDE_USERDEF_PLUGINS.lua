local M = {}

-- Include from USERDEF_PLUGINS.txt
-- Typically list of folders but can be files as well
local userdef_filepath = vim.fn.stdpath("config") .. "/lua/plugins/USERDEF_PLUGINS.txt";

local function _load_plugins(name_handler)
	local plugins = {};
	local userdef_plugins_file = io.open(userdef_filepath, "r");

	if not userdef_plugins_file then
		-- Error
		error("Could not open user defined plugins file: " .. userdef_plugins_file)
	else
		-- Populate plugins list
		local idx = 1;
		for name in userdef_plugins_file:lines() do
			plugins[idx] = name_handler(name)
			idx = idx + 1
		end
	end
	userdef_plugins_file:close()

	return plugins
end

M.load_lazy_plugins = function()
	local handler = function(name) return require("plugins." .. name) end
	return _load_plugins(handler)
end

M.load_init_plugins = function()
	local handler = function(name) return name end
	return _load_plugins(handler)
end

return M
