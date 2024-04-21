return {
	'andweeb/presence.nvim',
	config = function ()
		require("presence").setup({
			-- Rich Presence text options ,
				show_time = false,
				--  An editable file is loaded in the buffer (either string or function(filename: string): string)
				editing_text = "Manipulating bits",
				--  Browsing a file explorer (either string or function(file_explorer_name: string): string)
				file_explorer_text  = "Navigating inodes",
				--  Committing changes in git (either string or function(filename: string): string)
				git_commit_text     = "Injecting code",
				--  Managing plugins (either string or function(plugin_manager_name: string): string)
				-- plugin_manager_text = "Managing plugins",
				--  A read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
				reading_text        = "Viewing classified documents",
				--  In a git repository (either string or function(project_name: string|nil, filename: string): string)
				workspace_text      = "Infiltrating the codebase",
				--  `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
				-- line_number_text    = "Line %s out of %s",
		})
	end,
}
