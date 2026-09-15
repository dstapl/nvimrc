local base_dir = nil
local project_dir = nil

local os_name = vim.loop.os_uname().sysname
if os_name:find("Windows") then
	base_dir = "C://Coding//Lua//"
else
	base_dir = vim.env.HOME .. "/.src/personal/lua/"
end

if base_dir ~= nil then
	project_dir = base_dir .. "sudoku.nvim"
end


local M = {
	--'jim-fx/sudoku.nvim',
    -- 'blamblamdan/sudoku.nvim',
    -- dir = "C://Coding//Lua//sudoku.nvim",
	dir = project_dir,
    cmd = "Sudoku",
    opts = {
        persist_settings = true, -- safe the settings under vim.fn.stdpath("data"), usually ~/.local/share/nvim,
        persist_games = false, -- persist a history of all played games

        -- default_mappings = true, -- if set to false you need to set your own, like the following:
        default_mappings = false,
        mappings = {
            { key = "<C-a>",     action = "increment" },
            { key = "<C-x>",     action = "decrement" },
            { key = "f",	action = "selectPrefix"},
        },

        custom_highlights = {
            hint_cell = { fg = "white", bg = "yellow" },
            same_number = { fg = "white", gui = "bold" },
            set_number = { fg = "white", gui = "italic" },
            error = { fg = "white", bg = "#843434" },
        },
    },
}
return M
