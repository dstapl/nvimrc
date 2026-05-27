local vim = vim

-- Define Mason packages
local MASON_PKGS = {
	"lua_ls",
	"rust_analyzer",
	"pyright",
	"zls",
	"eslint",
	"tinymist",
	"clangd",
	"fortls"
}

-- Update based on installed Mason packages
local FILETYPES = {
		"lua",
		"rust", "rs",
		"python", "py",
		"zig", "zir", --"zig.zon", -- For zig build system
		"ipynb",
		"js",
		"typ",
		"mc", -- Custom: Monkey C
		"c", "h", -- c
		"fortran",
}

return {
	"neovim/nvim-lspconfig",
	event = "BufReadPost",
	ft = FILETYPES,
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		{
			"hrsh7th/nvim-cmp",
			event = {"InsertEnter","CmdLineEnter"},
			dependencies = {
				"hrsh7th/cmp-nvim-lsp",
				"hrsh7th/cmp-buffer",
			},
		},
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			--build = "make install_jsregexp"
		},
		"saadparwaiz1/cmp_luasnip",
		"j-hui/fidget.nvim",
	},
	opts = function()
		local cmp = require('cmp')
		local cmp_select = { behavior = cmp.SelectBehavior.Select }
		local cmp_lsp = require("cmp_nvim_lsp")

		local capabilities = vim.tbl_deep_extend( -- Might change per system
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)


		return {
			capabilities = capabilities,

			-- TODO	Generate default from MASON_PKGS
			--	Only make modifications from default here
			servers = {
				rust_analyzer = {
					settings = {
						["rust-analyzer"] = {
							checkOnSave = true,
							check = {
								command = "clippy",
							},
						}
					}
				},
				pyright = {},
				clangd = {},
				tinymist = {},
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								-- Ignore global variables from Vimscript
								globals = { "vim", "it", "describe", "before_each", "after_each" },
							}
						}
					}
				},
				zls = {
					settings = {
						format_on_save = false
					}
				},
				-- Adapted from https://github.com/fortran-lang/fortls/issues/426
				fortls = {
					cmd = { "fortls" },
					filetypes = { "fortran" },
					-- root_dir = require("lspconfig").util.root_pattern("Makefile", ".git"),
					settings = {
						fortls = {
							lowercase_intrinsics = true,
							hover_signature = true,
							hover_language = "fortran",
							use_signature_help = true,
						}
					}
				}

			},
			mason = {
				ensure_installed = MASON_PKGS
			},
			cmp = {
				snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
				mapping = cmp.mapping.preset.insert({
					-- Match with Telescope shortcuts
					['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
					['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
					-- Need to configure snippet engine for confirm to work
					['<C-y>'] = cmp.mapping.confirm({ select = true }),
					-- Unsure of use 
					-- ["<C-Y>"] = cmp.mapping.complete(),
				}),
				sources = cmp.config.sources({
					-- Same settings as VSCode
					{ name = "nvim_lsp", max_item_count = 12 },
					{ name = "luasnip", max_item_count = 4 },
				},
				{
					-- Only top 3 most recent buffers
					{ name = "buffer", max_item_count = 3 },
				})
			},
		}

	end,

	config = function(_, opts)
		require("fidget").setup()
		require("mason").setup()
		require("mason-lspconfig").setup(opts.mason)
		require("cmp").setup(opts.cmp)

		-- MIGRATING TO nvim-lspconfig 0.11
        for server, server_opts in pairs(opts.servers) do
            server_opts.capabilities = vim.tbl_deep_extend("force", opts.capabilities, server_opts.capabilities or {})

			-- Replaces lspconfig.server.setup()
            vim.lsp.enable(server, server_opts)
        end

		-- Special options from old config
		-- Zig
        vim.g.zig_fmt_autosave = 0

		-- Custom language servers
        vim.lsp.config["monkeyc_lsp"] = {
            cmd = { "python", "C:/Coding/Garmin/monkeyc-lsp/lsp.py" },
            filetypes = { "mc" },
            root_dir = vim.fs.root(0, { ".git", "monkey.jungle", "manifest.xml" }),
        }
        vim.lsp.enable("monkeyc_lsp")


		-- ALREADY ASSIGNED TO `K` by nvim-lspconfig
		-- vim.keymap.set("n",
		-- '<Leader>sd',
		-- --function()
		-- --	if cmp.visible_docs() then
		-- --		cmp.close_docs()
		-- --	else
		-- --		cmp.open_docs()
		-- --	end
		-- --end
		-- vim.lsp.buf.hover
		-- )
		vim.keymap.set("n", "<Leader>sd", vim.diagnostic.open_float)


		vim.diagnostic.config({
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always", -- Always show source code / docs
				header = "",
				prefix = "",
			},
		})
	end
}
