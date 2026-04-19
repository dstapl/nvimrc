local vim = vim

local M = {
	"neovim-treesitter/nvim-treesitter",
	dependencies = { "neovim-treesitter/treesitter-parser-registry" },
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	keys = { "<CMD>TSInstallInfo<CR>" },
}

local ensure_language_fts = {
	vimdoc = {},
	lua = {"lua"},
	rust = {"rs"},
	bash = {"sh"},
	latex = {"bib"},
	json = {"json"},
	yaml = {"yaml", "yml"},
	markdown = {"md"},
	zig = {"zig", "zon"},
	javascript = {"js"},
	python = {"py"},
	typst = {"typ"},
	c = {"c", "h"},
	fortran = {"f", "f90", "F", "F90"},
}


-- Flatten list for lazy loading
local lazy_ft = {}
local ft_set = {}

for _, fts in pairs(ensure_language_fts) do
	for _, ft in ipairs(fts) do
		if not ft_set[ft] then
			ft_set[ft] = true
			table.insert(lazy_ft, ft)
		end
	end
end
M.ft = lazy_ft



M.opts = {
	sync_install = false,
	auto_install = true,
}


local function create_autocmd(ts_group, pattern_list)
	vim.api.nvim_create_autocmd({"BufReadPost", "FileType"}, {
		group = ts_group,
		pattern = pattern_list,
		callback = function(ev)
			vim.defer_fn(function()
				local bufnr = ev.buf
				if vim.bo[bufnr].filetype == "" then
					vim.cmd("filetype detect")
				end
				vim.treesitter.start(bufnr)
				vim.bo[bufnr].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"

			end, 0) -- Delay so nvim can load in to determine filetype
		end
	}
)
end

M.config = function(_, opts)
	local ts = require("nvim-treesitter")


	-- Create autocmd to attach Treesitter to filetypes
	local ts_group = vim.api.nvim_create_augroup("treesitter_attach", { clear = true })

	local parsersInstalled = require("nvim-treesitter").get_installed("parsers")

	for _, parser in pairs(parsersInstalled) do
		local filetypes = vim.treesitter.language.get_filetypes(parser)

		local pattern_list = {}
		for i, ft in ipairs(filetypes) do
			pattern_list[i] = "*." .. ft
		end

		create_autocmd(ts_group, pattern_list)
	end

	-- and for the custom file types
	for _, fts in pairs(ensure_language_fts) do
		if #fts > 0 then
			local fts_pattern_list = {}
			for i, ft in ipairs(lazy_ft) do
				fts_pattern_list[i] = "*." .. ft
			end
			create_autocmd(ts_group, fts_pattern_list)
		end
	end



	ts.setup(opts)
	ts.install(vim.tbl_keys(ensure_language_fts))

	-- User command to show installed parsers
	vim.api.nvim_create_user_command("TSInstallInfo", function()
		local parsers_installed = require("nvim-treesitter.parsers").get_installed()
		vim.notify("Installed parsers: " .. table.concat(parsers_installed, ", "), vim.log.levels.INFO)
	end, { nargs = 0 })
end


return M
