-- Replace this with an iterator
local dir = vim.fn.stdpath("config") .. "/lua/plugins"
local luafiles = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
local modules = {}

local excluded = { -- Excluded module names
	"init",
	"lazy",
	"presence"
}

local function is_excluded(name)
	for _, value in ipairs(excluded) do
		if value == name then
			return true
		end
	end
	return false
end

for _, plugname in ipairs(luafiles) do
	-- Get file name
	local name = plugname:match("\\([^\\%.]*).lua$")
	if (name ~= nil) and not is_excluded(name)  then
		modules[#modules+1] = require("plugins." .. name)
	end -- Skip non-lua files
end

return modules
