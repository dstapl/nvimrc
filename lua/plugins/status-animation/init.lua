local PREFIX = "Animation"
local command_names = {}
command_names.change = PREFIX .. "Change"
command_names.pause = PREFIX .. "Pause"
command_names.resume = PREFIX .. "Resume"
command_names.stop = PREFIX .. "STOP"

return {
	dir = vim.fn.stdpath("config") .. "/lua/plugins/status-animation",
	main = "plugins.status-animation.status-animation",
	lazy = false,
	opts = require("plugins.status-animation.opts"),
	config = function(_, opts)
		local animation = require("plugins.status-animation.status-animation")
		local sprites = require("plugins.status-animation.sprites")
		animation.setup(opts)


		-- Create a completion list based on sprites file
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

		vim.api.nvim_create_user_command(command_names.change,
			function (commands)
				local args = commands["fargs"]

				-- Need to check if user has supplied enough arguments
				-- Error if not 2
				local supplied_nargs = 0
				for _ in pairs(args) do supplied_nargs = supplied_nargs + 1 end


				local name, delay = nil, nil
				local default_delay = 400 -- (ms)

				if supplied_nargs ~= 2 then
					if supplied_nargs == 1 then
						name, delay = unpack(args), default_delay
					else
						error("Invalid number of arguments. Expected 2. Got `" .. supplied_nargs .. "` instead.")
					end
				else
					name, delay = unpack(args)
				end

				delay = tonumber(delay)

				-- Check that the name is actually in the list of sprites
				if sprites[name] == nil then
					error("Unknown animation name: " .. name)
				end

				animation.change_current_animation(name, delay)
			end,
			{nargs = "+", complete = sprite_complete}
		)

		vim.api.nvim_create_user_command(command_names.stop,
		function ()
			animation.stop_current_animation({remove = true})
		end, {nargs = 0})

		vim.api.nvim_create_user_command(command_names.pause,
		function ()
			animation.stop_current_animation({pause = true})
		end, {nargs = 0})


		vim.api.nvim_create_user_command(command_names.resume,
		function ()
			animation.resume_current_animation()
		end, {nargs = 0})

	end,
	keys = {
		{"<leader>ac", ":"..command_names.change.." ", desc = "Change current animation"},
		{"<leader>ap", "<CMD>"..command_names.pause.."<CR>", desc = "Pause current animation"},
		{"<leader>ar", "<CMD>"..command_names.resume.."<CR>", desc = "Resume current animation"},
		-- TODO: <leader>ak for `kill` animation?
		{"<leader>as", "<CMD>"..command_names.stop.."<CR>", desc = "Remove (Stop) current animation"}

	},
	priority = 1000,
}
