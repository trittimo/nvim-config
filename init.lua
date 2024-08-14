-- [[Settings]]
-- Spacebar is our leader key
vim.g.mapleader = " "

-- Use 4 spaces for tab
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Show whitespace
vim.cmd(":set list")
vim.cmd(":set lcs+=space:·")

-- :help vim.opt
vim.cmd(":colorscheme slate") vim.cmd(":set relativenumber")

-- [[Keybinds]]
-- :help vim.keymap
-- :help tui-input

-- Remap window movement keys
vim.keymap.set({"n"}, "<C-l>", "<C-w><C-l>") vim.keymap.set({"n"}, "<C-h>",
"<C-w><C-h>") vim.keymap.set({"n"}, "<C-j>", "<C-w><C-j>")
vim.keymap.set({"n"}, "<C-k>", "<C-w><C-k>")
vim.keymap.set({"n"}, "<C-Right>", "<C-w>L")

-- Reload this config file
vim.keymap.set({"n"}, "<leader>r", "<cmd>:luafile $MYVIMRC<CR>")

-- Exit to normal mode
vim.keymap.set({"i"}, "kj", "<esc>")


vim.keymap.set({"n"}, "<C-.>", "<cmd>:cnext<CR>")
vim.keymap.set({"n"}, "<C-,>", "<cmd>:cprev<CR>")

-- [[Functions]]
vim.paste = (function(overridden)
    return function(lines, phase)
        for i,line in ipairs(lines) do
            -- Scrub ANSI color codes from paste input.
            lines[i] = line:gsub('\27%[[0-9;mK]+', '') end overridden(lines, phase)
        end
    end)(vim.paste)
