--------------------------------------------------------------------------------
---- init.lua ------------------------------------------------------------------
--------------------------------------------------------------------------------

require('vimrc')        -- basic options
require('statusline')   -- statusline
require('tabs')         -- tabs + tab binds

require('lazy-plugins')         -- plugins

-- save
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = true })
-- lsp binds
vim.keymap.set('n', 'K', '<Nop>', { buffer = bufnr })
-- vim.keymap.set('n', 'gh', vim.lsp.buf.hover, { buffer = bufnr, desc = 'LSP hover' })

------------------------
---- diagnostic stuff --
------------------------
virtual_lines_enabled = false -- default
virtual_lines_enabled_config = { current_line = false, highlight_whole_line = true, }
virtual_lines_disabled_config = false

virtual_text_enabled = true   -- default
virtual_text_enabled_config = true
virtual_text_disabled_config = false

vim.diagnostic.config({
    virtual_text = virtual_text_enabled and virtual_text_enabled_config or virtual_text_disabled_config,
    virtual_lines = virtual_lines_enabled and virtual_lines_enabled_config or virtual_lines_disabled_config,
    signs = true,
    underline = true,
    --update_in_insert = true,
    severity_sort = true,
})

vim.keymap.set('n', '<C-i>', function()
    virtual_text_enabled = not virtual_text_enabled
    local conf = virtual_text_enabled and virtual_text_enabled_config or virtual_text_disabled_config
    vim.diagnostic.config({ virtual_text = conf})
end, { desc = 'Toggle diagnostic virtual_text' })

vim.keymap.set('n', '<C-l>', function()
    virtual_lines_enabled = not virtual_lines_enabled
    local conf = virtual_lines_enabled and virtual_lines_enabled_config or virtual_lines_disabled_config
    vim.diagnostic.config({ virtual_lines = conf})
end, { desc = 'Toggle diagnostic virtual_lines' })

vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic" })


-- diagnostic virtual line colors
function apply_diagnostic_virtual_line_hl()
    local diag_keys = {[1] = 'Error', [2] = 'Warn', [3] = 'Info', [4] = 'Hint', [5] = 'Ok'}

    for _, k in pairs(diag_keys) do
        local diag = vim.api.nvim_get_hl(0, { name = string.format('Diagnostic%s', k) })
        local diag_virt_line = vim.api.nvim_get_hl(0, { name = string.format('DiagnosticVirtualLines%s', k) })
        local foreground = diag_virt_line.fg or diag.fg
        vim.api.nvim_set_hl(0, string.format('DiagnosticVirtualLines%s', k), { fg = foreground, bg = '#202020'  })
    end
end

apply_diagnostic_virtual_line_hl()

vim.api.nvim_create_autocmd('ColorScheme', {
    callback = apply_diagnostic_virtual_line_hl,
})


------------------------
---- session -----------
------------------------
-- Path to session file in current directory
local function get_session_path()
    return vim.fn.getcwd() .. "/.session.vim"
end

-- Save + quit
vim.keymap.set("n", "<leader>zz", function()
    local sessionfile = get_session_path()
    vim.cmd("mksession! " .. vim.fn.fnameescape(sessionfile))
    vim.cmd("qa")
end, { noremap = true, silent = true })

-- notify if session file in path
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        if vim.fn.argc() == 0 then
            local sessionfile = get_session_path()
            if vim.fn.filereadable(sessionfile) == 1 then
                print(string.format('Note: Session in this dir found: %s', sessionfile))
                --vim.cmd("silent source " .. vim.fn.fnameescape(sessionfile))
            end
        end
    end,
})

