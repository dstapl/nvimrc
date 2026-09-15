-- ============================================================================
-- Unicode character audit
--
-- RED    = invisible / potentially troublesome Unicode
-- YELLOW = other non-ASCII Unicode characters
--
-- The buffer contents are never modified.
-- ============================================================================

local unicode_ns = vim.api.nvim_create_namespace('unicode_audit')

-- ============================================================================
-- Highlight groups
-- ============================================================================

local function set_unicode_highlights()
	vim.api.nvim_set_hl(0, 'UnicodeSuspicious', {
		bg = '#f92672',
		fg = '#ffffff',
	})

	vim.api.nvim_set_hl(0, 'UnicodeNonASCII', {
		bg = '#7e57c2',
		fg = '#ffffff',
	})
end

set_unicode_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
	callback = set_unicode_highlights,
})

-- TODO: Auto generate this probably through a regex
local suspicious = {
	[0x00A0] = true, -- NBSP

	-- Unicode spaces / zero-width / directional marks
	[0x2000] = true, [0x2001] = true, [0x2002] = true,
	[0x2003] = true, [0x2004] = true, [0x2005] = true,
	[0x2006] = true, [0x2007] = true, [0x2008] = true,
	[0x2009] = true, [0x200A] = true, [0x200B] = true,
	[0x200C] = true, [0x200D] = true, [0x200E] = true,
	[0x200F] = true,

	-- Bidirectional formatting controls
	[0x202A] = true, [0x202B] = true, [0x202C] = true,
	[0x202D] = true, [0x202E] = true,

	-- Word joiner / directional isolates
	[0x2060] = true, [0x2061] = true, [0x2062] = true,
	[0x2063] = true, [0x2064] = true, [0x2065] = true,
	[0x2066] = true, [0x2067] = true, [0x2068] = true,
	[0x2069] = true,

	-- BOM / zero-width no-break space
	[0xFEFF] = true,

	-- Interlinear annotation controls
	[0xFFF9] = true, [0xFFFA] = true, [0xFFFB] = true,
}

local function highlight_unicode()
	local bufnr = vim.api.nvim_get_current_buf()

	vim.api.nvim_buf_clear_namespace(bufnr, unicode_ns, 0, -1)

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for row, line in ipairs(lines) do
		local col = 0

		local codepoints = vim.fn.str2list(line)
		for _, codepoint in ipairs(codepoints) do
			local char = vim.fn.nr2char(codepoint)
			local byte_len = #char

			if codepoint > 0x7F then
				local group

				if suspicious[codepoint] then
					group = 'UnicodeSuspicious'
				else
					group = 'UnicodeNonASCII'
				end

				vim.api.nvim_buf_add_highlight(
					bufnr,
					unicode_ns,
					group,
					row - 1,
					col,
					col + byte_len
				)
			end

			col = col + byte_len
		end
	end
end






-- Run on BufEnter straight away
vim.api.nvim_create_autocmd('BufEnter', {
  callback = highlight_unicode,
})

-- Debounce after text-change
local timer = vim.uv.new_timer()

local function highlight_unicode_debounced()
  timer:stop()
  timer:start(1500, 0, vim.schedule_wrap(highlight_unicode))
end


vim.api.nvim_create_autocmd({
  'TextChanged',
  'TextChangedI',
}, {
  callback = highlight_unicode_debounced,
})
