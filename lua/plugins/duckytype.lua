return {
	"kwakzalver/duckytype.nvim",
	keys = "<Leader>tt",
	cmd="DuckyType",
	opts = {
		number_of_words = 25,
		highlight = {
			good = "Comment",
			bad = "Error",
			--remaining = "Todo",
		},
		window_config = {
			border = "shadow", -- "None"
		},
	},
	lazy = true,
	--config = true,
	config = function (_, opts)
		require("duckytype").setup(opts)

		-- Set keybind to start, and restart
		vim.keymap.set("n", "<Leader>tt", "<cmd>DuckyType<CR>")
		vim.keymap.set("n", "<Leader>tq", "<cmd>q<CR>")
		vim.keymap.set("n", "<Leader>tr", "<cmd>q<CR><cmd>DuckyType<CR>")
	end
}
