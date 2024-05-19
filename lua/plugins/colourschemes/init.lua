local function my_colours()
	-- Highlight options are available at
	-- :so $VIMRUNTIME/syntax/hitest.vim
	--
	-- NC terms are for inactive windows
	-- Change background of number pane (Left pane)
	local black_base = "#000000"
	vim.cmd([[ hi LineNr guibg=]] .. black_base)
	vim.cmd([[ hi CursorLineNr guibg=]] .. black_base)
	vim.cmd([[ hi SignColumn guibg=]] .. black_base)
	-- Change statusline
	-- StatusLine, StatusLineNC, NvimTreeStatuslineNc, NeoTreeStatusLineNC
	-- Defaults:
	-- guifg=#cdd6f4 guibg=#181825
	-- guifg=#454659 guibg=#181825 
	-- guifg=#181825 guibg=#181825
	-- guifg=#181825 guibg=#181825
	local black_accent = "#11111b"
	local white_accent = "#cdd6f4"
	vim.cmd([[ hi StatusLine guibg=]] .. white_accent .. " guifg=" .. black_accent)
	vim.cmd([[ hi StatusLineNC guibg=]] .. black_accent .. " guifg=" .. white_accent)
end

local function contains(haystack, needle)
	for _, el in ipairs(haystack) do
		if el == needle then
			return true
		end
	end
end

my_colours()

local function choose_cs(name)
	local dir = vim.fn.stdpath("config") .. "\\lua\\plugins\\colourschemes"
	local css  = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
	-- Need to ignore current file
	local fullpath = dir .. "\\".. name .. ".lua"
	if (name ~= "init") and contains(css, fullpath) then
		return require("plugins.colourschemes." .. name)
	end
end

local cs = "catppuccin"
local M =  choose_cs(cs)
if M == nil then
	error("Invalid colourscheme: " .. cs)
else
	return M
end
