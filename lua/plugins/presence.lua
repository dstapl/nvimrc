return {
	"vyfor/cord.nvim",
	--lazy = true,
	-- build = ".\\build",
	event = "VeryLazy",
	enabled = true,
	opts = {
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
		usercmds = true,                              -- Enable user commands
		timestamp = {
			enable = true,                              -- Enable automatically updating presence
			-- Intervals are now real-time, no interval needed
			reset_on_idle = false,                      -- Reset start timestamp on idle
			reset_on_change = false,                    -- Reset start timestamp on presence change
		},
		editor = {
			icon = nil,                                 -- Image ID or URL in case a custom client id is provided
			client = 'neovim',                          -- vim, neovim, lunarvim, nvchad, astronvim or your application's client id
			tooltip = 'The Superior Text Editor',       -- Text to display when hovering over the editor's image
		},
		display = {
			-- theme = ?
			show_time = true,                           -- Display start timestamp
		    -- show_repository handled through text
            -- show_cursor_position ditto
			swap_fields = false,                        -- If enabled, workspace is displayed first
			-- workspace_blacklist handled through hooks/functions
		},
		-- lsp now handled through plugins e.g., diagnostics
		idle = {
			enabled = true,								-- Enable idle status
			show_status = true,                         -- Display idle status, disable to hide the rich presence on idle
			timeout = 1800000,                          -- Timeout in milliseconds after which the idle status is set, 0 to display immediately
			ignore_focus = false,                       -- Do not display idle status when neovim is focused
			details = 'Idle',                              -- Text to display when idle
			tooltip = '💤',                             -- Text to display when hovering over the idle image
		},
		text = {
			viewing = function (opts)
				return 'Viewing ' .. opts.filename
			end,
			editing = function (opts)
				return 'Editing ' .. opts.filename
			end,
			file_browser = 'Browsing files',      -- Text to display when browsing files (Empty string to disable)
			plugin_manager = 'Managing plugins',  -- Text to display when managing plugins (Empty string to disable)
			--lsp_manager = 'Configuring LSP in {}',      -- Text to display when managing LSP servers (Empty string to disable)
			lsp_manager = "",
			--vcs = 'Committing changes in {}',           -- Text to display when using Git or Git-related plugin (Empty string to disable)
			vcs = "",
			workspace = function (opts)
				return 'In ' .. opts.workspace                        -- Text to display when in a workspace (Empty string to disable)
			end,
		},
		buttons = {
			--{
			--	label = 'View Repository',                -- Text displayed on the button
			--	url = 'git',                              -- URL where the button leads to ('git' = automatically fetch Git repository URL)
			--},
			{
       				label = function(opts)
            				return opts.repo_url and 'View Repository' or 'View cord.nvim'
        			end,
        			url = function(opts)
           				return opts.repo_url or 'https://github.com/vyfor/cord.nvim'
        			end,
    			}
			-- {
			--   label = 'View Plugin',
			--   url = 'https://github.com/vyfor/cord.nvim',
			-- }
		},
		assets = {                                    -- Custom file icons
		-- lazy = {                                 -- Vim filetype or file name or file extension = table or string (see wiki)*
		--   name = 'Lazy',                         -- Optional override for the icon name, redundant for language types
		--   icon = 'https://example.com/lazy.png', -- Rich Presence asset name or URL
		--   tooltip = 'lazy.nvim',                 -- Text to display when hovering over the icon
		--   type = 2,                              -- 0 = language, 1 = file browser, 2 = plugin manager, 3 = lsp manager, 4 = vcs; defaults to language
		-- },
		-- ['Cargo.toml'] = 'crates',
		},
	};
	config = true,
}
