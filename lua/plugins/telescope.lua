return {
	'nvim-telescope/telescope.nvim', tag = '0.1.6',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function ()
--  	local actions = require("telescope.actions")
		require('telescope').setup({
--			find_files = {
--			mappings = {
--				i = {
--					-- <c-v> is paste on Windows systems
--					["<c-a>"] = actions.select_vertical
--				},
--				n = {
--					-- <c-v> is paste on Windows systems
--					["<c-a>"] = actions.select_vertical
--				}
--			}
--			}
		})

		local builtin = require('telescope.builtin')
		-- vim.keymap.set('n', '<leader>ff', function () builtin.find_files({hidden = true, no_ignore = true}) end)
		vim.keymap.set('n', '<leader>ff', function () builtin.find_files({no_ignore = true}) end)
	end
}
