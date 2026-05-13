---- init.lua ------------------------------------------------------------------
--------------------------------------------------------------------------------

require('vimrc')        -- basic options
require('statusline')   -- statusline
require('tabs')         -- tabs + tab binds

require('lazy-plugins')         -- plugins

-- For alacritty TAB is the same as "Ctrl + i". Therefor use `nnoremap <C-I> <C-I>`
vim.keymap.set("n", "<C-i>", "<C-i>", { silent = true, noremap = true })

-- save
vim.keymap.set('n', '<C-s>', ':w<CR>', { silent = true })
-- lsp binds
-- vim.keymap.set('n', 'K', '<Nop>', { buffer = bufnr })
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

vim.keymap.set('n', '<C-l>', function()
    virtual_text_enabled = not virtual_text_enabled
    local conf = virtual_text_enabled and virtual_text_enabled_config or virtual_text_disabled_config
    vim.diagnostic.config({ virtual_text = conf})
end, { desc = 'Toggle diagnostic virtual_text' })

-- vim.keymap.set('n', '<C-l>', function()
--     virtual_lines_enabled = not virtual_lines_enabled
--     local conf = virtual_lines_enabled and virtual_lines_enabled_config or virtual_lines_disabled_config
--     vim.diagnostic.config({ virtual_lines = conf})
-- end, { desc = 'Toggle diagnostic virtual_lines' })

vim.keymap.set('n', '<leader>lz', vim.lsp.buf.code_action, {
    desc = "Code action"
})

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

    vim.api.nvim_set_hl(0, 'DiagnosticHint', { fg = '#404040' })
    -- vim.api.nvim_set_hl(0, 'DiagnosticInfo', { fg = '#404040' })
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

-- vim.api.nvim_create_autocmd("LspAttach", {
--   callback = function(args)
--     local client = vim.lsp.get_client_by_id(args.data.client_id)
--     client.server_capabilities.semanticTokensProvider = nil
--   end,
-- })

-- 1. Register the config
vim.lsp.config.lua_ls = {
    filetypes = { 'lua' },

    settings = {
        Lua = {diagnostics = {globals = {"vim"}}},
    },
}

vim.lsp.config.zls = {
    install = {
        cmd = { os.getenv("HOME") .. "/bin/zls" },
    },
    filetypes = { 'zig', 'zir' },
    root_markers = { "build.zig", "zls.json", ".git" },
    settings = {
        zls = {
            enable_autofix = true,
            zig_exe_path = os.getenv("HOME") .. "/bin/zig-dir/zig",
        },
    },
}

-- 2. Enable it (Replaces the manual autocmd and vim.lsp.start)
vim.lsp.enable("zls")

vim.api.nvim_create_autocmd("FileType", {
    pattern = "zig",
    callback = function(args)
        -- You must pass the table directly
        vim.lsp.start(vim.lsp.config.zls, { bufnr = args.buf })
    end,
})


local target_torte = { ["torte"] = true }
local target_quiet = { ["quiet"] = true }
local target_default = { ["default"] = true  }
local target_blue = { ["blue"] = true  }

vim.api.nvim_create_autocmd({"ColorScheme", "VimEnter"}, {
    callback = function(args)
        -- default
        if target_default[args.match] then
            vim.api.nvim_set_hl(0, "Comment", { link = "@lsp.type.comment" })

            if vim.o.background == 'light' then
                vim.cmd("highlight Normal guibg=#d7d7d7 ctermbg=none")
                vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#ac60ac', italic = true, bold = false })

                vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = '#ffcccc' })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.rust", { fg = '#8f5c5c', underline = true })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.c", { fg = '#ffcccc' })
            else
                vim.cmd("highlight Normal guibg=#171914 ctermbg=none")

                vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#cc80cc', italic = true, bold = false })
                vim.api.nvim_set_hl(0, "@lsp.type.string.rust", { fg = '#80c070', italic = true })

                vim.api.nvim_set_hl(0, "_macros", { fg = '#bf8c8c', italic = true })
                vim.api.nvim_set_hl(0, "@lsp.type.macro", { link = "_macros" })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.c", { link = "_macros" })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.rust", { link = "_macros" })

                vim.api.nvim_set_hl(0, "Function", { fg = '#bccccc' })
                vim.api.nvim_set_hl(0, "rustFuncCall", { bold = false })
                vim.api.nvim_set_hl(0, "rustFuncName", { bold = true })

                vim.api.nvim_set_hl(0, "Statement", { fg = '#b8b8b8' })

                vim.api.nvim_set_hl(0, "Identifier", { fg = '#d0d0d0', italic = true, bold = false })
                vim.api.nvim_set_hl(0, "Constant", { fg = '#d0d0d0', italic = true, bold = false })

            end
        end

        -- blue
        if target_blue[args.match] then
            -- vim.api.nvim_set_hl(0, "@lsp", {fg = '#00ffff' })
            -- vim.api.nvim_set_hl(0, "Identifier", { fg = '#cccccc' })
            -- vim.api.nvim_set_hl(0, "Type", { bold = false })
            vim.api.nvim_set_hl(0, "Comment", { fg = '#cc80cc', italic = true, bold = false })
            vim.api.nvim_set_hl(0, "@lsp.type.comment", { link = "Comment" })
        end


        -- quiet
        if target_quiet[args.match] then
            vim.api.nvim_set_hl(0, "Comment", { link = "@lsp.type.comment" })

            if vim.o.background == 'light' then
                -- vim.cmd("highlight Normal guibg=#ffffdd ctermbg=none")
                vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#8c509c', italic = true, bold = false })
                vim.api.nvim_set_hl(0, "PreProc", { fg = '#6c7c6a' })

                vim.api.nvim_set_hl(0, "@lsp.type.string.rust", { link = 'String' })
                vim.api.nvim_set_hl(0, "cString", { link = 'String' })
                vim.api.nvim_set_hl(0, "String", { fg = '#306030' })

                vim.api.nvim_set_hl(0, "rustString", { fg = '#006000' })
                vim.api.nvim_set_hl(0, "rustStringContinuation", { fg = '#006000' })
                vim.api.nvim_set_hl(0, "rustEscape", { fg = '#006000' })

                vim.api.nvim_set_hl(0, "_macros", { fg = '#4c2600', italic = true, underline = false })
                vim.api.nvim_set_hl(0, "@lsp.type.macro", { link = "_macros" })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.c", { link = "_macros" })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.rust", { link = "_macros" })

                -- vim.api.nvim_set_hl(0, "Function", { fg = '#002040' })
                -- vim.api.nvim_set_hl(0, "Function", { fg = '#102848' })
                vim.api.nvim_set_hl(0, "Function", { fg = '#0c1e36' })
                vim.api.nvim_set_hl(0, "rustFuncName", { bold = true })
                vim.api.nvim_set_hl(0, "rustFuncCall", { bold = false })

                vim.api.nvim_set_hl(0, "Statement", { fg = '#505050' })

            else
                vim.cmd("highlight Normal guibg=#171914 ctermbg=none")
                vim.api.nvim_set_hl(0, "NormalFloat", { bg = '#444444', fg = '#dddddd', italic = true, bold = false })

                vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#cc80cc', italic = true, bold = false })

                vim.api.nvim_set_hl(0, "@lsp.type.string.rust", { fg = '#80c070', italic = true })
                vim.api.nvim_set_hl(0, "rustString", { fg = '#80c070' })
                vim.api.nvim_set_hl(0, "rustStringContinuation", { fg = '#80c070' })
                vim.api.nvim_set_hl(0, "rustStringDelimiter", { fg = '#80c070' })
                vim.api.nvim_set_hl(0, "rustEscape", { fg = '#80c070' })

                vim.api.nvim_set_hl(0, "_macros", { fg = '#bf8c8c', italic = true })
                vim.api.nvim_set_hl(0, "@lsp.type.macro", { link = "_macros" })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.c", { link = "_macros" })
                vim.api.nvim_set_hl(0, "@lsp.type.macro.rust", { link = "_macros" })

                -- vim.api.nvim_set_hl(0, "Function", { fg = '#ccdcdc' })
                vim.api.nvim_set_hl(0, "rustFuncCall", { bold = false })
                vim.api.nvim_set_hl(0, "rustFuncName", { bold = true })

                vim.api.nvim_set_hl(0, "Statement", { fg = '#b8b8b8' })
            end
        end

        -- torte
        if target_torte[args.match] then
            vim.cmd.highlight('IndentLine guifg=#555555')
            vim.cmd.highlight('IndentLineCurrent guifg=#bbbbbb')

            vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { fg = "#888888" })

            -- vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#ffa0ff', italic = true, bold = false })
            vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#cc80cc', italic = true, bold = false })
            vim.api.nvim_set_hl(0, "Comment", { link = "@lsp.type.comment" })

            vim.api.nvim_set_hl(0, "@lsp.type.string", { fg = '#ccffcc', italic = true })

            vim.api.nvim_set_hl(0, "@lsp.type.operator", { fg = "#ffff00" })

            vim.api.nvim_set_hl(0, "@lsp.type.builtin", { fg = "#ff8000", bold = false, underline = true })

            vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = "#c0ffc0", italic = true })
            vim.api.nvim_set_hl(0, "@lsp.type.variable", { fg = "#ffffff" })

            vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = "#80ffff", italic = false, underline = false }) -- true
            vim.api.nvim_set_hl(0, "@lsp.type.method", { fg = "#80ffff", italic = false, underline = false }) -- true

            vim.api.nvim_set_hl(0, "@lsp.type.type", { fg = '#00ccff' })

            vim.api.nvim_set_hl(0, "@lsp.type.keyword", { italic = true })

            vim.api.nvim_set_hl(0, "@lsp.type.parameter", { fg = "#ffffff", italic = false })

            -- vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = '#80f080', underline = false })
            vim.api.nvim_set_hl(0, "@lsp.type.enum", { fg = '#f0c0c0', bold = true })
            vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { fg = '#c0a0a0', italic = true })
            vim.api.nvim_set_hl(0, "@lsp.type.enum.cpp", { fg = '#00c000' })
            vim.api.nvim_set_hl(0, "@lsp.type.struct", { fg = '#00f000' })
            vim.api.nvim_set_hl(0, "@lsp.type.namespace", { fg = '#ff8888', italic = true })

            vim.api.nvim_set_hl(0, "@lsp.type.macro", { fg = '#c040ff', bold = true, underline = false })

            -- RUST
            vim.api.nvim_set_hl(0, "rustUnsafeKeyword", { fg = '#ff4000' })
            vim.api.nvim_set_hl(0, "rustSigil", { fg = '#ff8000' })
            vim.api.nvim_set_hl(0, "rustStorage", { fg='#00ccff' })
            vim.api.nvim_set_hl(0, "rustKeyword", { fg='#ffff00', italic = true })

            vim.api.nvim_set_hl(0, "rustAwait", { fg = '#c0c0f0', italic = true })
            vim.api.nvim_set_hl(0, "rustAsync", { link = 'rustAwait' })

            vim.api.nvim_set_hl(0, "rustStructure", { fg = '#ffffc0' })
            vim.api.nvim_set_hl(0, "rustTypedef", { link = 'rustStructure' })
            vim.api.nvim_set_hl(0, "@lsp.type.interface.rust", { fg = '#ff60a0', italic = true })
            vim.api.nvim_set_hl(0, "@lsp.type.macro.rust", { fg = '#c040ff', bold = true, underline = true })
            vim.api.nvim_set_hl(0, "@lsp.type.namespace.rust", { fg=  '#c0c0c0' })
            vim.api.nvim_set_hl(0, "@lsp.type.const.rust", { fg=  '#ffffff', bold = true, italic = true })


            -- C
            vim.api.nvim_set_hl(0, "cInclude", { link = "@lsp.type.macro" })
            vim.api.nvim_set_hl(0, "cType", { link = "@lsp.type.type"})
            vim.api.nvim_set_hl(0, "@type.builtin.c", { link = "@lsp.type.type"})
            vim.api.nvim_set_hl(0, "cComment", { link = "@lsp.type.comment" })
            vim.api.nvim_set_hl(0, "comment.c", { link = "@lsp.type.comment" })
            vim.api.nvim_set_hl(0, "cParen", { link = "@lsp.type.operator" })
            vim.api.nvim_set_hl(0, "cStorageClass", { fg = "#ff8000", bold = false, underline = false })
            vim.api.nvim_set_hl(0, "cFormat", { fg = "#aaaaaa", italic = true })
            vim.api.nvim_set_hl(0, "@punctuation.bracket.c", { fg = '#cccccc' })

            -- CPP
            vim.api.nvim_set_hl(0, "cppType", { link = "@lsp.type.type"})
            vim.api.nvim_set_hl(0, "cppCast", { fg = "#ff0080", bold = false, underline = true, italic = true })

            -- ZIG
            vim.api.nvim_set_hl(0, "zigBlock", { link = "@lsp.type.variable.zig" })
            vim.api.nvim_set_hl(0, "zigType", { link = "@lsp.type.type"})
            vim.api.nvim_set_hl(0, "zigVarDecl", { fg = '#aaaaaa', bold = true, italic = true })
            vim.api.nvim_set_hl(0, "zigPreProc", { fg = "#ff3333", italic = true, bold = false })
            vim.api.nvim_set_hl(0, "zigExecution", { fg = "#ffffc0", italic = true, bold = true })
            vim.api.nvim_set_hl(0, "zigBuiltinFn", { link = "@lsp.type.builtin" })
            vim.api.nvim_set_hl(0, "zigString", { link = "@lsp.type.keyword" })
            vim.api.nvim_set_hl(0, "zigCommentLine", { link = "@lsp.type.comment" })

            vim.cmd([[
              highlight DiagnosticUnderlineError gui=undercurl guisp=red
              highlight DiagnosticUnderlineWarn  gui=undercurl guisp=yellow
              highlight DiagnosticUnderlineHint  gui=undercurl guisp=blue
              highlight DiagnosticUnderlineInfo  gui=undercurl guisp=gray
            ]])

            -- nvim tree
            vim.api.nvim_set_hl(0, "NeoTreeMessage", { fg = "#808080" })
            vim.api.nvim_set_hl(0, "NeoTreeFileStats", { fg = "#a0a0a0" })
            vim.api.nvim_set_hl(0, "NeoTreeFileStatsHeader", { fg = "#ffff00" })

            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#282c38" })

            -- max page width thingy
            vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#002018" })



            vim.api.nvim_set_hl(0, "Whitespace", { fg = "#404040" })

            vim.api.nvim_set_hl(0, "Search", { bg = "#f1d4af", fg = "#000000" })
            vim.api.nvim_set_hl(0, "IncSearch", { bg = "#e67e22", fg = "#ffffff" })

            -- BACKGROUND
            -- vim.cmd("highlight Normal guibg=none ctermbg=none")
            vim.cmd("highlight Normal guibg=#14171a ctermbg=none")
            -- vim.cmd("highlight Normal guibg=#24272a ctermbg=none")
        end
    end,
})

-- stop treesitter
vim.treesitter.stop()

vim.opt.bg = 'light'
vim.cmd.colorscheme 'quiet'


vim.opt.list = true
vim.opt.listchars = { leadmultispace = "│   " }

vim.opt_local.textwidth = 100
vim.opt_local.colorcolumn = "101"
