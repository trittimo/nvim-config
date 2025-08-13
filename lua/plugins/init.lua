return {
    {
		"wincent/base16-nvim",
		lazy = false, -- load at start
		priority = 1000, -- load first
		config = function()
			vim.cmd([[colorscheme chalkboard]])
			vim.o.background = 'dark'
			vim.cmd([[hi Normal ctermbg=NONE]])
			-- Less visible window separator
			vim.api.nvim_set_hl(0, "WinSeparator", { fg = 1250067 })
			-- Make comments more prominent -- they are important.
			local bools = vim.api.nvim_get_hl(0, { name = 'Boolean' })
			vim.api.nvim_set_hl(0, 'Comment', bools)
			-- Make it clearly visible which argument we're at.
			local marked = vim.api.nvim_get_hl(0, { name = 'PMenu' })
			vim.api.nvim_set_hl(0, 'LspSignatureActiveParameter', { fg = marked.fg, bg = marked.bg, ctermfg = marked.ctermfg, ctermbg = marked.ctermbg, bold = true })
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
        "neovim/nvim-lspconfig",
        config = function()
            -- Stole most of this from https://github.com/jonhoo/configs/blob/master/editor/.config/nvim/init.lua
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
                        -- imports = {
                        --     group = {
                        --         enable = false,
                        --     },
                        -- },
                        -- completion = {
                        --     postfix = {
                        --         enable = false,
                        --     },
                        -- },
                    },
                },
            })
            vim.lsp.enable('rust_analyzer')

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
            vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

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
                    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
                    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
                    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
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
            { "f", "<cmd>:HopWord<cr>", desc = "Hop Word" }
        }
    },
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { 'nvim-lua/plenary.nvim' },
        keys = {
            { "<leader>f", "<cmd>:Telescope find_files<cr>", desc = "Telescope Find Files" },
            { "<C-S-f>",   "<cmd>:Telescope live_grep<cr>",  desc = "Telescope grep all files" },
            { "<leader>?", "<cmd>:Telescope keymaps<cr>",    desc = "Telescope keymaps" },
            { "<C-S-p>",   "<cmd>:Telescope commands<cr>",   desc = "Telescope commands" }
        }
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        config = function()
            local telescope = require("telescope")
            telescope.setup({
                extensions = {
                    file_browser = {
                        hijack_netrw = true
                    }
                }
            })
            telescope.load_extension("file_browser")
        end
    },
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
