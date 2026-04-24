vim.g.rustfmt_emit_files = 1
vim.g.rustfmt_command = "rustfmt +nightly"
vim.keymap.set('n', '<leader>lf', ':RustFmt<CR>', { silent = true })
vim.keymap.set('n', '<leader>lt', ':RustTest<CR>', { silent = true })
vim.keymap.set('n', '<leader>lT', ':RustTest!<CR>', { silent = true })
vim.keymap.set('n', '<leader>lr', ':RustRun<CR>', { silent = true })
vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "101"
