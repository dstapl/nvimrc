return {
	"dccsillag/magma-nvim",
	-- build = ":UpdateRemotePlugins",
	build = function (LazyPlugin)
		-- Try to install required python modules
		req_modules = {
			"pynvim", -- remote plugin api
			"jupyter_client", -- interacting with jupyter
			"ueberzug", "Pillow", -- displaying images
			"cairosvg", -- displaying SVG images
			"pnglatex", -- displaying TeX formulae
			"plotly", "kaido", -- displaying plotly figures
			"pyperclip", -- Copying output magma_copy_output
		}

		for _, module_name in ipairs(req_modules) do
			local handle = io.popen("python -m pip install " .. module_name)
			local result = handle:read("a") -- read all?
			handle:close()
			print(module_name .. " install message: " .. result)
		end
		
		vim.cmd(":UpdateRemotePlugins")
	end,
	ft = { "ipynb" },
	lazy = false, -- workaround
	keys = {
		-- Bug: Might have to convert each mapping into this format
		-- https://github.com/dccsillag/magma-nvim/issues/102
		--
		-- vim.cmd[[
		-- nnoremap <expr><silent> <Leader>r  nvim_exec('MagmaEvaluateOperator', v:true)
		-- ]]
		{"<leader>mi", "<cmd>MagmaInit<CR>", desc = "Initialises a runtime for the current buffer" },
		{"<leader>ml", "<cmd>MagmaEvaluateLine<CR>", desc = "Evaluate the current line"},
		{"<leader>mv", "<cmd>MagmaEvaluteVisual<CR>", desc = "Evaluate the current (visually) selected text"},
		{"<leader>mr", "<cmd>MagmaRestart!<CR>", desc = "Shuts down and restarts the current kernel"},
		{"<leader>mo", "<cmd>MagmaEvaluateOperator<CR>", desc = "Re/Evaluate the current cell / given by an operator"},
		{"<leader>mx", "<cmd>MagmaInterrupt<CR>", desc = "Interrupts the current cell. No-op if the cell is not running"},
	},
}
