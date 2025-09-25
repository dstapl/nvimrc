-- Replace this with an iterator
local dir = vim.fn.stdpath("config") .. "/lua/plugins"
local luafiles = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
local modules = {}



-- -- TODO: Duplicated in `./lazy.lua`
-- local userdef_filepath = vim.fn.stdpath("config") .. "/lua/plugins/USERDEF_PLUGINS.txt";
-- local userdef_plugins_file = io.open(userdef_filepath, "r");
-- local userdef_plugins_list = {};
-- if not userdef_plugins_file then
-- 	-- Error
-- 	error("Could not open user defined plugins file: " .. userdef_plugins_file)
-- else
-- 	-- Populate plugins list
-- 	local idx = 1;
-- 	for name in userdef_plugins_file:lines() do
-- 		userdef_plugins_list[idx] = name
-- 		idx = idx + 1
-- 	end
-- end
-- userdef_plugins_file:close()
local include_user = require("plugins.INCLUDE_USERDEF_PLUGINS")
local userdef_plugins_list = include_user.load_init_plugins()



-- Table for faster lookup of missing keys
local excluded = { -- Excluded module names. 'init' is mandatory
	init = true,
	lazy = true,
	['INCLUDE_USERDEF_PLUGINS'] = true,

	-- Other plugins
	--presence = true,
	['vim-fugitive'] = true,
	--baleia = true,
	["garbage-day"] = true,
	hardtime = true,


	-- TODO: Fix checkhealth of magma
	jupyter = true,
}

-- Add userdef_plugins into the excluded list
for _, name in ipairs(userdef_plugins_list) do
	excluded[name] = true
end




for _, plugname in ipairs(luafiles) do
	-- Get file name
	-- Filters against *%.txt.+
	local name = plugname:match("\\([^\\%.]*).lua$")

	-- Skip non-lua files
	if name == nil then
		goto continue
	end

	if excluded[name]  then
		--modules[#modules].enabled = false
		goto continue
	end

	modules[#modules+1] = require("plugins." .. name)

	::continue::
end

return modules
