local vim = vim
--- Inspired by `leosmaia21/gcompilecommands.nvim`
--- Adapted for Windows / Cross-platform

local PLUGIN_DIR = vim.fn.stdpath("config") .. "/lua/plugins"

local name = "gen-compile-commands"
local M = {
	name = name,
	dir = PLUGIN_DIR,
	main = PLUGIN_DIR .. "/" .. name .. ".lua",
	lazy = false,
	opts = {
		json_tmp_file = vim.fn.tempname(),
	}
}

local function encode_path_str(filepath)
	-- clangd accepts forward slashes on Windows as well as Unix.
	return filepath:gsub("\\", "/")
end

-- Safely formats compile_commands array into indented JSON using Neovim's built-in encoder.
local function format_pretty_compile_commands(commands)
	local lines = { "[" }

	for i, item in ipairs(commands) do
		table.insert(lines, "  {")
		table.insert(
			lines,
			'    "directory": ' .. vim.json.encode(item.directory) .. ","
		)
		table.insert(
			lines,
			'    "command": ' .. vim.json.encode(item.command) .. ","
		)
		table.insert(
			lines,
			'    "file": ' .. vim.json.encode(item.file)
		)
		table.insert(
			lines,
			"  }" .. (i < #commands and "," or "")
		)
	end

	table.insert(lines, "]")

	return table.concat(lines, "\n")
end

local function generateCompileCommands(opts)
	if not opts or not opts.json_tmp_file then
		print("Error: opts.json_tmp_file is required")
		return 1
	end

	local tmp_file = vim.fn.expand(opts.json_tmp_file)

	-- Simulates running "make" and greps all compile commands
	local cmd = 'make -wn 2>&1 | grep -E "gcc|clang|clang\\+\\+|g\\+\\+.*" > "' .. tmp_file .. '"'
	vim.cmd("silent! !" .. cmd)
	if vim.v.shell_error ~= 0 then
		print("Make failed, error: " .. vim.v.shell_error)
		return 1
	end

	local file = io.open(tmp_file, "r")
	if not file then
		print("Cannot open file (read): " .. tmp_file)
		return 1
	end

	local json_contents_str = file:read("*a")
	file:close()

	-- Get current directory and handle Windows paths properly
	local current_dir = encode_path_str(vim.fn.getcwd())
	local compile_commands = {}

	for line in json_contents_str:gmatch("[^\r\n]+") do
		local filename = line:match("[^%s]+$")

		if filename then
			local command = line:sub(1, #line - #filename)

			table.insert(compile_commands, {
				directory = current_dir,
				command = command,
				file = filename,
			})
		end
	end

	local write_path = current_dir .. "/compile_commands.json"

	file = io.open(write_path, "w")
	if not file then
		print("Cannot open file (write): " .. write_path)
		return 1
	end

	file:write(format_pretty_compile_commands(compile_commands))
	file:close()

	vim.cmd("silent! LspRestart")
	print("compile_commands.json generated, LSP restarted")

	-- Cleanup temporary files
	local success, errmsg, errcode = os.remove(tmp_file)
	if not success then
		print("Failed to remove temporary file: " .. tmp_file)
		print("(" .. tostring(errcode) .. ") " .. tostring(errmsg))
		return errcode or 1
	end

	return 0
end

M.setup = function(opts)
	if opts and opts.json_tmp_file ~= nil then
		opts.json_tmp_file = vim.fn.expand(opts.json_tmp_file)
	end
end

M.config = function(_, opts)
	M.setup(opts)
	vim.api.nvim_create_user_command("Gcompilecommands", function()
		generateCompileCommands(opts)
	end, {})
end

return M
