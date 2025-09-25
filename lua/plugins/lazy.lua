local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)


-- -- Include from USERDEF_PLUGINS.txt
-- -- Typically list of folders
-- -- TODO: Names
-- -- TODO: Duplicated in `./init.lua`
-- local userdef_filepath = vim.fn.stdpath("config") .. "/lua/plugins/USERDEF_PLUGINS.txt";
-- local userdef_plugins_file = io.open(userdef_filepath, "r");
-- local plugins = {};
-- if not userdef_plugins_file then
-- 	-- Error
-- 	error("Could not open user defined plugins file: " .. userdef_plugins_file)
-- else
-- 	-- Populate plugins list
-- 	local idx = 1;
-- 	for name in userdef_plugins_file:lines() do
-- 		plugins[idx] = require("plugins." .. name)
-- 		idx = idx + 1
-- 	end
-- end
-- userdef_plugins_file:close()

-- local plugins = require("plugins.INCLUDE_USERDEF_PLUGINS")
local include_user = require("plugins.INCLUDE_USERDEF_PLUGINS")

local plugins = include_user.load_lazy_plugins()

-- Append "plugins" to the end of userdef list
-- To include the remaining, external, plugins
plugins[#plugins + 1] = require("plugins");

local opts = {
	performance = {
		rtp = {
		disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin", -- netrw is useful
        "tarPlugin",
        "tohtml",
        -- "tutor",
        "zipPlugin",
      },
	},
	}
}

require("lazy").setup(plugins, opts)
