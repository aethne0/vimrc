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


local targets = { ["torte"] = true, ["darkblue"] = true, ["vim"] = true, }
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function(args)
        if targets[args.match] then
            vim.cmd.highlight('IndentLine guifg=#555555')
            vim.cmd.highlight('IndentLineCurrent guifg=#bbbbbb')

            vim.api.nvim_set_hl(0, "DiagnosticUnnecessary", { fg = "#888888" })

            vim.api.nvim_set_hl(0, "@lsp.type.comment", { fg = '#ffa0ff', italic = true, bold = false })
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

            vim.api.nvim_set_hl(0, "CursorLine", { bg = "#282c38" })

            vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#004030" })

            -- BACKGROUND
            vim.cmd("highlight Normal guibg=none ctermbg=none")
            -- vim.cmd("highlight Normal guibg=#1c1c1c ctermbg=none")

        end
    end,
})

vim.cmd.colorscheme 'torte'

