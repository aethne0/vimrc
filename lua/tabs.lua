--------------------------------------------------------------------------------
---- lua/tabs.lua --------------------------------------------------------------
--------------------------------------------------------------------------------

vim.keymap.set("n", "<F11>", ":tabprevious<CR>", { silent = true })
vim.keymap.set("n", "<F12>", ":tabnext<CR>", { silent = true })
vim.keymap.set("n", "<F9>", ":tabmove -1<CR>", { silent = true })
vim.keymap.set("n", "<F10>", ":tabmove +1<CR>", { silent = true })
