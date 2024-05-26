return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	keys = {"<C-e>", "<leader>aa", "<leader>ad",},
	opts = {
		-- TODO: Not working currently
		-- 	general = {
		-- 		-- Save list in memory. Gets deleted when Nvim is quit.
		-- 		encode = false,
		-- 	},
	},
	config = function (_, opts)
		local harpoon = require('harpoon')
		harpoon:setup(opts)

		vim.keymap.set("n", "<leader>aa", function() harpoon:list():add() end)
		vim.keymap.set("n", "<leader>ad", function() harpoon:list():remove() end)

		vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

	end,
}
