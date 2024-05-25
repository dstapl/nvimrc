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
vim.keymap.set("n", "<Leader>cl", "<cmd>CloakToggle<CR>")
-- LSP
vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename)
