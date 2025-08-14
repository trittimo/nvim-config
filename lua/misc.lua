-- Spacebar is our leader key
vim.g.mapleader = " "

-- Go to the correct indent level automatically
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Use ripgrep for searching
if vim.fn.executable("rg") == 1 then
    vim.opt.grepprg = "rg --no-heading --vimgrep"
    vim.opt.grepformat = "%f:%l:%c:%m"
end

-- Use 4 spaces for tab
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Permanent undo file
-- This file only fills to the undo buffer limit, which is good
vim.opt.undofile = true

-- :help vim.opt
vim.cmd(":set relativenumber")

vim.o.tags = "./tags;,tags"
