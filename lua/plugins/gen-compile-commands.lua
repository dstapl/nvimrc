--- Inspired by `leosmaia21/gcompilecommands.nvim`
--- Adapted for Windows

local PLUGIN_DIR = vim.fn.stdpath("config") .. "/lua/plugins/"
local M = {
	name = "gen-compile-commands",
	dir = PLUGIN_DIR,
	main = PLUGIN_DIR .. "gen-compile-commands.lua",
	lazy = false,
	opts = {
		tmp_file = os.getenv("LOCALAPPDATA") .. "/temp/compile_commandsNEOVIM.json.tmp"
	}
}


local function json_escape_string(str)
	return str:gsub('"', '\\"')
end

local function json_encode_with_sep(tbl, sep, indent_level)
	if type(tbl) ~= "table" then
		error("Input is not a table")
	end

	local function _encode_json_value(val)
		if type(val) == "table" then -- Nested tables
			return json_encode_with_sep(val)
		elseif type(val) == "string" then
			-- Escape string quotes " -> \"
			return '"' ..json_escape_string(val) .. '"'
		elseif type(val) == "number" then
			return tostring(val)
		elseif type(val) == "boolean" then
			return val and "true" or "false"
		else -- Type not supported or nil
			return "null"
		end
	end

	-- Encode json
	local indent = "\t"
	local outer_spacer = string.rep(indent, indent_level)
	local inner_spacer = outer_spacer .. indent

	local json = outer_spacer .. "{" .. sep
	local first = true

	for key, value in pairs(tbl) do
		-- Prepend commas for subsequent pairs
		if not first then
			json = json .. "," .. sep
		end

		-- Encode json key
		local key_str = ""
		if type(key) == "string" then
			key_str = '"' ..json_escape_string(key) .. '"'
		else
			key_str = tostring(key)
		end

		-- Encode json value
		json = json .. inner_spacer .. key_str .. ": " .. _encode_json_value(value)


		first = false
	end

	-- End the JSON object
	json = json .. sep .. outer_spacer .. "}"

	return json
end

-- TODO: Does this need to be changed per os? vim.loop.os_uname().sysname
local newline = "\n"
local function generateCompileCommands()
	local cmd = "make -wn 2>&1 | egrep \"gcc|clang|clang\\+\\+|g\\+\\+.*\" > " .. M.opts.tmp_file
	vim.cmd("silent! !" .. cmd)
	if vim.v.shell_error ~= 0 then
		print("(vim.v.shell_error)Make failed, error: " .. vim.v.shell_error)
		return 1
	end

	local f = io.open(M.opts.tmp_file, "r")
	if f == nil then
		print("(tmp_file)Cannot open file " .. M.opts.tmp_file)
		return
	end
	local str = f:read("*a")
	local current_dir = vim.fn.getcwd()
	current_dir = string.gsub(current_dir, '\\', '/')

	local file_dir = current_dir .. "/compile_commands.json"
	local file = io.open(file_dir, "w")
	if file == nil then
		print("(comp_file)Cannot open file " .. file_dir)
	end


	file:write("[" .. newline)


	-- Indent level 0 = None
	local indent_level = 1

	-- No trailing comma in JSON lists
	local matches = {}
	-- Collect all matches in the table
	for match in str:gmatch("[^\r\n]+") do
		table.insert(matches, match)
	end

	local build_no = 1
	for _, build in ipairs(matches) do
		local filename = build:match("[^%s]+$")
		local command = build:sub(1, #build - #filename)
		local command_table = {["directory"] = current_dir, ["command"] = command, ["file"] = filename};
		local json = json_encode_with_sep(command_table, newline, indent_level)

		if build_no < #matches then
			json = json .. "," .. newline
		end
		file:write(json)

		build_no = build_no + 1
	end
	file:write(newline .. "]")
	f:close()
	file:close()
	vim.cmd("silent! LspRestart")
	print("compile_commands.json generated, LSP restarted")

	return 0
end


M.setup = function(opts)
	if opts.tmp_file_path ~= nil then
		M.opts.tmp_file = vim.fn.expand(opts.tmp_file_path)
	end
end

M.config = function(_, opts)
	M.setup(opts)
	vim.api.nvim_create_user_command("Gcompilecommands", function()
		generateCompileCommands()
	end, {})
end


return M
