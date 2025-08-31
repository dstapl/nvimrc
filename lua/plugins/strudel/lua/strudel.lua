local M = {}

-- {channel_id = <id>, buf = <buf_no>, win = <nil or win>}
M.running_animations = vim.defaulttable()

local animations = require("plugins.strudel.lua.text_animations")


local function iterCoroutine(co)
	return function()
		if coroutine.status(co) == "dead" then
			return nil
		end
		local ok, value = coroutine.resume(co)
		if not ok then
			error(value)  -- propagate the error
		end
		return value
	end
end


-- Start Node process and render inline
function M.start()
	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, -- buf=0 for current buffer
	{relative='win', width=12, height=3, bufpos={20,10}} -- scrolls with buf
	)
	-- vim.api.nvim_set_current_buf(buf)

	local strudel_path = vim.fn.stdpath("config") .. "/lua/plugins/strudel/node/strudel.js"
	local job_return_val = vim.fn.jobstart(
		{"node", strudel_path},
		{
			stdout_buffered = false,
			on_stdout = function(_, data, _)
				local waveform = animations.visualize_waveform(data)

				-- Iterate over all values from the waveform
				for scope in iterCoroutine(waveform) do
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, {scope})
				end

				-- Should already be taken care of inside iterCoroutine
				if coroutine.status(waveform) ~= "dead" then
					coroutine.close(waveform)
				end
			end,
			on_exit = function() print("Strudel process exited") end,
		}
	)


	if job_return_val == 0 then
		error("Invalid jobstart arguments for starting strudel server")
		return
	elseif job_return_val == -1 then
		error("Node failed to execute Strudel. Potentially invalid path?" .. strudel_path)
		return
	end

	-- Success so job_return_val is channel-id
	-- Add to running_animations
	M.running_animations[#M.running_animations+1] = {
		channel_id = job_return_val,
		buf = buf,
		win = nil or win
	}
end


-- Kill server and any animation pop-ups
function M.stop()
	for idx, animation_info in ipairs(M.running_animations) do
		local channel_id = animation_info.channel_id

		local status = vim.fn.jobstop(channel_id)

		if status == 0 then
			error("Invalid jobid (" .. channel_id .. "), or job is already closing...")
		else
			-- Animation existed
			-- TODO: will the edge case of already closing come up often...?
			local win_id = animation_info.win
			if win_id ~= nil then
				vim.api.nvim_win_close(win_id, true) -- force close
			end

			-- and kill the buffer related to it
			local buf_id = animation_info.buf_id
			if buf_id ~= nil then
				vim.api.nvim_buf_delete(buf_id, {force = true})
			end

		end

		 -- Remove from table
		M.running_animations[idx] = nil
	end
end

function M.setup(opts)
	if not opts.enabled then return end
	print("Enabled strudel plugin")
end

return M
