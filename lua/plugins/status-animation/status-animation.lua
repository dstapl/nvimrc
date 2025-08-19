--
--
-- HEAVILY INSPIRED BY https://github.com/ElPiloto/significant.nvim
--
--
-- TODO(feat): Create a ui window to scroll through the options for `change_animation`
-- TODO(NOTE / bug): Buffer icons are shared through the Statusline.icon property in ../../config/statusline.lua
--		This is unwanted behaviour but the current API is cleaner. Want to support different buffers having different icons
-- TODO(bug): Buffer animation not cleared if command ran in not the original buffer that the status was set in
-- (e.g., when doing :vsp, the new buffer won't have its status cleared)
--
local PLUGIN_NAME = "status-animation"

local M = {}
local loop = vim.loop

local sprites = require("plugins.status-animation.sprites")

M.started_timer = false
M.should_stop = false
M._loaded_icons = {}

--TODO(ElPiloto): Probably make this so that it doesn't return a
--defaulttable.
M._timers_by_bufnr = vim.defaulttable()
M._should_stop_timers_by_bufnr = vim.defaulttable()
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


local function sprite_placer(bufnr, frame, stop_options)
	-- NOTE: `remove` takes higher priority
	-- TODO: remove and pause are tables?
	local remove = nil
	local pause = nil
	if next(stop_options) ~= nil then
		remove = stop_options["remove"] or false
		pause = stop_options["pause"] or false
	else
		remove = false
		pause = false
	end


	-- Handle status-animation
	if not (remove or pause) then
		-- Update icon
		Statusline.change_icon(frame)
		-- TODO: This is shared across all buffers...
		-- WARNING: So far vim.b isn't working to set the value 
		--	(i.e., vim.b[bufnr]...)
		vim.opt_local.statusline = "%!v:lua.Statusline.active()"
		return
		-- vim.cmd("redrawstatus")
	elseif pause then -- TODO: Just do nothing? (NOP?)

	elseif remove then -- Otherwise restore default vim statusline (no icon)
		-- Restore default statusline
		Statusline.change_icon()
		-- Remove from current animation
		M._current_animation[bufnr] = vim.defaulttable()
	end

	-- Win/BufEnter statusline=%!v:lua.Statusline.active()
	-- Win/BufLeave statusline=%!v:lua.Statusline.inactive()
	-- local buffer_is_hidden = vim.fn.getbufinfo(bufnr)[1].hidden
	local buffer_is_hidden = vim.fn.bufwinnr(bufnr) == -1
	local default_statusline = "ERROR status-animation:default_statusline" -- Placeholder

	if buffer_is_hidden then
		default_statusline = "%!v:lua.Statusline.inactive()"
	else
		default_statusline = "%!v:lua.Statusline.active()"
	end
	vim.opt_local.statusline = default_statusline

end

-- For single instance of an animation (i.e. per buffer)
local function make_loading_status(animation_name)
	local frames = sprites[animation_name]
	return frames
end

function M._start_timer(bufnr, animation_name, repeat_delay)
	-- if not vim.tbl_isempty(M._timers_by_bufnr[bufnr]) then
	-- 	-- TODO: Silent ignore?
	-- 	-- print('Aborting. TODO: Add option to force override timer.')
	-- 	-- --TODO(ElPiloto): Add log message saying we're not turning timer on b/c already on.
	-- 	-- print("TODO: Timer already enabled. Not starting.")
	--
	-- 	-- Delete current timer so it can be remade
	-- 	M._timers_by_bufnr[bufnr] = nil
	--
	-- 	--return false
	-- end

	if M._timers_by_bufnr[bufnr] ~= nil then
		M._timers_by_bufnr[bufnr] = nil
	end


	-- Make sure delay_ms is an integer
	if (repeat_delay == nil)  then
		error("Delay should be a positive integer. Got: nil instead")
	elseif (1 <= repeat_delay) then
		-- Convert to integer
		repeat_delay = math.floor(repeat_delay + 0.5)
	end

	-- TODO: Check this is ok?
	M.clear_stop_options(bufnr)

	if not repeat_delay then
		repeat_delay = 50
	end
	if animation_name then
		local res_frames = make_loading_status(animation_name)
		M._animation_icons[bufnr] = res_frames

	end
	local timer = loop.new_timer()
	local frames = M._animation_icons[bufnr]

	local count = 0

	local MAX_COUNT = 10000

	local function on_interval()
		count = count + 1

		local should_stop = M._should_stop_timers_by_bufnr[bufnr]['should_stop']
		local stop_options = M._should_stop_timers_by_bufnr[bufnr]['stop_options']

		if count > MAX_COUNT or should_stop then
			timer:close()

			-- TODO: This is kind of repeated at the bottom
			local icon = frames[( (count - 1)  % #frames)+1]

			local finish_fn = function()
				sprite_placer(bufnr, icon, stop_options)
			end

			-- TODO: Decrease delay?
			vim.defer_fn(finish_fn, 100)
			M._should_stop_timers_by_bufnr[bufnr]['should_stop'] = false
			M._timers_by_bufnr[bufnr] = nil
		end

		local icon = frames[(count % #frames)+1]
		--Specify line number on first invocation only, for the subsequent
		--invocations we want to update the sign regardless of the line.
		sprite_placer(bufnr, icon, stop_options)
	end

	-- TODO: Why is this so high? (500ms?)
	local launch_delay_ms = 100

	-- table.insert(M._timers_by_bufnr[bufnr], timer)
	M._timers_by_bufnr[bufnr] = timer
	M._current_animation[bufnr] = {animation_name, repeat_delay}
	M._should_stop_timers_by_bufnr[bufnr]['should_stop'] = false
	timer:start(launch_delay_ms, repeat_delay, vim.schedule_wrap(on_interval))

end


function M.start_animated_status(bufnr, animation_name, delay_ms)
	bufnr = bufnr or vim.api.nvim_get_current_buf()


	M._start_timer(bufnr, animation_name, delay_ms)
end

function M.stop_animated_status(bufnr, stop_options)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	M._should_stop_timers_by_bufnr[bufnr] = {
		should_stop = true,
		stop_options = stop_options,
	}
end


function M.stop_current_animation(stop_options)
	-- TODO: Is it more intuitive with `pause` *or* `remove` = true?
	stop_options = stop_options or {pause = true}
	local bufnr = vim.api.nvim_get_current_buf()

	M.stop_animated_status(bufnr, stop_options)
end


-- Convenience function for current buffer
-- TODO: Insert into statusline at custom position, not just start
function M.start_current_animation(animation_name, delay_ms)
	local bufnr = vim.api.nvim_get_current_buf()

	M.start_animated_status(bufnr, animation_name, delay_ms)
end


function M.clear_stop_options(bufnr)
	M._should_stop_timers_by_bufnr[bufnr]['should_stop'] = false
	M._should_stop_timers_by_bufnr[bufnr]['stop_options'] = {pause = false, remove = false}
end

function M.resume_animated_status(bufnr)
	-- Resume animation
	M.clear_stop_options(bufnr)

	-- Get current animation
	if next(M._current_animation[bufnr]) ~= nil then
		local animation_name, delay_ms = unpack(M._current_animation[bufnr])
		-- Actually start the timer again
		M._start_timer(bufnr, animation_name, delay_ms)
	else
		-- TODO: Pause and stop don't error
		-- Should this command error or not?
		error("No current animation to resume")
	end

end

function M.resume_current_animation()
	local bufnr = vim.api.nvim_get_current_buf()

	M.resume_animated_status(bufnr)
end


function M.change_animated_status(bufnr, animation_name, delay_ms)
	-- Remove the current animation
	M.stop_animated_status(bufnr, {remove = true})

	-- TODO: Add 500ms(100ms?) delay between call
	-- Start new animation
	local start_timer = vim.loop.new_timer()
		-- Delay 2000ms and 0 means "do not repeat"
	start_timer:start(300, 0, vim.schedule_wrap(function()
		M.start_animated_status(bufnr, animation_name, delay_ms)
	end
	))
end

function M.change_current_animation(animation_name, delay_ms)
	local bufnr = vim.api.nvim_get_current_buf()

	M.change_animated_status(bufnr, animation_name, delay_ms)
end

M.setup = function (opts) -- config: require(...).setup(opts)
	local starting_animation = opts["starting_animation"]
	local delay = opts["repeat_delay"]

	if starting_animation ~= nil then
		-- Set current animation to the starting one
		M.start_current_animation(starting_animation, delay)
	end
end

return M
