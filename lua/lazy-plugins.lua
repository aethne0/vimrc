--------------------------------------------------------------------------------
---- lua/lazy.lua --------------------------------------------------------------
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
        local lazyrepo = "https://github.com/folke/lazy.nvim.git"
        local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
        if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo(
            {
                { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
                { out, "WarningMsg" },
                { "\nPress any key to exit..." },
            }, 
            true, {}
        )
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
    spec = {

        { "catppuccin/nvim", name = "catppuccin", priority = 1000,
            config = function()
                require('catppuccin').setup({
                    flavor = 'latte',
                    -- transparent_background = true,
                    float = {
                        -- transparent = true,
                    },
                    integrations = {
                        cmp = true,
                        gitsigns = true,
                        nvimtree = true,
                        notify = true,
                        mini = {
                            enabled = true,
                        },
                    }
                })

                local hour = tonumber(os.date("%H"))
                local is_day = (hour >= 6 and hour < 17)
                if is_day then
                    vim.cmd.colorscheme 'catppuccin-latte'
                end
            end
        },

        { "bluz71/vim-moonfly-colors", name = "moonfly", },

        {
              "folke/tokyonight.nvim",
              lazy = false,
              priority = 1000,
              opts = {},
              config = function()
                  require('tokyonight').setup({})
                  local hour = tonumber(os.date("%H"))
                  local is_day = (hour >= 6 and hour < 17)
                  if not is_day then
                      vim.cmd.colorscheme 'tokyonight-moon'
                  end
              end
        },

        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
            require("nvim-treesitter.configs").setup {
                ensure_installed = { "elixir", "heex", "eex", "go" },
                highlight = { enable = true },
            }
            end,
        },

        -- lsp
        { 
            'mason-org/mason-lspconfig.nvim',

            dependencies = {
                'neovim/nvim-lspconfig',
                'mason-org/mason.nvim',
            },

            config = function()
                require('mason').setup()
                require('mason-lspconfig').setup()

            end
        },

        {
            "hrsh7th/nvim-cmp",
            -- autocompletion
            dependencies = {
              "hrsh7th/cmp-nvim-lsp",
              "L3MON4D3/LuaSnip",
              "saadparwaiz1/cmp_luasnip",
            },
            config = function()
              local cmp = require("cmp")
              cmp.setup({

                snippet = {
                  expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                  end,
                },

                mapping = cmp.mapping.preset.insert({
                  ["<C-Space>"] = cmp.mapping.complete(),
                  ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),

                sources = cmp.config.sources({
                  { name = "nvim_lsp" },
                  { name = "nvim_lua" },
                  { name = "luasnip" },
                  { name = "path" },
                  { name = "buffer" },
                }),

                formatting = {
                    fields = { "abbr", "menu", "kind" },
                    format = function(entry, item)
                        -- Define menu shorthand for different completion sources.
                        local menu_icon = {
                            nvim_lsp = "LSP",
                            nvim_lua = "LUA",
                            luasnip  = "SNP",
                            buffer   = "BUF",
                            path     = "PWD",
                        }
                        -- Set the menu "icon" to the shorthand for each completion source.
                        item.menu = menu_icon[entry.source.name]

                        -- Set the fixed width of the completion menu to 60 characters.
                        -- fixed_width = 20

                        -- Set 'fixed_width' to false if not provided.
                        fixed_width = fixed_width or false

                        -- Get the completion entry text shown in the completion window.
                        local content = item.abbr

                        -- Set the fixed completion window width.
                        if fixed_width then
                            vim.o.pumwidth = fixed_width
                        end

                        -- Get the width of the current window.
                        local win_width = vim.api.nvim_win_get_width(0)

                        -- Set the max content width based on either: 'fixed_width'
                        -- or a percentage of the window width, in this case 20%.
                        -- We subtract 10 from 'fixed_width' to leave room for 'kind' fields.
                        local max_content_width = fixed_width and fixed_width - 10 or math.floor(win_width * 0.3)

                        -- Truncate the completion entry text if it's longer than the
                        -- max content width. We subtract 3 from the max content width
                        -- to account for the "..." that will be appended to it.
                        if #content > max_content_width then
                            item.abbr = vim.fn.strcharpart(content, 0, max_content_width - 3) .. "..."
                        else
                            item.abbr = content .. (" "):rep(max_content_width - #content)
                        end
                        return item
                    end,
                },

              })
            end,
          },

        {
          -- file explorer etc
          'nvim-telescope/telescope.nvim',
          dependencies = { 
              "nvim-lua/plenary.nvim",
              "nvim-telescope/telescope-live-grep-args.nvim",
          },
            --cmd = { "Telescope" },
            config = function() 
                local t = require('telescope')

                t.setup{
                    extensions = {
                        live_grep_args
                    },
                    defaults = {
                        file_ignore_patterns = {},
                        find_command = { 'rg', '--files', '--ignore', '--hidden' },
                    },
                    pickers = { 
                        colorscheme = {
                            enable_preview = true
                        },
                    },
                }

                t.load_extension('live_grep_args')
            end,
        },

        {
            "folke/which-key.nvim",
            event = "VeryLazy",
            opts = { },
            keys = {
                {
                    "<leader>?",
                    function()
                        local wk = require('which-key')
                        wk.show({ global = true })
                    end,
                    desc = "Buffer Local Keymaps (which-key)",
                },
            },
            config = function()
                local wk = require('which-key')
                wk.add({
                    { "<leader>u", group = "Themes", desc = "colo" },
                })
            end

        },

        { 
            'nvim-neo-tree/neo-tree.nvim',
            version = "3.35", -- TODO: check if this is fixed - 3.36.(1?) broke something
            dependencies = {
                'nvim-lua/plenary.nvim',
                'MunifTanjim/nui.nvim',
            },
            lazy = false,
            config = function()
                require('neo-tree').setup({
                    default_component_configs = {
                        git_status = {
                            symbols = {
                                -- Change type
                                added     = "✚",
                                deleted   = "✖",
                                modified  = "",
                                renamed   = "󰁕",
                                -- Status type
                                untracked = "",
                                ignored   = "",
                                unstaged  = "󰄱",
                                staged    = "",
                                conflict  = "",
                            },
                            align = 'right',
                        },
                    },
                })
                vim.keymap.set("n", '<leader>f',
                    ":Neotree source=filesystem reveal=true position=current toggle=true<CR>",
                    { silent = true }
                )
                vim.keymap.set("n", '<leader>b',
                    ":Neotree source=buffers reveal=true position=current toggle=true<CR>",
                    { silent = true }
                )
                vim.keymap.set("n", '<leader>g',
                    ":Neotree source=git_status reveal=true position=current toggle=true<CR>",
                    { silent = true }
                )
            end
        },

        {
            "folke/noice.nvim",

            event = "VeryLazy",
            opts = { },
            dependencies = {
                "MunifTanjim/nui.nvim",
                "rcarriga/nvim-notify",
            },

            config = function()
                require('noice').setup({
                    cmdline = { enabled = false, },
                    messages = { enabled = false, },
                    popupmenu = { enabled = false, },
                    notify = { enabled = false, },

                    lsp = {
                        override = {
                            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                            ["vim.lsp.util.stylize_markdown"] = true,
                            ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
                        },

                        progress = {
                            enabled = true,
                            -- Lsp Progress is formatted using the builtins for lsp_progress. See config.format.builtin
                            -- See the section on formatting for more details on how to customize.
                            --- @type NoiceFormat|string
                            format = "lsp_progress",
                            --- @type NoiceFormat|string
                            format_done = "lsp_progress_done",
                            throttle = 1000 / 30, -- frequency to update lsp progress message
                            view = "mini",
                        },
                    },

                    presets = {
                        bottom_search = true, -- use a classic bottom cmdline for search
                        command_palette = false, -- position the cmdline and popupmenu together
                        long_message_to_split = true, -- long messages will be sent to a split
                        inc_rename = false, -- enables an input dialog for inc-rename.nvim
                        lsp_doc_border = true, -- add a border to hover docs and signature help
                    },
                })
            end
        },

        {
            'lewis6991/gitsigns.nvim',
            -- this is various git integration, including the left-side symbols
            opts = {
                signs = {
                    add = { text = '+' },
                    change = { text = '~' },
                    delete = { text = '_' },
                    topdelete = { text = '‾' },
                    changedelete = { text = '~' },
                }
            }
        },

        { 
            'unblevable/quick-scope',
        },

        {
            'chentoast/marks.nvim',
            config = function() 
                require('marks').setup()
            end
        },

        {
            -- todo write a better one
            'folke/todo-comments.nvim',
            dependencies = { 'nvim-lua/plenary.nvim' },
            opts = { 
                signs = false,
                keywords = {
                    FIX = {
                      icon = " ", -- icon used for the sign, and in search results
                      color = "error", -- can be a hex color, or a named color (see below)
                      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
                      -- signs = false, -- configure signs for some keywords individually
                    },
                    TODO = { icon = "⇾", color = "info" },
                    HACK = { icon = " ", color = "warning" },
                    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
                    PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
                    LOCK = { icon = " ", color = "lock", },
                    TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
                },
                colors = {
                    lock = { "DiagnosticWarn", "WarningMsg", "#FFFF00" },
                },
            },
        },

        {
            'wellle/context.vim',
        },

        {
            'nvim-lualine/lualine.nvim',
            config = function()
                require('lualine').setup{
                    options = {
                        icons_enabled = false,
                        theme = 'auto',
                        component_separators = { left = '|', right = '|'},
                        section_separators = { left = ' ', right = ' '},
                    }
                }
            end,
        },

        {
            "lukas-reineke/indent-blankline.nvim",
            main = "ibl",
            ---@module "ibl"
            ---@type ibl.config
            opts = {},
            config = function()
                require('ibl').setup()
            end
        },

        {
            'saecki/live-rename.nvim',
            config = function()
                local r = require('live-rename')
                vim.keymap.set('n', '<F2>', r.rename, {desc = 'LSP rename'})
            end
        },

        {
            'davidmh/mdx.nvim',
            dependencies = { 'nvim-treesitter/nvim-treesitter' },
        },


    },
    -- Configure any other settings here. See the documentation for more details.
    -- colorscheme that will be used when installing plugins.
    install = { colorscheme = { 'koehler' } },
    -- automatically check for plugin updates
    checker = { enabled = false },
})

