if vim.g.neovide then
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
