return {
	"neovim/nvim-lspconfig",
	-- Update based on installed lsp servers
	--event = "BufReadPost",
	ft = {
		"lua",
		"rs",
		"py"
	},
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		{
			"hrsh7th/nvim-cmp",
			event = "InsertEnter",
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

		local lspconfig = require("lspconfig")

		local capabilities = vim.tbl_deep_extend( -- Might change per system
			"force",
			{},
			vim.lsp.protocol.make_client_capabilities(),
			cmp_lsp.default_capabilities()
		)

		return {
			["mason-lspconfig"] = {
				ensure_installed = { -- Define LSPs
				"lua_ls",
				"rust_analyzer",
				"pyright",
				},
				handlers = {
					function(server_name) -- Default handler 
						lspconfig[server_name].setup {
							capabilities = capabilities
						}
					end,
					["lua_ls"] = function() -- Disable warnings undefined global vim
						lspconfig.lua_ls.setup {
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = {
										-- Ignore global variables from Vimscript
										globals = { "vim", "it", "describe", "before_each", "after_each" },
									}
								}
							},
						}
					end,
				}
			},
			cmp = {
				snippet = {
					expand = function(args)
						require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
					end,
				},
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
					{ name = 'nvim_lsp', max_item_count = 12 },
					{ name = 'luasnip', max_item_count = 4 },
				},
				{
					-- Only top 3 most recent buffers
					{ name = 'buffer', max_item_count = 3 },
				})
			},
		}
	end,
	config = function(_, opts)
		require("fidget").setup()
		require("mason").setup()
		require("mason-lspconfig").setup(opts["mason-lspconfig"])
		local cmp = require('cmp')

		cmp.setup(opts.cmp)

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
