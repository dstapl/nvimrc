--! USER COMMANDS
--:CordConnect - Initialize presence client internally and connect to Discord
--:CordReconnect - Reconnect to Discord
--:CordDisconnect - Disconnect from Discord
--:CordTogglePresence - Toggle presence
--:CordShowPresence - Show presence
--:CordHidePresence - Hide presence
--:CordToggleIdle - Toggle idle status
--:CordIdle - Show idle status
--:CordUnidle - Hide idle status and reset the timeout
--:CordWorkspace <name> - Change the name of the workspace (visually)
return {
	"vyfor/cord.nvim",
	event = "VeryLazy",
	enabled = true,
	opts = {
		usercmds = true,
		display = {
			show_time = true,
			swap_fields = false,
			view = "asset",
		},
		timestamp = {
			enable = true,
			reset_on_idle = false,
			reset_on_change = false,
		},
		idle = {
			enabled = true,
			show_status = true,
			timeout = 1800000, -- 30 minutes
			ignore_focus = false,
			details = "Idle",
			tooltip = "💤",
		},
		text = {
			viewing = function(opts) return "Viewing " .. opts.filename end,
			editing = function(opts) return "Editing " .. opts.filename end,
			workspace = function(opts) return "In " .. opts.workspace end,

			-- Hides status text
			lsp = "",
			vcs = "",

			file_browser = "Browsing files",
			plugin_manager = "Managing plugins",
			lsp_manager = "",
		},
	},
}
