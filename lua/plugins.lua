local plugin_path = function(p) return vim.fn.stdpath("config") .. "/plugins/" .. p end
local utils = require("utils")("plugins.log")
local lsp_utils = require("lsp_utils")

-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
local treesitter_languages = { -- Map the treesitter name -> filetype
    lua = "lua",
    python = "python",
    javascript = "javascript",
    bash = "bash",
    cpp = "cpp",
    c = "c",
    rust = "rust",
    c_sharp = "csharp",
    sql = "sql",
    razor = "razor",
    html = "html",
}
local lsp_filetypes = {
    "html",
    "rust",
    "lua",
    "ccp",
    "javascript"
}
local treesitter_filetypes = {}
for _,v in pairs(treesitter_languages) do table.insert(treesitter_filetypes, v) end

return {
    {
        "trittimo/file-gui",
        lazy = true,
        dir = plugin_path("trittimo/file-gui"),
        dev = true,
        opts = {},
        keys = {
            { "<C-M-o>", function() require("file-gui"):select_folder() end }
        }
    },
    {
        "nvim-tree/nvim-tree.lua",
        lazy = true,
        dir = plugin_path("nvim-tree/nvim-tree.lua"),
        dev = true,
        opts = {
            on_attach = function(bufnr)
                -- :help nvim-tree-api
                local api = require("nvim-tree.api")
                local function delete_file()
                    api.fs.trash(api.tree.get_node_under_cursor())
                end
                api.config.mappings.default_on_attach(bufnr)
                vim.keymap.set("n", "<C-k>", "3k", {buffer = bufnr, noremap = true, silent = true, nowait = true})
                vim.keymap.set("n", "<C-j>", "3j", {buffer = bufnr, noremap = true, silent = true, nowait = true})
                vim.keymap.set("n", "<C-d>", delete_file, {buffer = bufnr, noremap = true, silent = true, nowait = true})
            end,
            trash = {
                cmd = utils.is_windows and "Remove-Item -Recurse" or "rm -rf"
            }
        },
        cmd = {
            "NvimTreeFindFileToggle",
            "NvimTreeClipboard",
            "NvimTreeFindFile",
            "NvimTreeRefresh",
            "NvimTreeFocus",
            "NvimTreeToggle",
            "NvimTreeClose",
            "NvimTreeOpen"
        }
    },
    {
        "tpope/vim-dadbod",
        lazy = true,
        dir = plugin_path("tpope/vim-dadbod"),
        dev = true,
        opts = {
        }
    },
    {
        "kristijanhusak/vim-dadbod-completion",
        lazy = true,
        dir = plugin_path("kristijanhusak/vim-dadbod-completion"),
        dev = true,
        ft = { "sql", "mysql", "plsql" },
        opts = {
        }
    },
    {
        "kristijanhusak/vim-dadbod-ui",
        lazy = true,
        dir = plugin_path("kristijanhusak/vim-dadbod-ui"),
        dev = true,
        dependencies = {
            { "tpope/vim-dadbod" },
            { "kristijanhusak/vim-dadbod-completion" },
        },
        ft = { "sql", "mysql", "plsql" },
        cmd = {
            "DBUI",
            "DBUIToggle",
            "DBUIAddConnection",
            "DBUIFindBuffer",
        },
    },
    {
        "nvim-lua/plenary.nvim",
        lazy = true,
        dir = plugin_path("nvim-lua/plenary.nvim"),
        dev = true

    },
    {
		"tinted-theming/tinted-vim",
		lazy = false, -- load at start
        dir = plugin_path("tinted-theming/tinted-vim"),
        dev = true,
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
        lazy = true,
        dir = plugin_path("nvim-treesitter/nvim-treesitter"),
        dev = true,
        build = ":TSUpdate",
        ft = treesitter_filetypes,
        config = function()
            local treesitter = require("nvim-treesitter")
            treesitter.setup({
                highlight = { enable = true },
                indent = { enable = true },
                incremental_selection = { enable = true }
            })
            local treesitter_remote_names = {}; for k,_ in pairs(treesitter_languages) do table.insert(treesitter_remote_names, k) end
            treesitter.install(treesitter_remote_names)

            vim.api.nvim_create_autocmd('FileType', {
                pattern = treesitter_filetypes,
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
        lazy = true,
        dir = plugin_path("seblyng/roslyn.nvim"),
        dev = true,
        ft = { "razor", "csharp", "csproj", "sln" },
        config = function()
            if lsp_utils:check("roslyn") then
                vim.lsp.config("roslyn", {
                    cmd = lsp_utils.roslyn:cmd(),
                    filetypes = { "razor", "csharp" },
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
                    }
                })
                vim.lsp.enable('roslyn')
            end
        end,
        init = function()
            vim.filetype.add({
                extension = {
                    razor = "razor",
                    cshtml = "razor",
                    cs = "csharp",
                    csproj = "csproj",
                    sln = "sln"
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dev = true,
        ft = lsp_filetypes,
        dir = plugin_path("neovim/nvim-lspconfig"),
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities.textDocument.completion.completionItem.snippetSupport = true
            -- Requires running `npm i -g vscode-langservers-extracted`
            vim.lsp.config("html", {
                capabilities = capabilities,
                cmd = { "vscode-html-language-server", "--stdio" }
            })

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

            if lsp_utils:check("lua") then
                vim.lsp.config("lua_ls", {
                    cmd = lsp_utils.lua:cmd(),
                    filetypes = { "lua" },
                    on_init = function(client)
                        if client.workspace_folders then
                            local path = client.workspace_folders[1].name
                            if path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
                                return
                            end
                        end

                        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
                            runtime = {
                                version = 'LuaJIT', -- Version of Lua to run
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
                            }
                        })
                    end,
                    settings = {
                        Lua = {}
                    }
                })
            end

            if lsp_utils:check("clangd") then
                vim.lsp.config("clangd", {
                    cmd = lsp_utils.clangd:cmd(),
                    filetypes = { "c", "cpp" }
                })
            end

            vim.lsp.enable('rust_analyzer')
            -- vim.lsp.enable('ts_ls')
            vim.lsp.enable('html')
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
                    vim.keymap.set({'n','v','i'}, '<C-.>', vim.lsp.buf.code_action, opts)
                    vim.keymap.set({'n','v','i'}, '<C-,>', vim.diagnostic.open_float, opts)
                    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
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
    {
        "saghen/blink.cmp",
        dir = plugin_path("saghen/blink.cmp"),
        build = "cargo build --release",
        dev = true,
        opts_extend = { "sources.default" },
        opts = {
            keymap = {
                preset = "none",
                ["<C-space>"] = { function(cmp) cmp.show({ providers = { "snippets" } }) end },
                ["<C-e>"] = { "hide", "fallback" },
                ["<S-k>"] = { "show_signature", "show_documentation", "hide_signature", "fallback" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
                ["<C-S-k>"] = { "scroll_documentation_up", "fallback" },
                ["<C-S-j>"] = { "scroll_documentation_down", "fallback" },
                ["<Tab>"] = { "accept", "fallback" }
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" }
            },
            fuzzy = { implementation = "rust" }
        }
    },
    {
        -- Causes me headaches in a lot of buffers
        -- Might revisit at some point
        "shrynx/line-numbers.nvim",
        dir = plugin_path("shrynx/line-numbers.nvim"),
        dev = true,
        opts = {},
        enabled = false
    },
    {
        "junegunn/fzf",
        lazy = true,
        dir = plugin_path("junegunn/fzf"),
        dev = true
    },
    {
        "junegunn/fzf.vim",
        lazy = true,
        dir = plugin_path("junegunn/fzf.vim"),
        dev = true,
        cmd = { "Files", "Fzf", "Rg", "Buffers" },
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
