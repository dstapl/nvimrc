local cs = {
    "ring0-rootkit/ring0-dark.nvim",
	lazy = false,
};

-- Re-used colours
-- TODO: Everything seems quite bright compared to youtube videos
--	Tips: remove bolds, and then reduce saturation
cs.palette = {
	purple = "#800080",

	orange = "#C08E4F",
	yellow = "yellow",
	light_green = "#87C555",

	grey = "#98A6A3",
};


local pal = cs.palette;
-- N.B. 2025-12-18 It seems like clangd (lsp) can not differentiate between
--		the `typedef` and `struct` *versions* of token definitions, so these
--		will have to be the same
--	E.g. typedef struct Test Test; will have the same highlighting for both.
cs.opts = {
	TSComment = { fg = pal.orange, italic = true },
	TSPreProcDir = { fg = pal.grey, italic = false },
	TSWIP = { fg = pal.purple, bg = "red", italic = true, bold = true },
	TSstatement = { fg = pal.yellow, italic = false, bold = false },

	-- NOTE: Links are to pre-defined groups
	Operator = { link = "TSstatement" },
	["@lsp.type.operator.c"] = { link = "Normal" },
	["@variable"] = { link = "Normal" },
	["@lsp.type.property.c"] = { link = "@variable" },

    Function = { link = "Normal" },

    PreProc = { link = "TsPreProcDir" },
    Include = { link = "TsPreProcDir" },
	Included = { link = "String" };
    Define = { link = "TsPreProcDir" },
    Macro = { link = "TsPreProcDir" },
    PreCondit = { link = "TsPreProcDir" },
	Comment = { link = "TSComment" },

	["@lsp.type.class.c"] = { link = "Normal" },
	["@lsp.typemod.class.declaration.c"] = { link = "Normal" },

    StorageClass = { link = "TSstatement" },
	cStatement = { link = "TSstatement" },
    Structure = { link = "TSstatement" },
    Typedef = { link = "TSstatement" },
	Enum = { link = "TSstatement" } ,
	Union = { link = "TSstatement" } ,

	-- e.g. Type included in struct field definitions
	cType = { link = "TSPreProcDir" },
    Constant = { link = "Structure" },
    Character = { link = "String" },
    String = { fg = pal.light_green, italic = false, bold = false },
    Boolean = { link = "Normal" },
    Number = { link = "Normal" },
    Float = { link = "Normal" },

	-- Custom
	CursorLine = { italic = false },
	StatusLine = { italic = false },
};

cs.config = function (_, opts)
	local rd = require("ring0dark");
	rd.setup(opts)

	vim.cmd.colorscheme("ring0dark")


	for hl_field, value in pairs(opts) do
		vim.api.nvim_set_hl(0, hl_field, value)
	end
end


return cs
