local vim = vim

return {
	enabled = false,
	dir = vim.fn.stdpath("config") .. "/lua/plugins/todoage",
	main = "plugins.todoage.todoage",
	lazy = false,
	opts = {
		keywords = { "TODO", "FIXME", "HACK" },
		format = function(age_days)
			return string.format("(%d days)", age_days)
		end,
	},
	config = function(_, opts)
		local todoage = require("plugins.todoage.todoage")
		vim.api.nvim_create_user_command("Todoage", function()
			todoage.refresh()
		end, {})

		vim.api.nvim_create_user_command("TodoageEnable", function()
			todoage.enable()
		end, {})

		vim.api.nvim_create_user_command("TodoageDisable", function()
			todoage.disable()
		end, {})

		vim.api.nvim_create_user_command("TodoageToggle", function()
			todoage.toggle()
		end, {})

		todoage.setup(opts)
	end
}
