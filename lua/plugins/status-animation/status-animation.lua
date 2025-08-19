--
--
-- HEAVILY INSPIRED BY https://github.com/ElPiloto/significant.nvim
--
--
-- TODO(feat): Create a ui window to scroll through the options for `change_animation`
-- TODO(NOTE / bug): Animations are stored - and can be cancelled - independently per window, which is good but:
--		BUG 1: They disappear from the original window when the cursor is on a different window (Only showing when the cursor is on the animated window)
--		BUG 2: Animations of a current window eventually (visually) override the animations of another window. Likely linked to BUG 1. To reproduce:
--			1. Make new Windows A and B that have no animations. E.g., through :new then :vsp
--			2. Go to B and start an animation
--			3. Go to A and start an animation (Note how window B's animation has disappeared r.e. BUG 1)
--				Note how both A and B are showing window A's animation (current window takes priority)
--			5. Go back to B and note how both A and B are showing window B's animation
--			6. Cancelling window B's animation works fine, and removes it visually from both windows.
--			7. Going back to window A only shows the animation on window A not window B anymore
--			
--		This is unwanted behaviour but the current API is cleaner. Want to support different buffers having different icons
local PLUGIN_NAME = "status-animation"

local M = {}
-- vim.loop is deprecated
local loop = vim.uv

local sprites = require("plugins.status-animation.sprites")

--TODO(ElPiloto): Probably make this so that it doesn't return a
--defaulttable.
M._timers_by_winid = vim.defaulttable()
M._should_stop_timers_by_winid= vim.defaulttable()
M._animation_icons = vim.defaulttable()
M._current_animation = vim.defaulttable() -- {name, delay}

local ANIM_SIGN_PREFIX = 'AnimationIcon'

local text_hls = {
	'markdownH3',
	'markdownH4',
	'markdownH5',
	'markdownH6',
	'markdownH1',
	'markdownH2',
}


local function print_table(table, sep)
	sep = sep or "\n"
	local big_string = ""
	for _, data in ipairs(table) do
		big_string = big_string .. data .. sep
	end
	print(big_string)
end


local function sprite_placer(winid, frame, stop_options)
	-- Check window actually exists right now
	if not vim.api.nvim_win_is_valid(winid) then
		-- Set signal to remove animation, stopping timer
		M.stop_animated_status(winid, {pause = false, remove = true})
		return
	end


	-- NOTE: `remove` takes higher priority
	-- TODO: remove and pause are tables?
	local remove = nil
	local pause = nil

	if next(stop_options) ~= nil then
		remove = stop_options["remove"]
		pause = stop_options["pause"]
    end
    remove = remove or false
    pause = pause or false


	-- Handle status-animation
	if not (remove or pause) then
		-- -- Update icon
		-- Statusline.change_icon(frame)
		-- -- TODO: This is shared across all buffers...
		-- -- WARNING: So far vim.b isn't working to set the value 
		-- --	(i.e., vim.b[bufnr]...)
		-- vim.opt_local.statusline = "%!v:lua.Statusline.active()"
		-- return
		-- -- vim.cmd("redrawstatus")

        vim.w[winid].statusline_icon = frame
        -- vim.api.nvim_set_option_value("statusline", "%!v:lua.Statusline.active()", {win = winid})
        -- return
	-- Remove takes priority
	elseif remove then -- Otherwise restore default vim statusline (no icon)
		-- -- Restore default statusline
		-- Statusline.change_icon()
		-- -- Remove from current animation
		-- M._current_animation[bufnr] = vim.defaulttable()
        vim.w[winid].statusline_icon = ""
        M._current_animation[winid] = vim.defaulttable()

		-- And close timer
		local timer = M._timers_by_winid[winid]
		-- TODO: BUG CLOSE NOT AVAILABLE ON A TABLE VALUE

		local timer_is_set = type(timer) == "userdata"

		if timer_is_set and (not timer:is_closing()) then
			timer:close()
		end

		-- TODO: Move inside the if-block?
		M._timers_by_winid[winid] = nil
	elseif pause then
		-- TODO: Just do nothing? (NOP?)
	end


	-- Win/BufEnter statusline=%!v:lua.Statusline.active()
	-- Win/BufLeave statusline=%!v:lua.Statusline.inactive()

	-- TODO: Can windows be hiddden/is this useful anymore?
    -- local buffer_is_hidden = vim.fn.winbufnr(winid) == -1
    -- local default_statusline = buffer_is_hidden and "%!v:lua.Statusline.inactive()" or "%!v:lua.Statusline.active()"
    -- vim.api.nvim_set_option_value("statusline", default_statusline, {win = winid})
    vim.api.nvim_set_option_value("statusline", "%!v:lua.Statusline.active()", {win = winid})
end

-- For single instance of an animation (i.e. per buffer)
local function make_loading_status(animation_name)
	local frames = sprites[animation_name]
	return frames
end

function M._start_timer(winid, animation_name, repeat_delay)
	if not vim.tbl_isempty(M._timers_by_winid[winid]) then
		-- TODO: Silent ignore?
		-- print('Aborting. TODO: Add option to force override timer.')
		-- --TODO(ElPiloto): Add log message saying we're not turning timer on b/c already on.
		-- print("TODO: Timer already enabled. Not starting.")

		-- Delete current timer so it can be remade
		M._timers_by_winid[winid] = nil

		--return false
	end

	-- Check window actually exists right now
	if not vim.api.nvim_win_is_valid(winid) then
		return
	end


	if M._timers_by_winid[winid] ~= nil then
		M._timers_by_winid[winid] = nil
	end


	-- Make sure delay_ms is an integer
	if (repeat_delay == nil)  then
		error("Delay should be a positive integer. Got: nil instead")
	elseif (repeat_delay >= 1) then
		-- Convert to integer
		repeat_delay = math.floor(repeat_delay + 0.5)
    else
        -- Default option
        repeat_delay = 50
    end

	-- TODO: Check this is ok?
	M.clear_stop_options(winid)

	if animation_name then
		local res_frames = make_loading_status(animation_name)
		M._animation_icons[winid] = res_frames

	end
	local timer = loop.new_timer()

	-- table.insert(M._timers_by_bufnr[bufnr], timer)
	M._timers_by_winid[winid] = timer

	local frames = M._animation_icons[winid]

	local count = 0
	local MAX_COUNT = 10000

	local function on_interval()
		count = count + 1

		local should_stop = M._should_stop_timers_by_winid[winid]['should_stop']
		local stop_options = M._should_stop_timers_by_winid[winid]['stop_options']

		if count > MAX_COUNT or should_stop then
			-- TODO: This is kind of repeated at the bottom
			local icon = frames[( (count - 1)  % #frames)+1]

			local finish_fn = function()
				sprite_placer(winid, icon, stop_options)
			end

			-- TODO: Decrease delay?
			vim.defer_fn(finish_fn, 100)
			M._should_stop_timers_by_winid[winid]['should_stop'] = false

		end

		local icon = frames[(count % #frames)+1]
		--Specify line number on first invocation only, for the subsequent
		--invocations we want to update the sign regardless of the line.
		sprite_placer(winid, icon, stop_options)
	end

	-- TODO: Why is this so high? (500ms?)
	local launch_delay_ms = 100

	M._current_animation[winid] = {animation_name, repeat_delay}
	M._should_stop_timers_by_winid[winid]['should_stop'] = false
	timer:start(launch_delay_ms, repeat_delay, vim.schedule_wrap(on_interval))
end


function M.start_animated_status(winid, animation_name, delay_ms)
	winid = winid or vim.api.nvim_get_current_win()
	M._start_timer(winid, animation_name, delay_ms)
end

function M.stop_animated_status(winid, stop_options)
	winid = winid or vim.api.nvim_get_current_win()
	M._should_stop_timers_by_winid[winid] = {
		should_stop = true,
		stop_options = stop_options,
	}
end


function M.stop_current_animation(stop_options)
	-- TODO: Is it more intuitive with `pause` *or* `remove` = true?
	stop_options = stop_options or {pause = true}
	local winid = vim.api.nvim_get_current_win()

	M.stop_animated_status(winid, stop_options)
end


-- Convenience function for current buffer
-- TODO: Insert into statusline at custom position, not just start
function M.start_current_animation(animation_name, delay_ms)
	local winid = vim.api.nvim_get_current_win()

	M.start_animated_status(winid, animation_name, delay_ms)
end


function M.clear_stop_options(winid)
	M._should_stop_timers_by_winid[winid]['should_stop'] = false
	M._should_stop_timers_by_winid[winid]['stop_options'] = {pause = false, remove = false}
end

function M.resume_animated_status(winid)
	-- -- Resume animation
	-- M.clear_stop_options(winid)
	--
	-- -- Get current animation
	-- if next(M._current_animation[winid]) ~= nil then
	-- 	local animation_name, delay_ms = unpack(M._current_animation[winid])
	-- 	-- Actually start the timer again
	-- 	M._start_timer(winid, animation_name, delay_ms)
	local window_has_animation = next(M._current_animation[winid]) ~= nil
	if window_has_animation then
		M.clear_stop_options(winid)
	else
		-- TODO: Pause and stop don't error
		-- Should this command error or not?
		error("No current animation to resume")
	end

end

function M.resume_current_animation()
	local winid = vim.api.nvim_get_current_win()

	M.resume_animated_status(winid)
end


function M.change_animated_status(winid, animation_name, delay_ms)
	-- Remove the current animation
	M.stop_animated_status(winid, {remove = true})

	-- TODO: Add 500ms(100ms?) delay between call
	-- Start new animation
	local start_timer = loop.new_timer()
		-- Delay 2000ms and 0 means "do not repeat"
	-- TODO: Stop this timer? Does this just keep running until nvim shutdown?
	start_timer:start(300, 0, vim.schedule_wrap(function()
		M.start_animated_status(winid, animation_name, delay_ms)
	end
	))
end

function M.change_current_animation(animation_name, delay_ms)
	local winid = vim.api.nvim_get_current_win()

	M.change_animated_status(winid, animation_name, delay_ms)
end



-- -- Helper to copy animation state to new window
-- local function copy_animation_to_new_win(src_winid, dest_winid)
-- 	if (src_winid == nil) or (dest_winid == nil) then
-- 		-- No copying
-- 		return
-- 	end
--     if vim.w[src_winid].statusline_icon then
--         vim.w[dest_winid].statusline_icon = vim.w[src_winid].statusline_icon
--     end
--     if M._current_animation[src_winid] then
-- 		-- BUG:Table index is nil when doing ctrl+k on vim to get diagnostics from lsp
-- 		-- Probably need to check if dest_winid even exists
--         M._current_animation[dest_winid] = M._current_animation[src_winid]
--         M._animation_icons[dest_winid] = M._animation_icons[src_winid]
--         -- Optionally start timer for new window
--         -- local animation_name, delay = unpack(M._current_animation[src_winid])
--         -- M._start_timer(dest_winid, animation_name, delay)
--     end
-- end
--
-- -- Autocmd for new window creation (split)
-- vim.api.nvim_create_autocmd("WinNew", {
--     callback = function(args)
--         local new_winid = args.win()
--         local cur_winid = vim.api.nvim_get_current_win()
--         copy_animation_to_new_win(cur_winid, new_winid)
--     end,
-- })
--
--

M.setup = function (opts) -- config: require(...).setup(opts)
	local starting_animation = opts["starting_animation"]
	local delay = opts["repeat_delay"]

	if starting_animation ~= nil then
		-- Set current animation to the starting one
		M.start_current_animation(starting_animation, delay)
	end
end

return M
