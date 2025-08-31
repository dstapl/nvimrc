local M = {}


-- **Helpers**

-- Map float [-1,1] to Unicode block char
local function amp_to_char(x)
  local levels = {"▁","▂","▃","▄","▅","▆","▇","█"}
  local idx = math.floor((x+1)/2 * (#levels-1)) + 1
  return levels[idx]
end

-- Convert waveform to ASCII string
local function waveform_to_line(waveform)
  local chars = {}
  for _, sample in ipairs(waveform) do
    table.insert(chars, amp_to_char(sample))
  end
  return table.concat(chars)
end




-- TODO: Hooks into current audio
--	Taking input in function argument
function M.visualize_waveform(data)
	local co = coroutine.create(function ()
		for _, line in ipairs(data) do
			if line ~= "" then
				local ok, frame = pcall(vim.fn.json_decode, line)
				if ok and frame.waveform then
					local scope = waveform_to_line(frame.waveform)
					coroutine.yield(scope)
				end
			end
		end
	end
	)

	return co
end


-- TODO: Piano roll



function M.setup(opts)
	if not opts.enabled then return end
	print("Enabled strudel plugin")
end

return M
