-- Disable unused LSP clients
return {
	"zeioth/garbage-day.nvim",
	dependencies = "nvim-lspconfig",
	event = "LspAttach",
	-- "start_client", "vim.lsp.start_client"
	--cmd = "start_client",
	lazy = true,
	opts = {
		excluded_lsp_clients = {
			"null-ls",
			"jdtls",
		},

		-- Ensure grace_period > timeout/1000
		grace_period = 60*2, -- Seconds (Minutes)
		wakeup_delay = 600, -- Milliseconds before reactiving
	},
	config = true,
}
