return {
	'uga-rosa/ccc.nvim',
	-- TODO: Make sure these are up-to-date
	keys = {"<Leader>cp", "<Leader>ch"},
	opts = {
		highlighter = {
			-- Auto-enable on BufEnter
			auto_enable = false,
			-- Map written words* to highlighter colours
			-- * based on built-in lsp
			-- lsp = true,
		},
	},
	config = function (_, opts)
		require("ccc").setup(opts)

		vim.keymap.set("n", "<Leader>cp", "<cmd>CccPick<CR>")
		vim.keymap.set("n", "<Leader>ch", "<cmd>CccHighlighterToggle<CR>")
	end
}
