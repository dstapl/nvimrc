return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	config = function ()
		local hardtime = require("hardtime")
		hardtime.setup({
			-- Already shown on statusline
			showmode = false,
			disabled_keys = {
				-- Supposedly disables key
				["<Leader>"] = {"n", "v"}
			},
			hints = {
			   ["[dcyvV][ia][%(%)]"] = {
				  message = function(keys)
					 return "Use " .. keys:sub(1, 2) .. "b () and B {} instead of " .. keys
				  end,
				  length = 3,
			   },
			},
		})
	end
}
