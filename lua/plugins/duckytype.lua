return {
	"kwakzalver/duckytype.nvim",
	keys = "<Leader>tt",
	cmd = "DuckyType",
	opts = {
		number_of_words = 25,
		highlight = {
			good = "Comment",
			bad = "Error",
			--remaining = "Todo",
		},
		window_config = {
			border = "none", -- "shadow", "none"
		},
	},
	lazy = true,
	config = function (_, opts)
		require("duckytype").setup(opts)

		vim.keymap.set("n", "<Leader>tt", "<cmd>DuckyType<CR>")
		-- Redundant...
		vim.keymap.set("n", "<Leader>tq", "<cmd>q<CR>")
		-- <CR> seems to not work within a macro...?
		-- vim.keymap.set("n", "<Leader>tr", "<CR>")
		vim.keymap.set("n", "<Leader>tr", "<cmd>q<CR><cmd>DuckyType<CR>")
	end
}
