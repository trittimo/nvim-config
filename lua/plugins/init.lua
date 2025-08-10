return {
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
            local lspconfig = require("lspconfig")
            lspconfig.lua_ls.setup({})
            lspconfig.rust_analyzer.setup({})
            lspconfig.ts_ls.setup({})
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
            { "<C-S-f>", "<cmd>:Telescope live_grep<cr>", desc = "Telescope grep all files" },
            { "<leader>?", "<cmd>:Telescope keymaps<cr>", desc = "Telescope keymaps" },
            { "<C-S-p>", "<cmd>:Telescope commands<cr>", desc = "Telescope commands" }
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
    }
}
