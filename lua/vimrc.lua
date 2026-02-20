--------------------------------------------------------------------------------
---- lua/vimcr.lua -------------------------------------------------------------
--------------------------------------------------------------------------------

vim.cmd("syntax on")
vim.opt.number = true
vim.opt.relativenumber = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.showmode = false

vim.opt.breakindent = true

vim.opt.undofile = true

vim.opt.signcolumn = 'yes'

vim.opt.cursorline = true

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

vim.opt.termguicolors = true

-- vim.cmd.colorscheme 'torte' -- elflord, murphy, evening

-- Change 'fg' for the tildes (~) and 'bg' for the background color
vim.api.nvim_set_hl(0, "EndOfBuffer", { fg = "#444444", bg = "#000000" })
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1e2430", bold = false, underline = false })

--[[
local hour = tonumber(os.date("%H"))
if hour >= 8 and hour < 20 then
    vim.opt.bg = 'light'
    vim.cmd.colorscheme 'catpuccin-latte' -- morning
else
    vim.opt.bg = 'dark'
    vim.cmd.colorscheme 'catpuccin-macchiato' -- elflord, murphy, evening
end
]]

vim.keymap.set('n', '<leader>ul', function()
    vim.opt.bg = 'light'
    vim.cmd.colorscheme 'catppuccin-latte'
end, {desc = "Theme: catpuccin-LATTE" })
vim.keymap.set('n', '<leader>uf', function()
    vim.opt.bg = 'dark'
    vim.cmd.colorscheme 'catppuccin-frappe'
end, {desc = "Theme: catpuccin-frappe" })
vim.keymap.set('n', '<leader>um', function()
    vim.opt.bg = 'dark'
    vim.cmd.colorscheme 'catppuccin-macchiato'
end, {desc = "Theme: catpuccin-macchiato" })
vim.keymap.set('n', '<leader>ut', function()
    vim.opt.bg = 'dark'
    vim.cmd.colorscheme 'tokyonight-moon'
end, {desc = "Theme: tokyonight-moon" })
vim.keymap.set('n', '<leader>ux', function()
    vim.opt.bg = 'dark'
    vim.cmd.colorscheme 'moonfly'
end, {desc = "Theme: moonfly" })

vim.g.matchparen_disable_cursor_hl = 1

-- vim.opt.clipboard = "unnamed"

vim.keymap.set('n', '<leader>cad', ':set autochdir<CR>', { silent = true })

vim.keymap.set('n', 'gh', ':lua vim.lsp.buf.hover()<CR>', { buffer = bufnr, desc = 'LSP hover' })

vim.keymap.set('n', 'gd', ':split | lua vim.lsp.buf.definition()<CR>', { buffer = bufnr, desc = 'Goto definition - new tab' })
vim.keymap.set('n', 'gD', ':tab split | lua vim.lsp.buf.definition()<CR>', { buffer = bufnr, desc = 'Goto definition - new tab' })

vim.keymap.set('n', '<leader>T', ':Telescope<CR>', { buffer = bufnr, desc = 'Telescope' })

vim.keymap.set('n', '<leader>C', ':Telescope command_history<CR>', { buffer = bufnr, desc = 'Telescope COMMAND_HISTORY' })
vim.keymap.set('n', '<leader>d', ':Telescope diagnostics<CR>', { buffer = bufnr, desc = 'TELESCOPE DIAGNOSTICS' })

vim.keymap.set('n', '<c-p>', ':Telescope find_files<CR>', { buffer = bufnr, desc = 'Telescope FILES' })
vim.keymap.set('n', '<c-g>', ':Telescope live_grep<CR>', { buffer = bufnr, desc = 'Telescope LIVE_GREP' })
vim.keymap.set('n', '<c-f>', ':Telescope current_buffer_fuzzy_find<CR>', { buffer = bufnr, desc = 'Telescope FUZZY' })

vim.keymap.set('n', '<leader>r', ':Telescope lsp_references<CR>' , { desc = "Telescope References (cursor)" })
vim.keymap.set('v', '<leader>r', function()
    -- Get the visual selection manually
    vim.cmd('normal! "vy') -- Yank selection into register 'v'
    local selection = vim.fn.getreg('v')
    require('telescope.builtin').lsp_references({ default_text = selection })
end, { desc = "LSP References (selection)" })

vim.keymap.set('n', '<c-h>', ':split<CR>', { buffer = bufnr, desc = 'Split' })

-- quarter page scrolling
vim.keymap.set('n', '<C-u>', function()
    local count = math.floor(vim.api.nvim_win_get_height(0) / 4)
    local curs = vim.api.nvim_win_get_cursor(0)
    local target_row = math.max(curs[1] - count, 1)

    -- sets both cursor-pos & window scroll
    vim.api.nvim_win_set_cursor(0, { target_row, curs[2] })
    vim.fn.winrestview({ topline = vim.fn.line('w0') - count, leftcol = 0 })
end, { desc = 'Scroll up 1/4 page' })

vim.keymap.set('n', '<C-d>', function()
    local count = math.floor(vim.api.nvim_win_get_height(0) / 4)
    local curs = vim.api.nvim_win_get_cursor(0)
    local buff_line_count = vim.api.nvim_buf_line_count(0)
    local target_row = math.min(curs[1] + count, buff_line_count)

    -- sets both cursor-pos & window scroll
    vim.api.nvim_win_set_cursor(0, { target_row, curs[2] })
    vim.fn.winrestview({ topline = vim.fn.line('w0') + count, leftcol = 0 })
end, { desc = 'Scroll down 1/4 page' })

-- sucking

-- Suck: Pull next tab into a split and focus it
vim.keymap.set('n', '<leader>s', function()
    local tabs = vim.api.nvim_list_tabpages()
    local current_tab = vim.api.nvim_get_current_tabpage()
    
    if #tabs <= 1 then
        print("No other tab to suck in")
        return
    end

    local current_idx = 1
    for i, handle in ipairs(tabs) do
        if handle == current_tab then
            current_idx = i
            break
        end
    end

    local target_idx = (current_idx % #tabs) + 1
    local target_tab_handle = tabs[target_idx]
    local target_win = vim.api.nvim_tabpage_get_win(target_tab_handle)
    local target_buf = vim.api.nvim_win_get_buf(target_win)

    -- Close the tab at that position
    vim.cmd(target_idx .. 'tabclose')

    -- Create split and focus the new buffer
    vim.cmd('split')
    vim.api.nvim_set_current_buf(target_buf)
end, { silent = true, desc = "Suck next tab into focused split" })

-- Push: Move current split to new tab but stay in original tab
vim.keymap.set('n', '<leader>t', function()
    if vim.fn.winnr('$') <= 1 then
        print("No split to push out")
        return
    end

    local current_tab = vim.api.nvim_get_current_tabpage()

    -- Move current window to new tab (focus shifts to new tab)
    vim.cmd('wincmd T')

    -- Return focus to the original tab
    vim.api.nvim_set_current_tabpage(current_tab)
end, { silent = true, desc = "Push split to new tab and stay" })
