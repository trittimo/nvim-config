if vim.g.neovide then
    vim.keymap.set('v', '<D-c>', '"+y') -- Copy
    vim.keymap.set('n', '<D-v>', '"+gpv`[=`]') -- Paste normal mode
    vim.keymap.set('c', '<D-v>', '<C-R>"+p') -- Paste command mode
    vim.keymap.set('i', '<D-v>', '<Esc>"+gpa') -- Paste insert mode
    vim.keymap.set("t", '<D-v>', '<C-\\><C-n>l"+gpa') -- Paste terminal mode

    -- Increase font size
    vim.keymap.set('n', '<D-=>', function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
    end, { silent = true })

    -- Decrease font size
    vim.keymap.set('n', '<D-->', function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1 / 1.1
    end, { silent = true })

    -- Reset font size
    vim.keymap.set('n', '<D-0>', function()
        vim.g.neovide_scale_factor = 1
    end, { silent = true })
end

vim.keymap.set({"i", "n"}, "<D-/>", "gcc", { remap = true, silent = true})
vim.keymap.set("v", "<D-/>", "gc", { remap = true, silent = true})
vim.keymap.set("i", "<D-Left>", "<Esc>bi")
vim.keymap.set("i", "<D-Right>", "<Esc>wi")
vim.keymap.set("n", "<D-Left>", "b")
vim.keymap.set("n", "<D-Right>", "w")
vim.keymap.set("n", "<D-a>", "gg^<S-V><S-G>")
vim.keymap.set("i", "<D-a>", "<Esc>gg^<S-V><S-G>")
