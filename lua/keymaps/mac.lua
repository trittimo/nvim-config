if vim.g.neovide then
    vim.keymap.set('v', '<D-c>', '"+y') -- Copy
    vim.keymap.set('n', '<D-v>', '"+gpv`[=`]') -- Paste normal mode
    vim.keymap.set('c', '<D-v>', '<C-R>"+p') -- Paste command mode
    vim.keymap.set('i', '<D-v>', '<Esc>"+gpa') -- Paste insert mode
    vim.keymap.set("t", '<D-v>', '<C-\\><C-n>l"+gpa') -- Paste terminal mode

    -- Increase font size
    vim.keymap.set('n', '<D-=>', function()
        local current_font = vim.o.guifont
        local _, _, size = current_font:find(':h(%d+)')
        size = tonumber(size) or 20
        vim.o.guifont = current_font:gsub(':h%d+', '') .. ':h' .. (size + 1)
    end, { silent = true })

    -- Decrease font size
    vim.keymap.set('n', '<D-->', function()
        local current_font = vim.o.guifont
        local _, _, size = current_font:find(':h(%d+)')
        size = tonumber(size) or 20
        if size > 6 then  -- Prevent font from getting too small
            vim.o.guifont = current_font:gsub(':h%d+', '') .. ':h' .. (size - 1)
        end
    end, { silent = true })

    -- Reset font size
    vim.keymap.set('n', '<D-0>', function()
        vim.o.guifont = 'Menlo:h20'
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
