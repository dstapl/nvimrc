return {
	"neovim/nvim-lspconfig",
	-- Update based on installed lsp servers
	event = "BufReadPost",
	ft = {
		"lua",
		"rs",
		"py",
		"zig", "zir", --"zig.zon", -- For zig build system
		"ipynb",
		"js",
		"mc", -- Custom: Monkey C
	},
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
				"zls",
				"eslint",
				},
				handlers = {
					function(server_name) -- Default handler 
						lspconfig[server_name].setup {
							capabilities = capabilities
						}
					end,
					["lua_ls"] = function() -- Disable warnings undefined global vim
						lspconfig.lua_ls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									diagnostics = {
										-- Ignore global variables from Vimscript
										globals = { "vim", "it", "describe", "before_each", "after_each" },
									}
								}
							},
						})
					end,
					zls = function ()
						lspconfig.zls.setup({
							capabilities = capabilities,
							settings = {
								Lua = {
									format_on_save = false, -- true
								},
							}
						})
						vim.g.zig_fmt_autosave = 0 -- Disable location list
					end
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


		-- Setup custom language servers
		-- (Adapted from)
		-- https://www.reddit.com/r/neovim/comments/12abfoh/comment/jzkoiih/
		local lspconfig = require("lspconfig")
		local configs = require("lspconfig.configs")
		if not configs.monkeyc_lsp then
			configs.monkeyc_lsp = {
				default_config = {
					-- TODO: Switch to `python3`?  
					cmd = { 'python', 'C:/Coding/Garmin/monkeyc-lsp/lsp.py' },
					root_dir = lspconfig.util.root_pattern('.git', ''),
					filetypes = { "mc" },
					settings = {} -- TODO: What goes here?
				},
			}
		end
		lspconfig.monkeyc_lsp.setup{}


		local cmp = require('cmp')

		cmp.setup(opts.cmp)
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
