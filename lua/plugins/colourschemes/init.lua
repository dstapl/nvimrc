local THEMES_PATH = "plugins.colourschemes.themes."

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
	return true
end


local function get_file_name(file)
	local fp = file:match("[^%\\%/]*%.lua$") -- Windows \\, Linux \/
	return fp:sub(0, #fp - 4) -- Assumes only one extension .lua
end


local function get_all_cs_names()
	local dir = vim.fn.stdpath("config") .. "/lua/plugins/colourschemes/themes"
	local css  = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})

	local css_names = {}

	-- Read in filenames and exclude "init*" files
	for _, filepath in ipairs(css) do
		local name = get_file_name(filepath)

		if name ~= "init" then
			css_names[#css_names+1] = name
		end

	end

	return css_names
end

local function load_all_cs()
	local cs_names = get_all_cs_names();
	local load_css = {};

	for _, name in ipairs(cs_names) do
		load_css[#load_css+1] = require(THEMES_PATH .. name)
	end

	return load_css -- List of colourschemes
end

local function _choose_cs(name)
	local css = load_all_cs()
	local found = false

	for i, M in ipairs(css) do
		-- Assumes name is at the start
		if M[1]:find(name) == nil then
			--css[i].enabled = false
			css[i].lazy = true
		else
			found = true
		end
	end
	return {css, found}
end



local function choose_cs(name)
	local cs_name = name or "catppuccin" -- Default backup theme

	local all = _choose_cs(cs_name)
	local css = all[1]
	local found = all[2]

	if found == true then
		return css
	end

	-- Use default (defined) colours
	-- If colourscheme is not in the list of files
	print("Invalid colourscheme: " .. cs_name)
	my_colours()
	return {}
end



local THEMES = get_all_cs_names(); -- Load once per nvim session
-- Create auto-completion list from `/Themes` folder
local function theme_complete(arglead, cmdline, cursorpos)
	local matches = {}
	for _, theme_name in ipairs(THEMES) do           -- iterate over the keys
		-- vim.pesc(...) == vim.fn.escape(arglead, '\\.^$')
		if theme_name:find('^' .. vim.pesc(arglead)) then
			table.insert(matches, theme_name)
		end
	end
	table.sort(matches)
	return matches                           -- MUST return a Lua list of strings
end

function ColourMe(name)
	local status, M = pcall(require, THEMES_PATH .. name)

	if not status then
		print("Invalid colourscheme: " .. name)
		return
	end

	local opts = M.opts or {}

	-- opts can be table *or* function
	if type(opts) == "function" then
		opts = opts()
	end

	M.config(nil,opts)
end



vim.api.nvim_create_user_command("ColourMe",
	function (opts)
		ColourMe(opts.args)
	end,
	{nargs = 1, complete = theme_complete}
)


-- E.g., "catppuccin", "vscode"
return choose_cs("vscode")
