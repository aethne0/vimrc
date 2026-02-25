vim.keymap.set('n', '<leader>lr', ':w<CR>:!make -C build run<CR>', { 
    silent = true, 
    buffer = true, 
    desc = "Save and Run C Project" 
})
