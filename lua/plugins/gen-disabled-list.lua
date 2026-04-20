local vim = vim
--- Copied from gen-compile-commands.lua
local PLUGIN_DIR = vim.fn.stdpath("config") .. "/lua/plugins"
local name = "gen-disabled-list"
local filename = name .. ".lua"
local M = {
	name = name,
	dir = PLUGIN_DIR,
	main = PLUGIN_DIR .. "/" .. filename,
	lazy = false,
}


local function serialize_plugin_spec(spec)
	local parts = {}

	-- If spec is just a string (git repo), serialize as string
	if type(spec) == "string" then
		table.insert(parts, string.format('%q', spec))
		return table.concat(parts)
	end

	-- Start table
	table.insert(parts, "{ ")

	-- The first field: either name, dir, or string repo in first position
	if spec.name then
		table.insert(parts, string.format('name = %q, ', spec.name))
	elseif spec.dir then
		table.insert(parts, string.format('dir = %q, ', spec.dir))
	elseif spec[1] and type(spec[1]) == "string" then
		-- git repo as first list item
		table.insert(parts, string.format('%q, ', spec[1]))
	end

	-- enabled field (optional, default true so only write if false)
	if spec.enabled == false then
		table.insert(parts, "enabled = false, ")
	end

	-- close table
	table.insert(parts, "}")

	return table.concat(parts)
end

local function serialize_plugin_list_to_lines(specs)
	local lines = {"return {"}

	for _, spec in ipairs(specs) do
		table.insert(lines, "  " .. serialize_plugin_spec(spec) .. ",")
	end

	table.insert(lines, "}")

	return lines
end

local function get_plugin_id_from_git_url(url)
	-- Removing any trailing .git
	url = url:gsub("%.git$", "")

	local author_repo = url:match("github.com[:/](.+/.+)$")

	if author_repo then
		return author_repo
	else
		error("Could not parse plugin id from URL: " .. url)
	end
end


-- Filepath relative to stdpath("config")
local function write_disable_file(filepath, disabled_plugin_specs)
	local spec_serialized_lines = serialize_plugin_list_to_lines(disabled_plugin_specs)

	local lines = {
		"-- AUTO-GENERATED FILE - DO NOT EDIT MANUALLY",
		"-- See ../plugins/" .. filename .. " for the command to generate this file."
	}
	vim.list_extend(lines, spec_serialized_lines)


	vim.fn.writefile(lines, filepath)
	print("Disabled plugins file written to: " .. filepath)
end


local function generate_disabled_spec_list(to_disable_display_names)
	local lazy_config = require("lazy.core.config")
	local loaded_plugins = lazy_config.plugins

	local disabled_specs = {}

	for plugin_id, plugin_spec in pairs(loaded_plugins) do
		-- Internal name used by lazy.nvim
		local display_name = plugin_spec.name or plugin_id

		for _, name_to_disable in ipairs(to_disable_display_names) do
			if display_name == name_to_disable or plugin_id == name_to_disable then
				local git_url = plugin_spec.url

				if git_url then
					-- Standard (shortened) git repo url used in plugin specs
					local repo_id = get_plugin_id_from_git_url(git_url)
					table.insert(disabled_specs, { repo_id, enabled = false })

				else -- Probably a local (custom) plugin
					-- No URL, try to disable by local dir or name
					local dir = plugin_spec.dir
					local name = plugin_spec.name

					if dir then
						table.insert(disabled_specs, { dir = dir, enabled = false })
					elseif name then
						table.insert(disabled_specs, { name = name, enabled = false })
					else
						table.insert(disabled_specs, { plugin_id, enabled = false })
					end
				end
			end
		end
	end

	return disabled_specs
end


M.config = function(_, opts)
	vim.api.nvim_create_user_command("GenerateDisabledPlugins",
	function ()
		local path = vim.fn.stdpath("config") .. "/lua/config/disabled.lua"

		local to_disable_display_names = {
			-- Other plugins
			--presence,
			"vim-fugitive",
			--baleia,
			"garbage-day.nvim",
			"hardtime.nvim",

			-- TODO: Fix checkhealth of magma
			"magma-nvim",
		}

		local disabled_specs = generate_disabled_spec_list(to_disable_display_names)

		write_disable_file(path, disabled_specs)
	end,
	{}
)
end

return M
