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
            require("lspconfig")
                .lua_ls
                .setup({})
        end
    }
}
