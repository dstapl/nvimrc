return {
	"neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			--build = "make install_jsregexp"
		},
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",

		-- Disable unused LSP clients
		{
			  "zeioth/garbage-day.nvim",
			  dependencies = "neovim/nvim-lspconfig",
			  event = "VeryLazy",
			  opts = {
				excluded_lsp_clients = {
					"null-ls",
					"jdtls",
				},

				-- Ensure grace_period > timeout/1000
				grace_period = 60*2, -- Seconds (Minutes)
				wakeup_delay = 600, -- Milliseconds before reactiving
			  }
		},
    },
	config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend( -- Might change per system
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = { -- Define LSPs
                "lua_ls",
                "rust_analyzer",
				-- "pyright",
            },
            handlers = {
                function(server_name) -- Default handler 
                    require("lspconfig")[server_name].setup {
                        capabilities = capabilities
                    }
                end,
				["lua_ls"] = function() -- Disable warnings undefined global vim
                    require("lspconfig").lua_ls.setup {
                        capabilities = capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
-- Ignore global variables from Vimscript
globals = { "vim", "it", "describe", "before_each", "after_each" },
                                }
                            }
                        }
                    }
                end,
            }
        })
        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
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
            }, {
                -- Only top 3 most recent buffers
                { name = 'buffer', max_item_count = 3 },
            })
        })

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
