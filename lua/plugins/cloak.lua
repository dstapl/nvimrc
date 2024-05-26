return {
	"laytan/cloak.nvim",
	opts = {
		enabled = true,
		cloak_character = "*",
		-- The applied highlight group (colors) on the cloaking, see `:h highlight`.
		highlight_group = "Comment",
		cloak_telescope = false,
		patterns = {
			{
				-- Match any file starting with ".env".
				-- This can be a table to match multiple file patterns.
				file_pattern = {
					".env*",
					"*credentials*",
					-- Don't match lspconfig
					-- Can add additional words through `|` operator
					"*.git/config",
				},
				-- Match an equals sign and any character after it.
				-- This can also be a table of patterns to cloak,
				-- example: cloak_pattern = { ":.+", "-.+" } for yaml files.
				cloak_pattern = {
					"=.+",
					":.+",
				},
			},
		},
	},
	config = true,
}
