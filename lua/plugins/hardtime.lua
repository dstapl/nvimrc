local DISABLED_FILETYPES = {
      "NvimTree",
      "TelescopePrompt",
      "aerial",
      "alpha",
      "checkhealth",
      "dapui*",
      "Diffview*",
      "Dressing*",
      "help",
      "httpResult",
      "lazy",
      "Neogit*",
      "mason",
      "neotest-summary",
      "minifiles",
      "neo-tree*",
      "netrw",
      "noice",
      "notify",
      "prompt",
      "qf",
      "oil",
      "undotree",
      "Trouble",
}

-- Doesn't seem to have any effect
local ADD_FILETYPES = {
	"harpoon",
}

for _, ft in pairs(ADD_FILETYPES) do
	DISABLED_FILETYPES[#DISABLED_FILETYPES+1] = ft
end

return {
	"m4xshen/hardtime.nvim",
	dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
	event = "VeryLazy",
	opts = {
		-- Already shown on statusline
		showmode = false,
		disabled_keys = {
			-- Supposedly disables key
			--["<Leader>"] = {"n", "v"}
			--["<Leader>"] = {},
		},
		hints = {
			["[dcyvV][ia][%(%)]"] = {
				message = function(keys)
					return "Use " .. keys:sub(1, 2) .. "b () and B {} instead of " .. keys
				end,
				length = 3,
			},
			disabled_filetypes = DISABLED_FILETYPES,
		},
	},
	config = true,
}
