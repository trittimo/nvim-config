return {
    {
		"tinted-theming/tinted-vim",
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
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "lua", "python", "javascript", "bash", "cpp", "c", "rust", "c_sharp"
                },
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = { enable = true }
            })
        end
    },
    {
        "seblyng/roslyn.nvim",
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
        config = function()
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

            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('ts_ls')
            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('roslyn')
            vim.lsp.enable('html')

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
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
        },
        keys = {
        },
    },
    {
        'smoka7/hop.nvim',
        version = "*",
        opts = {
            keys = 'etovxqpdygfblzhckisuran'
        },
        keys = {
            { "<C-S-f>", "<cmd>:HopWord<cr>", desc = "Hop Word" }
        }
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = function()
            local actions = require("telescope.actions")
            return {
                pickers = {
                    -- Can setup specific picker defaults here, e.g.
                    -- tags = {
                    --     mappings = { ... }
                    -- }
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
            { "<leader>t",   "<cmd>:Telescope tags<cr>", desc = "Telescope tags" },
            { "<leader>m",   "<cmd>:Telescope marks<cr>", desc = "Telescope marks" },
            { "<leader>f",   "<cmd>:Telescope live_grep<cr>", desc = "Telescope grep all files" },
            { "<leader>?", "<cmd>:Telescope keymaps<cr>", desc = "Telescope keymaps" },
            { "<leader>b", "<cmd>:Telescope buffers<cr>", desc = "Telescope keymaps" },
            { "<C-S-p>",   "<cmd>:Telescope commands<cr>", desc = "Telescope commands" },
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
        "AckslD/muren.nvim",
        config = true,
        keys = {
            { "<C-S-r>", "<cmd>:MurenToggle<cr>", desc = "Open Muren (regex replace)" }
        }
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "neovim/nvim-lspconfig",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        opts = function()
            local cmp = require("cmp")
            return {
                snippet = {
                    expand = function(args)
                        vim.snippet.expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    -- Accept currently selected item.
                    -- Set `select` to `false` to only confirm explicitly selected items.
                    ['<CR>'] = cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
                }),
                experimental = {
                    ghost_text = true,
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "path" }
                },
            }
        end
    },
    {
        "shrynx/line-numbers.nvim",
        opts = {},
    }
}
