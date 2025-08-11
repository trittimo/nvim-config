if vim.g.neovide then
    vim.keymap.set('v', '<D-c>', '"+y') -- Copy
    vim.keymap.set('n', '<D-v>', '"+gp') -- Paste normal mode
    vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
    vim.keymap.set('i', '<D-v>', '<Esc>"+gpa') -- Paste insert mode
    vim.keymap.set("t", '<D-v>', '<C-\\><C-n>l"+gpa') -- Paste terminal mode
end

vim.keymap.set("i", "<D-Left>", "<Esc>bi")
vim.keymap.set("i", "<D-Right>", "<Esc>wi")
vim.keymap.set("n", "<D-Left>", "b")
vim.keymap.set("n", "<D-Right>", "w")
vim.keymap.set("n", "<D-a>", "gg^<S-V><S-G>")
vim.keymap.set("i", "<D-a>", "<Esc>gg^<S-V><S-G>")
