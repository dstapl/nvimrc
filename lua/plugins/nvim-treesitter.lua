-- NOTE: If experiencing ABI errors when updating parsers:
--		TRY UPDATING THE **TREE-SITTER-CLI** first

-- Snippets from nvim-treesitter/lua/health.lua
local function query_status(lang, query_group)
	local tsq = vim.treesitter.query
	local ok, err = pcall(tsq.get, lang, query_group)
	if not ok then
		return 'x', err
	elseif not err then
		return '.'
	else
		return '✓'
	end
end

-- Adapted from nvim-treesitter/lua/health.lua
-- Removed error collection
local function get_installed_parsers()
	local config = require("nvim-treesitter.config")
	local parsers = require("nvim-treesitter.parsers")
	local ts_health = require("nvim-treesitter.health")
	local health = vim.health

	-- Parser installation checks
	local lang_status_string = 'Installed languages' .. string.rep(' ', 5) .. 'H L F I J\n'

	local languages = config.get_installed()
	table.sort(languages)

	for _, lang in ipairs(languages) do
		local parser = parsers[lang]
		local out = lang .. string.rep(' ', 22 - #lang)

		if parser and parser.install_info then
			for _, query_group in pairs(ts_health.bundled_queries) do
				local status, _ = query_status(lang, query_group)
				out = out .. status .. ' '
			end
		end

		lang_status_string = lang_status_string .. string.rep(' ', 2) .. vim.fn.trim(out, ' ', 2) .. "\n"
	end

	local legend = '  Legend: H[ighlights], L[ocals], F[olds], I[ndents], In[J]ections'
	lang_status_string = lang_status_string .. "\n" .. legend

	vim.notify(
		lang_status_string,
		vim.log.levels.INFO
	)
end



local M = {
	'nvim-treesitter/nvim-treesitter',
	lazy = false,
	build = ":TSUpdate",
	event =  { "BufReadPre", "BufNewFile" }, -- Only need TS inside buffers
	ft = {
		"lua", "rs", "sh", "tex", "bib", "json", "md", "zig", "zon",
		"yaml", "yml", "ipynb", "js", "py", "typ", "c", "h",
		"f", "f90", "F", "F90",
	},

	-- Restore functionality of previous version/s of nvim-treesitter
	keys = {
		"<CMD>TSInstallInfo",
	},
}

M.opts = {
	ensure_installed = {
		"vimdoc", "lua", "rust", "bash", "latex", "bibtex", "json",
		"markdown", "zig", "yaml", "javascript", "python", "typst",
		"c", "fortran",
	},
	sync_install = false,

	-- Set to false if `tree-sitter` CLI is not intsalled locally
	auto_install = true,
	highlight = { -- Consistent syntax highlighting
		enable = true,
		disable = {},-- List of disabled *parsers*
	},
	incremental_selection = { -- Parser grammar node selection
		enable = false,
		disable = {},
	},
	indent = { -- Indentation when = is pressed
		enable = true,
		disable = {},
	},

}

M.config = function(_, opts)
	local ts = require("nvim-treesitter");
	ts.setup(opts)

	-- Noop on already installed parsers
	ts.install(opts.ensure_installed) -- Async operation

	-- NOTE: 2026-12-19 get_installed is currently exposed in the API
	-- nvim-treesitter commit 0ac55b8
	-- Pretty print list of installed parsers
	vim.api.nvim_create_user_command("TSInstallInfo", function ()
		get_installed_parsers()
	end, {nargs = 0});
end


return M
