-- NOTE: If experiencing ABI errors when updating parsers:
--		TRY UPDATING THE **TREE-SITTER-CLI** first
return {
	'nvim-treesitter/nvim-treesitter',
	lazy = false,
	build = ":TSUpdate",
	event =  { "BufReadPre", "BufNewFile" }, -- Only need TS inside buffers
	ft = {
		"lua", "rs", "sh", "tex", "bib", "json", "md", "zig", "zon",
		"yaml", "yml", "ipynb", "js", "py", "typ", "c", "h",
		"f", "f90", "F", "F90",
	},
	opts = {
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

	},

	-- Restore functionality of previous version/s of nvim-treesitter
	keys = {
		"<CMD>TSInstallInfo",
	},
	config = function(_, opts)
		local ts = require("nvim-treesitter");
		ts.setup(opts)

		-- Noop on already installed parsers
		ts.install(opts.ensure_installed) -- Async operation

		-- Pretty print list of installed parsers
		vim.api.nvim_create_user_command("TSInstallInfo", function ()
			local parsers = ts.get_installed();

			for _, parser_name in ipairs(parsers) do
				print(parser_name .. "\n")
			end
		end, {nargs = 0});
	end,
}

