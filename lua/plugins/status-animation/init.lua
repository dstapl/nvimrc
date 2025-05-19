return {
	dir = vim.fn.stdpath("config") .. "/lua/plugins/status-animation",
	main = "plugins.status-animation.status-animation",
	lazy = false,
	opts = require("plugins.status-animation.opts"),
	config = function(_, opts)
		local animation = require("plugins.status-animation.status-animation")
		local sprites = require("plugins.status-animation.sprites")
		animation.setup(opts)

		local PREFIX = "Animation"


		-- Create a completion list based on sprites file
		-- https://github.com/nvim-lua/completion-nvim/wiki/custom-completion-source
		-- local function getCompletionItems(ArgLead, CmdLine, CursorPos)
		-- 	print(ArgLead, CmdLine, CursorPos)
		-- 	local complete_items = {}
		-- 	-- define your total completion items
		--
		-- 	-- find matches items and put them into complete_items
		-- 	for animation_name, _ in pairs(sprites) do
		-- 		-- score_func is a fuzzy match scoring function
		-- 		local score = score_func(prefix, animation_name)
		-- 		if score < #prefix/2 then
		-- 			table.insert(complete_items, {
		-- 				word = animation_name,
		-- 				kind = 'animation name', -- TODO: Have space or not?
		-- 				icase = 0, -- Case *sensitive*
		-- 				dup = 1,
		-- 				empty = 0, -- Don't want empty names
		-- 			})
		-- 		end
		-- 	end
		-- 	return complete_items
		-- end


		local function sprite_complete(arglead, cmdline, cursorpos)
			local matches = {}
			for k, _ in pairs(sprites) do           -- iterate over the keys
				-- vim.pesc(...) == vim.fn.escape(arglead, '\\.^$')
				if k:find('^' .. vim.pesc(arglead)) then
					table.insert(matches, k)
				end
			end
			table.sort(matches)
			return matches                           -- MUST return a Lua list of strings
		end

		vim.api.nvim_create_user_command(PREFIX.."Change",
			function (commands)
				local args = commands["fargs"]

				-- Need to check if user has supplied enough arguments
				-- Error if not 2
				local supplied_nargs = 0
				for _ in pairs(args) do supplied_nargs = supplied_nargs + 1 end


				local name, delay = nil, nil
				local default_delay = 300 -- (ms)

				if supplied_nargs ~= 2 then
					if supplied_nargs == 1 then
						name, delay = unpack(args), default_delay
					else
						error("Invalid number of arguments. Expected 2. Got `" .. supplied_nargs .. "` instead.")
					end
				else
					name, delay = unpack(args)
				end
				local delay_num = tonumber(delay)

				-- Check that the name is actually in the list of sprites
				if sprites[name] == nil then
					error("Unknown animation name: " .. name)
				end

				if (delay_num == nil)  then
					error("Delay should be a positive integer. Got: `"..delay .. "` instead")
				elseif (1 <= delay_num) then
					-- Convert to integer
					delay_num = math.floor(delay_num + 0.5)
					animation.change_current_animation(name, delay)
				end
			end,
			{nargs = "+", complete = sprite_complete}
		)

		vim.api.nvim_create_user_command(PREFIX .. "Stop",
		function ()
			animation.stop_current_animation({remove = true})
		end, {nargs = 0})

		vim.api.nvim_create_user_command(PREFIX .. "Pause",
		function ()
			animation.stop_current_animation({pause = true})
		end, {nargs = 0})


		vim.api.nvim_create_user_command(PREFIX .. "Resume",
		function ()
			animation.resume_current_animation()
		end, {nargs = 0})

	end,
	keys = {
		{"<leader>asdlkfjsldkfj"}

	},
	priority = 1000,
}
