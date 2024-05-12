-- Replace this with an iterator
local dir = vim.fn.stdpath("config") .. "/lua/plugins"
local luafiles = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
local modules = {}

-- Table for faster lookup of missing keys
local excluded = { -- Excluded module names. 'init' is mandatory
	--init = true,
	lazy = true,
	presence = true,
	['vim-fugitive'] = true,
	--baleia = true,
}

local function is_excluded(name)
    return excluded[name]
end

for _, plugname in ipairs(luafiles) do
--for k=1, #luafiles do local plugname = luafiles[k];
	-- Get file name
	-- Filters against *%.txt.+
	local name = plugname:match("\\([^\\%.]*).lua$")
	-- Skip non-lua files
	if (name ~= nil) and not ( (name == "init") or (name == "lazy") ) then
		modules[#modules+1] = require("plugins." .. name)
		if is_excluded(name) then
			modules[#modules].enabled = false
		end
	end
end

return modules
