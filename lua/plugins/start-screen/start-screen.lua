local PLUGIN_NAME = "start-screen"
-- local autocmd_group = vim.api.nvim_create_augroup(PLUGIN_NAME, {})
local imDir = vim.fn.stdpath("data") .. "/" .. PLUGIN_NAME

local function choose_image(dir)
	-- TODO: glob is bottleneck
	local cwdContent = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
	local nfiles = #cwdContent
	if nfiles == 0 then return nil end

	local fname = cwdContent[math.random(1, nfiles)]

	return fname
end

local function switch_to_image(category, number, imDir)
	local default_fname = imDir .. "/coconut.jpg"
	local catDir = imDir .. "/" .. category
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

local function setup(opts)
	-- Need to initialise random number generator
	math.randomseed(os.time())

	if not not opts.splash_enabled then
--		vim.api.nvim_create_autocmd("VimEnter", {
--			group = autocmd_group,
--			callback = switch_to_image,
--			once = true
--		})
		local category = opts.category or "Academics"
		local number = opts.number or 1
		switch_to_image(category, number, imDir)
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
