-- Avoid side-effects when nocompatible has already been set.
if vim.opt.compatible:get() then
    vim.opt.compatible = false
end

vim.opt.guicursor = ""

-- Set hybrid (regular + relative) line numbers
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- Other things
vim.opt.ruler = true
vim.opt.ls = 2

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.expandtab = true -- Convert tabs to spaces

vim.opt.smartindent = true

vim.opt.wrap = false -- Yucky linewrap

-- Search highlighting
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Colours
vim.opt.termguicolors = true

-- Other
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes" -- Display things like breakpoints & icons
vim.opt.updatetime = 1000 -- Unstable at lower values than ~1000
-- Don't colour characters past column limit (Soft char limit)
vim.opt.colorcolumn = "80"


vim.opt.visualbell = false


-- Edit netrw file explorer
vim.g.netrw_banner = 0
vim.g.netrw_browse_split = 0
vim.g.netrw_winsize = 25

-- Set overrides for specific files
local wrap_files = {
	'markdown',
}

-- Want maximum colorcolumn and the difference between the remaining columns
for _, filetype in ipairs(wrap_files) do
	local au_name = string.format("WrapLineIn%sFile", filetype)
	local col_l = vim.opt.colorcolumn:get()
	local wrap_m = math.max(0, vim.fn.winwidth(0) - (col_l[0] or col_l[1]))
	local nvim_au_exec = string.format([[
		augroup %s
			autocmd!
			autocmd FileType %s setlocal wrap
			autocmd FileType %s setlocal wrapmargin=%s
		augroup END
	]], au_name, filetype, filetype, wrap_m
	)
	vim.api.nvim_exec(nvim_au_exec, false)
end


-- Set <Leader>
vim.g.mapleader = " "

