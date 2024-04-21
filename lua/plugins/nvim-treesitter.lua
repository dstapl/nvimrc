return {
	'nvim-treesitter/nvim-treesitter', 
	build = ":TSUpdate",
	config = function ()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"vimdoc", "lua", "rust", "bash"
			},
			
			sync_install = false,

			-- Set to false if `tree-sitter` CLI is not intsalled locally
			auto_install = true,
			
		})
	end
}

