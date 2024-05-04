-- Replace this with an iterator
local dir = vim.fn.stdpath("config") .. "/lua/plugins"
local luafiles = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
local modules = {}

-- Table for faster lookup of missing keys
local excluded = { -- Excluded module names. 'init' is mandatory
	init = true,
	lazy = true,
	presence = true,
}

local function is_excluded(name)
    return excluded[name]
end

for _, plugname in ipairs(luafiles) do
	-- Get file name
	-- Filters against *%.txt.+
	local name = plugname:match("\\([^\\%.]*).lua$")
	-- Skip non-lua files
	if (name ~= nil) and not is_excluded(name)  then
		modules[#modules+1] = require("plugins." .. name)
	end
end

return modules
