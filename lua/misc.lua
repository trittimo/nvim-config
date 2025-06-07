-- Spacebar is our leader key
vim.g.mapleader = " "

-- Use 4 spaces for tab
vim.opt.tabstop = 4
vim.opt.expandtab = true

-- Show whitespace
vim.cmd(":set list")
vim.cmd(":set lcs+=space:·")
vim.cmd(":set path+=**")

-- :help vim.opt
vim.cmd(":colorscheme slate")
vim.cmd(":set relativenumber")
