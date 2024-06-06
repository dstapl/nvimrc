local PLUGIN_NAME = "start-screen"
local imDir = vim.fn.stdpath("data") .. "\\" .. PLUGIN_NAME

local function choose_random(arr)
	local length = #arr

	if length == 0 then
		return nil
	end

	return arr[math.random(1, length)]
end

local function choose_image(dir)
	-- TODO: glob is bottleneck
	local cwdContent = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
	return choose_random(cwdContent)
end

local function switch_to_image(category, number, dir)
	local default_fname = dir .. "/coconut.jpg"
	local catDir = dir .. "/" .. category
	local fname = choose_image(catDir) or default_fname

	-- Open the first file
	-- TODO: This alone takes 10-20ms
	vim.cmd.edit(fname)

	-- TODO: Not working
	-- if number > 1 then
	-- 	for _ = 1, number - 1, 1 do
	-- 		-- TODO: Open in spiral pattern
	-- 		-- so number = 4 would split the screen into quarters
	-- 		fname = choose_image(dir) or default_fname
	-- 		vim.cmd.vsplit(fname)
	-- 	end
	-- end
end

--local function remove_value(arr, val)
--	for index, value in ipairs(arr) do
--		if val == value then
--			table.remove(arr, index)
--		end
--	end
--
--	return arr
--end

local function setup(opts)
	-- Need to initialise random number generator
	math.randomseed(os.time())

	if not not opts.splash_enabled then
		local number = opts.number or 1
		local category = opts.category or "Academics"

		if category ~= 'Random' then
			switch_to_image(category, number, imDir)
		else
			-- Chose random category (dir) from list of directories
			local cmd = 'dir /AD-H/B "' .. imDir .. '"'
			local dirs = vim.split(vim.fn.system(cmd), '\n', {trimempty=true})
			local chosen = choose_random(dirs)
			if chosen == nil then
					-- Shouldn't run
					return
			end

			switch_to_image(chosen, number, imDir)
		end

	end
end



if (vim.fn.isdirectory(imDir) == 0) then
	return {setup = function() end}
--executable adds ~10ms of startup time...
--if (vim.fn.executable("ascii-image-converter") == 0) then
--	return { setup = function(opts) end }
else
	return { setup = setup }
end
