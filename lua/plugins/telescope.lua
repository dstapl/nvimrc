return {
	'nvim-telescope/telescope.nvim', tag = '0.1.6',
	dependencies = { 'nvim-lua/plenary.nvim' },
	keys = "<Leader>ff",
	opts = {
--		find_files = {
--		mappings = {
--			i = {
--				-- <c-v> is paste on Windows systems
--				["<c-a>"] = actions.select_vertical
--			},
--			n = {
--				-- <c-v> is paste on Windows systems
--				["<c-a>"] = actions.select_vertical
--			}
--		}
--		}
--		defaults = {
--			For linux users
--			preview = {
--				filesize_hook = function(filepath, bufnr, opts)
--					local max_bytes = 10000
--					-- powershell Get-Content README.md -Head 4
--					-- This is so inefficient...
--					local cmd ={"head", "-c", max_bytes, filepath}
--					require('telescope.previewers.utils').job_maker(cmd, bufnr, opts)
--				end
--			},
--		}
	},
	config = function (_, opts)
--  	local actions = require("telescope.actions")
		require('telescope').setup(opts)

		local builtin = require('telescope.builtin')
--		vim.keymap.set('n', '<leader>ff', function () builtin.find_files({hidden = true, no_ignore = true}) end)
		vim.keymap.set('n', '<leader>ff', function () builtin.find_files({no_ignore = true}) end)
	end
}
