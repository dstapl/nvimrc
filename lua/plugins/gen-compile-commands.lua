--- Inspired by `leosmaia21/gcompilecommands.nvim`
--- Adapted for Windows

local PLUGIN_DIR = vim.fn.stdpath("config") .. "/lua/plugins"
local TMP_DIR = os.getenv("LOCALAPPDATA") .. "/temp"
local M = {
	name = "gen-compile-commands",
	dir = PLUGIN_DIR,
	main = PLUGIN_DIR .. "/gen-compile-commands.lua",
	lazy = false,
	opts = {
		json_tmp_file = TMP_DIR .. "/compile_commandsNEOVIM.json.tmp",
		clangd_tmp_file = TMP_DIR .. "/.clang.json.tmp"
	}
}
local NEWLINE = "\n"


local function json_escape_string(str)
	-- Escape string quotes " -> \"
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

		-- Encode lua key into json
		local key_str = ""
		if type(key) == "string" then
			key_str = '"' ..json_escape_string(key) .. '"'
		else
			key_str = tostring(key)
		end

		-- Add to output
		json = json .. inner_spacer .. key_str .. ": " .. _encode_json_value(value)


		first = false
	end

	-- End the JSON object
	json = json .. sep .. outer_spacer .. "}"

	return json
end


local function encode_path_str(filepath)
	return string.gsub(filepath, '\\', '/')
end



local function write_json_compile_commands_indented(file, current_dir, json_contents_str, indent_level)
	file:write("[" .. NEWLINE)

	-- Implement no trailing comma in JSON lists

	local matches = {}
	-- Collect all matches in the table
	for match in json_contents_str:gmatch("[^\r\n]+") do
		table.insert(matches, match)
	end

	-- Track which build option we're on
	local build_no = 1
	for _, build in ipairs(matches) do
		-- Construct json object and string
		local filename = build:match("[^%s]+$")
		local command = build:sub(1, #build - #filename)
		local command_table = {["directory"] = current_dir, ["command"] = command, ["file"] = filename};
		local json = json_encode_with_sep(command_table, NEWLINE, indent_level)

		-- Append comma unless last element
		if build_no < #matches then
			json = json .. "," .. NEWLINE
		end
		file:write(json)

		build_no = build_no + 1
	end

	file:write(NEWLINE .. "]")

	file:flush()
end


-- TODO: Does this need to be changed per os? vim.loop.os_uname().sysname
local function generateCompileCommands(indent_level)
	if (indent_level == nil) or (type(indent_level) ~= "number") then
		indent_level = 0 -- None
	end

	-- NOTE: Run "make clean" or similar before this.
	-- Simulates running "make" and greps all compile commands
	local cmd = "make -wn 2>&1 | egrep \"gcc|clang|clang\\+\\+|g\\+\\+.*\" > " .. M.opts.json_tmp_file
	vim.cmd("silent! !" .. cmd)
	if vim.v.shell_error ~= 0 then
		print("(vim.v.shell_error)Make failed, error: " .. vim.v.shell_error)
		return 1
	end

	local current_dir = encode_path_str(vim.fn.getcwd())
	local write_path = current_dir .. "/compile_commands.json"

	-- IO Handlers
	local f = io.open(M.opts.json_tmp_file, "r")
	if f == nil then
		print("Cannot open file(read)" .. M.opts.json_tmp_file)
		return nil
	end
	local json_contents_str = f:read("*a")

	-- Format path
	local file = io.open(write_path, "w")
	if file == nil then
		print("Cannot open file(write)" .. write_path)
		return nil
	end

	if file == nil then
		error("File I/O failed")
		return nil
	end

	-- Write out JSON
	write_json_compile_commands_indented(file, current_dir, json_contents_str, indent_level)

	-- Close files
	file:close()
	f:close()
	vim.cmd("silent! LspRestart")
	print("compile_commands.json generated, LSP restarted")

	return 0
end


M.setup = function(opts)
	if opts.json_tmp_file_path ~= nil then
		M.opts.json_tmp_file = vim.fn.expand(opts.json_tmp_file_path)
	end
end

M.config = function(_, opts)
	M.setup(opts)
	vim.api.nvim_create_user_command("Gcompilecommands", function()
		generateCompileCommands()
	end, {})
end


return M
