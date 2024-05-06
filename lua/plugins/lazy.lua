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

local plugins = {
	require("plugins.start-screen"),
	require("plugins.colourschemes"),
	require("plugins")
}

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
