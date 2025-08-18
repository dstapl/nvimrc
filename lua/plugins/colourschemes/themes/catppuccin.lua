local cs = {
	"catppuccin/nvim",
	name = "catppuccin",
	lazy = false,
	-- Only with lazy = true
	priority = 1000
}


-- local mocha = {
-- 	rosewater = "#f5e0dc",
-- 	flamingo = "#f2cdcd",
-- 	pink = "#f5c2e7",
-- 	mauve = "#cba6f7",
-- 	red = "#f38ba8",
-- 	maroon = "#eba0ac",
-- 	peach = "#fab387",
-- 	yellow = "#f9e2af",
-- 	green = "#a6e3a1",
-- 	teal = "#94e2d5",
-- 	sky = "#89dceb",
-- 	sapphire = "#74c7ec",
-- 	blue = "#89b4fa",
-- 	lavender = "#b4befe",
-- 	text = "#cdd6f4",
-- 	subtext1 = "#bac2de",
-- 	subtext0 = "#a6adc8",
-- 	overlay2 = "#9399b2",
-- 	overlay1 = "#7f849c",
-- 	overlay0 = "#6c7086",
-- 	surface2 = "#585b70",
-- 	surface1 = "#45475a",
-- 	surface0 = "#313244",
-- 	base = "#1e1e2e",
-- 	mantle = "#181825",
-- 	crust = "#11111b",
-- }


cs.opts = {
	transparent_background = false,
	-- Show ~ lines at the end of buffer
	show_end_of_buffer = true,
	color_overrides = {
		-- all = {
		-- 	text = "#ffffff",
		-- },
		mocha  = {
			-- Left pane (Number pane)
			--base = "#000000",
			-- General line numbers
			surface1 = "#454659",
			-- Current line number
			lavender = "#b4befe",
			base = "#12121c"
		},
	},
	compile_path = vim.fn.stdpath("cache") .. "catppuccin"
	--Not sure if these have any effect
	--integrations = {
	--	telescope = true,
	--	harpoon = true,
	--}
}


-- Overrides
cs.config = function (_, opts)
	-- if config.colorscheme ~= "catppuccin" then
	-- 	return false
	-- end
	require("catppuccin").setup(opts)

	-- Set base Catppuccin colourscheme
	vim.cmd.colorscheme("catppuccin-mocha")

end


return cs
