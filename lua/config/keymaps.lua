-- Set <Leader>
vim.g.mapleader = " "


-- Set jump marks on basic vertical motions
local jump_line_threshold = 8
local jump_mark_keys = {"j", "k"}
local jump_mark_modes = {"n", "v"}

for _, key in ipairs(jump_mark_keys) do
	vim.keymap.set(jump_mark_modes, key, function()
		local move_n_lines = vim.v.count
		if move_n_lines > jump_line_threshold then
			-- Set mark if over the threshold
			vim.cmd("normal! m'")
		end
		vim.cmd("normal! " .. move_n_lines .. key)
	end, {silent = true})
end

-- Allow <C-i> <C-o> navigation while in visual mode
-- Helper functions
local function get_term_key(key)
	-- See :h nvim_replace_termcodes
	return vim.api.nvim_replace_termcodes(key, true, false, true)
end

local function pos_eq(pos1, pos2)
	-- Lengths not equal (Though they should be)
	if #pos1 ~= #pos2 then return false end

	for idx, _ in ipairs(pos1) do
		if pos1[idx] ~= pos2[idx] then return false end
	end

	-- If pos2 hasn't been exhausted for some reason
	if next(pos2) then return false end

	-- Element wise equal without nesting
	return true
end

local function get_char_pos(mark)
	local bigpos = vim.fn.getcharpos(mark)
	return {bigpos[1], bigpos[2], bigpos[3], bigpos[4]}
end

local function clamp_cursor_pos(pos, win)
	if pos_eq(pos, {0,0,0,0}) then
		pos = get_char_pos(".")
	end

	local line = pos[2]
	local col = pos[3]
	local lines = vim.api.nvim_buf_get_lines(win, line - 1, line, true)
	if (#lines == 0) then
		-- Line doesn't exist, return current cursor
		return get_char_pos(".")
	end
	local line_len = #lines[1]
	if col > line_len + 1 then
		col = line_len + 1
	end


	return {pos[1], line, col, pos[4]}
end

-- TODO(BUG) *SOMETIMES* Start/end pos gets replaced by another mark
local function visual_jump(key)
	local mode = vim.fn.mode()
	mode = mode:gsub("CTRL-V", "") -- Windows

	-- Save visual selection start and end marks
	local current_win_nr = 0
	local start_pos = vim.fn.getpos("'<")
	start_pos = clamp_cursor_pos(start_pos, current_win_nr)

	local end_pos = vim.fn.getpos("'>")
	end_pos = clamp_cursor_pos(end_pos, current_win_nr)


	-- Perform jump
	local esc = get_term_key("<Esc>")
	local jump = get_term_key(key)
	vim.cmd("normal! " .. esc .. jump)

	-- Restore visual selection marks
	vim.fn.setpos("'<", start_pos)
	vim.fn.setpos("'>", end_pos)

	-- Current cursor position
	end_pos = clamp_cursor_pos(get_char_pos("."), current_win_nr)

	-- Re-enter visual mode with previous selection
	-- Move cursor to start position
	vim.api.nvim_win_set_cursor(current_win_nr, {start_pos[2], start_pos[3]})
	vim.cmd("normal! " .. mode)
	-- Move to end pos
	vim.api.nvim_win_set_cursor(current_win_nr, {end_pos[2], end_pos[3]})
end

local nav_keys = {"<C-o>", "<Tab>"} -- CTRL-i conflicts with Tab in visual mode
for _, key in ipairs(nav_keys) do
	vim.keymap.set("v", key, function()
		visual_jump(key)
	end, {silent = false})
end


-- Ext copy / paste
vim.keymap.set({"n","v"},"<Leader>y",[["+y]])

vim.keymap.set({"n","v"},"<Leader>p",[["+p]])

-- CTRL+<BS> delete word
vim.keymap.set("i", "", "db")
vim.keymap.set("n", "", "db")

-- Blackhole delete
vim.keymap.set("n", "<Leader>d", [["_P]])

-- Cloak and colour picker (ccc) 
-- TOOD: This has stopped working
--vim.keymap.set("n", "<Leader>cl", "<cmd>CloakPreviewLine<CR>")
-- Replaced with this for now instead
vim.keymap.set("n", "<Leader>cl", "<CMD>CloakToggle<CR>")

-- LSP
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename)

-- Replace highlighted word in visual mode
-- Need to stop <leader>(<space>) moving the cursor
vim.keymap.set('v', ' ', '')
vim.keymap.set('v', '<Leader>r', '"hy:%s/<C-r>h//g<left><left>')


-- Maybe get rid of this...Only really for closing start-screen
vim.keymap.set("n", "<ESC><ESC>", "<CMD>bd<CR>")


-- Open system file-explorer at current buffer directory
vim.keymap.set("n", "<Leader>ex", "<CMD>!start explorer %:h<CR><CR>")
