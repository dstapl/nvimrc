--local PLUGIN_NAME = vim.fn.expand("%:t:r")
local PLUGIN_NAME = "start-screen"
local autocmd_group = vim.api.nvim_create_augroup(PLUGIN_NAME, {})
local imDir = vim.fn.stdpath("data") .. "\\" .. PLUGIN_NAME

local function choose_image(dir)
	local cwdContent = vim.split(vim.fn.glob(dir .."/*"), '\n', {trimempty=true})
	local nfiles = #cwdContent
	if nfiles == 0 then return nil end

	local fname = cwdContent[math.random(1, nfiles)]

	return fname
end

local function switch_to_image(dir, number)
	local default_fname = imDir .. "\\" .. "Matt.png"
	local fname = choose_image(dir) or default_fname

	-- Open the first file
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
		local default_category = "Academics"
		local category = opts.category or default_category
		local default_number = 1
		local number = opts.number or default_number
		switch_to_image(imDir .. "/" .. category, number)
	end
end

return {
	setup = setup
}
