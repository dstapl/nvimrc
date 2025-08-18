-- https://stackoverflow.com/questions/5375240/a-more-useful-statusline-in-vim
-- and https://nuxsh.is-a.dev/blog/custom-nvim-statusline.html#org38ea4da
-- https://www.reddit.com/r/neovim/comments/s9wyh8/custom_neovim_statusline_in_lua/
local modes = {
	["n"] = "NORMAL",
	["no"] = "NORMAL",
	["v"] = "VISUAL",
	["V"] = "VISUAL LINE",
	[""] = "VISUAL BLOCK",
	["s"] = "SELECT",
	["S"] = "SELECT LINE",
	[""] = "SELECT BLOCK",
	["i"] = "INSERT",
	["ic"] = "INSERT",
	["R"] = "REPLACE",
	["Rv"] = "VISUAL REPLACE",
	["c"] = "COMMAND",
	["cv"] = "VIM EX",
	["ce"] = "EX",
	["r"] = "PROMPT",
	["rm"] = "MOAR",
	["r?"] = "CONFIRM",
	["!"] = "SHELL",
	["t"] = "TERMINAL",
}


local function mode()
	local current_mode = vim.api.nvim_get_mode().mode
	return string.format(" %s ", modes[current_mode]):upper()
end

-- -- LEGACY
-- local function update_mode_colors()
--   local current_mode = vim.api.nvim_get_mode().mode
--   local mode_color = "%#StatusLineAccent#"
--   if current_mode == "n" then
--       mode_color = "%#StatuslineAccent#"
--   elseif current_mode == "i" or current_mode == "ic" then
--       mode_color = "%#StatuslineInsertAccent#"
--   elseif current_mode == "v" or current_mode == "V" or current_mode == "" then
--       mode_color = "%#StatuslineVisualAccent#"
--   elseif current_mode == "R" then
--       mode_color = "%#StatuslineReplaceAccent#"
--   elseif current_mode == "c" then
--       mode_color = "%#StatuslineCmdLineAccent#"
--   elseif current_mode == "t" then
--       mode_color = "%#StatuslineTerminalAccent#"
--   end
--   return mode_color
-- end



local function filepath()
	local fpath = vim.fn.fnamemodify(vim.fn.expand "%", ":~:.:h")
	if fpath == "" or fpath == "." then
		return " "
	end

	return string.format(" %%<%s/", fpath)
end

local function filename()
	local fname = vim.fn.expand "%:t"
	if fname == "" then
		return ""
	end
	return string.format("%s%s ", fname, '%m') -- Modified flag %m
end

local function filetype()
	return string.format(" %s ", vim.bo.filetype):upper()
end

local function lineinfo()
	if vim.bo.filetype == "alpha" then
		return ""
	end
	--	return " %P %l:%c "
	return " %l:%c " -- Line number & col
end

Statusline = {}
Statusline.icon = ""
Statusline.weather = ""

Statusline.change_icon = function(icon)
	Statusline.icon = icon or ""
end

Statusline.change_weather = function(weather_report)
	Statusline.weather = weather_report or ""
end

Statusline.active = function()
	-- icon = icon or ""
	return table.concat {
		Statusline.icon,
		"%#Statusline#",
		--    update_mode_colors(),
		mode(),
		"%#StatusLineNC# ",
		filepath(),
		filename(),
		"%#StatusLineNC#",
		--    lsp(),
		"%=%#StatusLineExtra#",
		Statusline.weather,
		filetype(),
		lineinfo(),
	}
end

function Statusline.inactive()
	return " %F"
end

function Statusline.short()
	return "%#StatusLineNC# TelescopePrompt"
end

-- Autogroups for active, inactive, short
-- vim.api.nvim_exec([[
--   augroup Statusline
--   au!
--   au WinEnter,BufEnter * setlocal statusline=%!v:lua.Statusline.active()
--   au WinLeave,BufLeave * setlocal statusline=%!v:lua.Statusline.inactive()
--   augroup END
-- ]], false)

local statusline_group = vim.api.nvim_create_augroup("Statusline", { clear = true })
vim.api.nvim_create_autocmd({"WinEnter", "BufEnter"}, {
	group = statusline_group,
	callback = Statusline.active,
})

vim.api.nvim_create_autocmd({"WinLeave", "BufLeave"}, {
	group = statusline_group,
	callback = Statusline.inactive,
})
-- au WinEnter,BufEnter,FileType TelescopePrompt setlocal statusline=%!v:lua.Statusline.short()

vim.opt_local.statusline = "%!v:lua.Statusline.active()"
