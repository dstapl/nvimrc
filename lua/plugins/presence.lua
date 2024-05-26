return {
	'andweeb/presence.nvim',
	--lazy = true,
	event = "VeryLazy",
	enabled = false,
	opts = {
		-- Rich Presence text options ,
		show_time = false,
		--  An editable file is loaded in the buffer (either string or function(filename: string): string)
		editing_text = "Coding",
		--  Browsing a file explorer (either string or function(file_explorer_name: string): string)
		file_explorer_text = "Browsing files",
		--  Committing changes in git (either string or function(filename: string): string)
		git_commit_text = "Uploading",
		--  Managing plugins (either string or function(plugin_manager_name: string): string)
		-- plugin_manager_text = "Managing plugins",
		--  A read-only or unmodifiable file is loaded in the buffer (either string or function(filename: string): string)
		reading_text = "Reading",
		--  In a git repository (either string or function(project_name: string|nil, filename: string): string)
		workspace_text = "Remote",
		--  `enable_line_number` is set to true (either string or function(line_number: number, line_count: number): string)
		-- line_number_text    = "Line %s out of %s",
	},
	config = true,
}
