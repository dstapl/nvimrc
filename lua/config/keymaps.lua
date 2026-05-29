local vim = vim

-- Set <Leader>
vim.g.mapleader = " "

-- Ext copy / paste
vim.keymap.set({"n","v"},"<Leader>y",[["+y]])

vim.keymap.set({"n","v"},"<Leader>p",[["+p]])

-- CTRL+<BS> delete word
vim.keymap.set("i", "", "db")
vim.keymap.set("n", "", "db")

-- Blackhole delete
vim.keymap.set("n", "<Leader>d", [["_P]])

-- Cloak and colour picker (ccc) 
-- TOOD: This has stopped working
--vim.keymap.set("n", "<Leader>cl", "<cmd>CloakPreviewLine<CR>")
-- Replaced with this for now instead
vim.keymap.set("n", "<Leader>cl", "<CMD>CloakToggle<CR>")

-- LSP
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename)

-- Replace highlighted word in visual mode
-- Need to stop <leader>(<space>) moving the cursor
vim.keymap.set("v", " ", "")
vim.keymap.set("v", "<Leader>r", '"hy:%s/<C-r>h//g<left><left>')


-- Maybe get rid of this...Only really for closing start-screen or :term
vim.keymap.set("n", "<ESC><ESC>", "<CMD>bd<CR>")


-- Open system file-explorer at current buffer directory
vim.keymap.set("n", "<Leader>ex", "<CMD>!start explorer %:h<CR><CR>")


-- Clear current registers (Adapted from https://stackoverflow.com/a/39348498)
local function clear_registers()
  local regs = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-=\"*+%#"
  for i = 1, #regs do
    local reg = regs:sub(i, i)
    vim.fn.setreg(reg, "")
  end
end
vim.api.nvim_create_user_command("ClearRegisters", clear_registers, {})
