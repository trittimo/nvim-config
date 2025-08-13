if vim.g.neovide then
    vim.keymap.set('v', '<C-S-c>', '"+y') -- Copy
    vim.keymap.set('n', '<C-S-v>', '"+gpv`[=`]') -- Paste normal mode
    vim.keymap.set('c', '<C-S-v>', '<C-R>"+p') -- Paste command mode
    vim.keymap.set('i', '<C-S-v>', '<Esc>"+gpa') -- Paste insert mode
    vim.keymap.set("t", '<C-S-v>', '<C-\\><C-n>l"+gpa') -- Paste terminal mode

    -- Increase font size
    vim.keymap.set('n', '<C-=>', function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
    end, { silent = true })

    -- Decrease font size
    vim.keymap.set('n', '<C-->', function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1 / 1.1
    end, { silent = true })

    -- Reset font size
    vim.keymap.set('n', '<C-0>', function()
        vim.g.neovide_scale_factor = 1
    end, { silent = true })
end

vim.keymap.set({"i", "n"}, "<C-/>", "gcc", { remap = true, silent = true})
vim.keymap.set("v", "<C-/>", "gc", { remap = true, silent = true})
