local plugin_path = function(p) return vim.fn.stdpath("config") .. "/plugins/" .. p end
return {
    {
        "nvim-tree/nvim-tree.lua",
        dir = plugin_path("nvim-tree/nvim-tree.lua"),
        dev = true,
        opts = {
        }
    },
    {
        "hrsh7th/cmp-nvim-lsp",
        dir = plugin_path("hrsh7th/cmp-nvim-lsp"),
        dev = true
    },
    {
        "hrsh7th/cmp-buffer",
        dir = plugin_path("hrsh7th/cmp-buffer"),
        dev = true

    },
    {
        "hrsh7th/cmp-path",
        dir = plugin_path("hrsh7th/cmp-path"),
        dev = true

    },
    {
        "nvim-lua/plenary.nvim",
        dir = plugin_path("nvim-lua/plenary.nvim"),
        dev = true

    },
    {
		"tinted-theming/tinted-vim",
        dir = plugin_path("tinted-theming/tinted-vim"),
        dev = true,
		lazy = false, -- load at start
		priority = 1000, -- load first
		config = function()
            -- Opacity seemed like a cool idea but it's mostly distracting
            -- vim.g.neovide_opacity = 0.95
            -- vim.g.neovide_normal_opacity = 0.95
			vim.cmd.colorscheme("base16-material-darker")
		end,
        enabled = function()
            return vim.g.neovide
        end
	},
    {
        "nvim-treesitter/nvim-treesitter",
        dir = plugin_path("nvim-treesitter/nvim-treesitter"),
        dev = true,
        build = ":TSUpdate",
        lazy = false,
        config = function()
            local treesitter = require("nvim-treesitter")
            treesitter.setup({
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = { enable = true }
            })
            treesitter.install({
                "lua", "python", "javascript", "bash", "cpp", "c", "rust", "c_sharp", "sql"
            })

            vim.api.nvim_create_autocmd('FileType', {
                pattern = { "lua", "python", "javascript", "cpp", "csharp", "sql" },
                callback = function()
                    vim.treesitter.start()
                    vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.wo[0][0].foldmethod = 'expr'

                    -- Note, this one is experimental
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            })
        end
    },
    {
        "seblyng/roslyn.nvim",
        dir = plugin_path("seblyng/roslyn.nvim"),
        dev = true,
        ft = { "cs", "razor" },
        config = function()
            vim.lsp.config("roslyn", {
                cmd = cmd,
                settings = {
                    ["csharp|inlay_hints"] = {
                        csharp_enable_inlay_hints_for_implicit_object_creation = true,
                        csharp_enable_inlay_hints_for_implicit_variable_types = true,

                        csharp_enable_inlay_hints_for_lambda_parameter_types = true,
                        csharp_enable_inlay_hints_for_types = true,
                        dotnet_enable_inlay_hints_for_indexer_parameters = true,
                        dotnet_enable_inlay_hints_for_literal_parameters = true,
                        dotnet_enable_inlay_hints_for_object_creation_parameters = true,
                        dotnet_enable_inlay_hints_for_other_parameters = true,
                        dotnet_enable_inlay_hints_for_parameters = true,
                        dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
                        dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
                        dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
                    },
                    ["csharp|code_lens"] = {
                        dotnet_enable_references_code_lens = true,
                    },
                },
            })
        end,
        init = function()
            vim.filetype.add({
                extension = {
                    razor = "razor",
                    cshtml = "razor",
                },
            })
        end,
    },
    -- Come back to this some day if it actually fucking works
    -- {
    --     "seblyng/roslyn.nvim",
    --     ft = { "cs", "razor" },
    --     dependencies = {
    --         {
    --             "tris203/rzls.nvim",
    --             config = true,
    --         },
    --     },
    --     config = function()
    --         local roslyn_base_path = vim.fs.joinpath(
    --             vim.fn.stdpath("data"),
    --             "roslyn",
    --             "artifacts",
    --             "bin",
    --             "Microsoft.CodeAnalysis.LanguageServer",
    --             "Release",
    --             "net9.0"
    --         )
    --         local rzls_base_path = vim.fs.joinpath(
    --             vim.fn.stdpath("data"),
    --             "razor",
    --             "artifacts",
    --             "bin",
    --             "Microsoft.CodeAnalysis.Razor.Compiler",
    --             "Release",
    --             "net9.0"
    --         )
    --
    --         local cmd = {
    --             "dotnet",
    --             vim.fs.joinpath(roslyn_base_path, "Microsoft.CodeAnalysis.LanguageServer.dll"),
    --             "--stdio",
    --             "--logLevel=Information",
    --             "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.get_log_path()),
    --             "--razorSourceGenerator=" .. vim.fs.joinpath(rzls_base_path, "Microsoft.CodeAnalysis.Razor.Compiler.dll"),
    --             "--razorDesignTimePath="
    --                 .. vim.fs.joinpath(rzls_base_path, "Targets", "Microsoft.NET.Sdk.Razor.DesignTime.targets"),
    --         }
    --
    --         vim.lsp.config("roslyn", {
    --             cmd = cmd,
    --             handlers = require("rzls.roslyn_handlers"),
    --             settings = {
    --                 ["csharp|inlay_hints"] = {
    --                     csharp_enable_inlay_hints_for_implicit_object_creation = true,
    --                     csharp_enable_inlay_hints_for_implicit_variable_types = true,
    --
    --                     csharp_enable_inlay_hints_for_lambda_parameter_types = true,
    --                     csharp_enable_inlay_hints_for_types = true,
    --                     dotnet_enable_inlay_hints_for_indexer_parameters = true,
    --                     dotnet_enable_inlay_hints_for_literal_parameters = true,
    --                     dotnet_enable_inlay_hints_for_object_creation_parameters = true,
    --                     dotnet_enable_inlay_hints_for_other_parameters = true,
    --                     dotnet_enable_inlay_hints_for_parameters = true,
    --                     dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
    --                     dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
    --                     dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    --                 },
    --                 ["csharp|code_lens"] = {
    --                     dotnet_enable_references_code_lens = true,
    --                 },
    --             },
    --         })
    --     end,
    --     init = function()
    --         vim.filetype.add({
    --             extension = {
    --                 razor = "razor",
    --                 cshtml = "razor",
    --             },
    --         })
    --     end,
    -- },
    {
        "neovim/nvim-lspconfig",
        dir = plugin_path("neovim/nvim-lspconfig"),
        dev = true,
        config = function()
            local lsp_utils = require("lsp_utils")
            vim.lsp.config('rust_analyzer', {
                -- Server-specific settings. See `:help lspconfig-setup`
                settings = {
                    ["rust-analyzer"] = {
                        cargo = {
                            features = "all",
                        },
                        checkOnSave = {
                            enable = true,
                        },
                    },
                },
            })


            vim.lsp.config('lua_ls', {
                on_init = function(client)
                    if client.workspace_folders then
                        local path = client.workspace_folders[1].name
                        if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                            return
                        end
                    end

                    client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                        runtime = {
                            -- Tell the language server which version of Lua you're using (most
                            -- likely LuaJIT in the case of Neovim)
                            version = 'LuaJIT',
                            -- Tell the language server how to find Lua modules same way as Neovim
                            -- (see `:h lua-module-load`)
                            path = {
                                'lua/?.lua',
                                'lua/?/init.lua',
                            },
                        },
                        -- Make the server aware of Neovim runtime files
                        workspace = {
                            checkThirdParty = false,
                            library = {
                                vim.env.VIMRUNTIME
                                -- Depending on the usage, you might want to add additional paths
                                -- here.
                                -- '${3rd}/luv/library'
                                -- '${3rd}/busted/library'
                            }
                            -- Or pull in all of 'runtimepath'.
                            -- NOTE: this is a lot slower and will cause issues when working on
                            -- your own configuration.
                            -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                            -- library = {
                                --   vim.api.nvim_get_runtime_file('', true),
                                -- }
                        }
                    })
                end,
                settings = {
                    Lua = {}
                }
            })

            if lsp_utils.clangd.cmd then
                vim.lsp.config("clangd", {
                    cmd = lsp_utils.clangd:cmd(),
                    filetypes = { "c", "cpp", "h" }
                })
            end

            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('ts_ls')
            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('roslyn')
            vim.lsp.enable('html')
            vim.lsp.enable('cpp')
            vim.lsp.enable('clangd')
            vim.lsp.enable('lua_ls')

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
                group = vim.api.nvim_create_augroup('UserLspConfig', {}),
                callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    local opts = { buffer = ev.buf }
                    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
                    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
                    vim.keymap.set('n', '<S-k>', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
                    vim.keymap.set('n', '<leader>wl', function()
                        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                    end, opts)
                    vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, opts)
                    vim.keymap.set({'n','v','i'}, '<C-,>', vim.lsp.buf.code_action, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

                    local client = vim.lsp.get_client_by_id(ev.data.client_id)

                    -- TODO: find some way to make this only apply to the current line.
                    -- if client.server_capabilities.inlayHintProvider then
                    --     vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
                    -- end

                    -- None of this semantics tokens business.
                    -- https://www.reddit.com/r/neovim/comments/143efmd/is_it_possible_to_disable_treesitter_completely/
                    client.server_capabilities.semanticTokensProvider = nil

                    -- format on save for Rust
                    -- if client.server_capabilities.documentFormattingProvider then
                    --     vim.api.nvim_create_autocmd("BufWritePre", {
                    --         group = vim.api.nvim_create_augroup("RustFormat", { clear = true }),
                    --         buffer = bufnr,
                    --         callback = function()
                    --             vim.lsp.buf.format({ bufnr = bufnr })
                    --         end,
                    --     })
                    -- end
                end,
            })
        end
    },
    {
        "smoka7/hop.nvim",
        dir = plugin_path("smoka7/hop.nvim"),
        dev = true,
        version = "*",
        opts = {
            keys = 'etovxqpdygfblzhckisuran'
        },
        keys = {
            { "<C-S-f>", "<cmd>:HopWord<cr>", desc = "Hop Word" }
        }
    },
    {
        "nvim-telescope/telescope.nvim",
        dir = plugin_path("nvim-telescope/telescope.nvim"),
        dev = true,
        opts = function()
            local actions = require("telescope.actions")
            return {
                pickers = {
                    -- Can setup specific picker defaults here, e.g.
                    buffers = {
                        mappings = {
                            n = {
                                ["<C-d>"] = actions.delete_buffer
                            },
                            i = {
                                ["<C-d>"] = actions.delete_buffer
                            }
                        }
                    }
                },
                defaults = {
                    mappings = {
                        i = {
                            ["<C-j>"] = actions.move_selection_next,
                            ["<C-k>"] = actions.move_selection_previous,
                        }
                    },
                    vimgrep_arguments = {
                        "rg",
                        "--color=never",
                        "--no-heading",
                        "--with-filename",
                        "--line-number",
                        "--column",
                        "--smart-case",
                    }
                }
            }
        end,
        keys = {
            { "<leader>t", "<cmd>:Telescope tags<cr>", desc = "Telescope tags" },
            { "<leader>m", "<cmd>:Telescope marks<cr>", desc = "Telescope marks" },
            { "<leader>f", "<cmd>:Telescope live_grep<cr>", desc = "Telescope grep all files" },
            { "<leader>f", mode = {"v"}, desc = "Telescope grep all files",
                function()
                    require("telescope.builtin").grep_string({
                        grep_open_files = false,
                        word_match = "-w"
                    })
                end
            },
            { "<leader>?", "<cmd>:Telescope keymaps<cr>", desc = "Telescope keymaps" },
            { "<leader>b", "<cmd>:Telescope buffers<cr>", desc = "Telescope keymaps" },
            { "<C-S-p>", "<cmd>:Telescope commands<cr>", desc = "Telescope commands" },
        },
    },
    -- This extension just adds too many headaches. It crashes nvim in massive directories
    -- Nice in theory though
    -- {
    --     "nvim-telescope/telescope-file-browser.nvim",
    --     dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    --     config = function()
    --         local telescope = require("telescope")
    --         telescope.setup({
    --             extensions = {
    --                 file_browser = {
    --                     hijack_netrw = true,
    --                     depth = false,
    --                     respect_gitignore = true,
    --                     grouped = true,
    --                     hide_parent_dir = true,
    --                     mappings = {
    --                         i = {
    --                             ["<C-k>"] = function(prompt_bufnr)
    --                                 local action_set = require("telescope.actions.set")
    --                                 action_set.shift_selection(prompt_bufnr, -10)
    --                             end,
    --                             ["<C-j>"] = function(prompt_bufnr)
    --                                 local action_set = require("telescope.actions.set")
    --                                 action_set.shift_selection(prompt_bufnr, 10)
    --                             end,
    --                         },
    --                         n = {
    --                             ["<C-k>"] = function(prompt_bufnr)
    --                                 local action_set = require("telescope.actions.set")
    --                                 action_set.shift_selection(prompt_bufnr, -10)
    --                             end,
    --                             ["<C-j>"] = function(prompt_bufnr)
    --                                 local action_set = require("telescope.actions.set")
    --                                 action_set.shift_selection(prompt_bufnr, 10)
    --                             end,
    --                         }
    --                     }
    --                 }
    --             }
    --         })
    --         telescope.load_extension("file_browser")
    --     end
    -- },
    {
        "hrsh7th/nvim-cmp",
        dir = plugin_path("hrsh7th/nvim-cmp"),
        dev = true,
        opts = function()
            local cmp = require("cmp")
            return {
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-S-j>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-S-k>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                    ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                    -- Accept currently selected item.
                    -- Set `select` to `false` to only confirm explicitly selected items.
                    ['<Tab>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
                }),
                experimental = {
                    ghost_text = true,
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "path" },
                    { name = "buffer" }
                },
            }
        end
    },
    {
        "shrynx/line-numbers.nvim",
        dir = plugin_path("shrynx/line-numbers.nvim"),
        dev = true,
        opts = {},
    },
    {
        "junegunn/fzf",
        dir = plugin_path("junegunn/fzf"),
        dev = true
    },
    {
        "junegunn/fzf.vim",
        dir = plugin_path("junegunn/fzf.vim"),
        dev = true,
        cmd = { "Files", "FZF", "Rg", "Buffers" },
        init = function()
            -- Use fd for file listing (huge speed win)
            vim.env.FZF_DEFAULT_COMMAND = "fd --type f --hidden --follow --exclude .git"

            -- Better layout, still terminal-based
            vim.env.FZF_DEFAULT_OPTS = "--height=80% --layout=reverse"

            -- Faster file command
            vim.g.fzf_files_options = "--preview-window=hidden"

            -- :Fzf alias
            vim.cmd("command! Fzf Files")
        end
    },
    {
        "lewis6991/gitsigns.nvim",
        dir = plugin_path("lewis6991/gitsigns.nvim"),
        dev = true,
        event = { "BufReadPre", "BufNewFile" },
        opts = function()
            return {
                word_diff = false,
                on_attach = function(bufnr)
                    local gitsigns = require("gitsigns")
                    local function map(mode, l, r, opts)
                        opts = opts or {}
                        opts.buffer = bufnr
                        vim.keymap.set(mode, l, r, opts)
                    end

                    -- Navigation
                    map('n', ']c', function()
                        if vim.wo.diff then
                            -- In a diff window
                            vim.cmd.normal({']c', bang = true})
                        else
                            gitsigns.nav_hunk('next')
                        end
                    end)

                    map('n', '[c', function()
                        if vim.wo.diff then
                            -- In a diff window
                            vim.cmd.normal({'[c', bang = true})
                        else
                            gitsigns.nav_hunk('prev')
                        end
                    end)
                    -- git diff
                    map('n', '<leader>gd', function()
                        local current_buffer = vim.api.nvim_get_current_buf()
                        vim.api.nvim_create_autocmd("BufEnter", {
                            callback = function(args)
                                -- The plugin opens the gitsigns buffer and then re-activates the original window
                                if vim.api.nvim_get_current_buf() ~= current_buffer then
                                    return false
                                end
                                vim.cmd("wincmd h")
                                return true
                            end
                        })
                        gitsigns.diffthis("~")
                    end)
                end
            }
        end
    }
}
