local vim = vim

local M = {
	"neovim-treesitter/nvim-treesitter",
	dependencies = { "neovim-treesitter/treesitter-parser-registry" },
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	keys = { "<CMD>TSInstallInfo<CR>" },
}

local ensure_language_fts = {
	vimdoc = {},
	lua = {"lua"},
	rust = {"rs"},
	bash = {"sh"},
	latex = {"tex", "sty"},
	bibtex = {"bib"},
	json = {"json"},
	yaml = {"yaml", "yml"},
	markdown = {"md"},
	zig = {"zig", "zon"},
	javascript = {"js"},
	typescript = {"ts"},
	python = {"py"},
	typst = {"typ"},
	c = {"c", "h"},
	fortran = {"f", "f90", "F", "F90"},
}

M.opts = {
	sync_install = false,
	auto_install = true,

	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},

	indent = {
		enable = true,
	},
}

M.config = function(_, opts)
	local ts = require("nvim-treesitter")

	-- Configure nvim-treesitter first.
	ts.setup(opts)

	-- Install/ensure the requested parsers.
	ts.install(vim.tbl_keys(ensure_language_fts))

	-- User command to show installed parsers.
	vim.api.nvim_create_user_command("TSInstallInfo", function()
		local ok, parsers_mod = pcall(require, "nvim-treesitter")
		local parsers_installed = ok and parsers_mod.get_installed() or {}

		vim.notify(
			"Installed parsers: " .. table.concat(parsers_installed, ", "),
			vim.log.levels.INFO
		)
	end, { nargs = 0 })
end

return M
