if vim.g.neovide then
    vim.keymap.set('v', '<C-S-c>', '"+y') -- Copy
    vim.keymap.set('n', '<C-S-v>', '"+P') -- Paste normal mode
    vim.keymap.set('v', '<C-S-v>', '"+P') -- Paste visual mode
    vim.keymap.set('c', '<C-S-v>', '<C-R>+') -- Paste command mode
    vim.keymap.set('i', '<C-S-v>', '<ESC>l"+Pli') -- Paste insert mode
    vim.keymap.set("t", '<C-S-v>', '<C-\\><C-n>l"+Pli') -- Paste insert mode
end

-- Allow clipboard copy paste in neovim
-- vim.api.nvim_set_keymap('', '<C-s-v>', '+p<CR>', { noremap = true, silent = true})
-- vim.api.nvim_set_keymap('!', '<C-s-v>', '<C-R>+', { noremap = true, silent = true})
-- vim.api.nvim_set_keymap('t', '<C-s-v>', '<C-R>+', { noremap = true, silent = true})
-- vim.api.nvim_set_keymap('v', '<C-s-v>', '<C-R>+', { noremap = true, silent = true})

