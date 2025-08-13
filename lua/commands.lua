-- Format the current buffer
vim.api.nvim_create_user_command("Format", function()
    vim.lsp.buf.format { async = true }
end, {})

-- Preview Markdown
vim.api.nvim_create_user_command("Markdown", function()
    local file

    -- Check if current buffer is netrw
    if vim.bo.filetype == "netrw" then
        -- Get filename under cursor in netrw
        -- netrw shows file names in the buffer, so grab the line text
        local line = vim.api.nvim_get_current_line()
        -- Construct full path: netrw’s directory + filename under cursor
        local dir = vim.fn.expand("%:p:h") -- netrw directory path
        file = vim.fn.fnamemodify(dir .. "/" .. line, ":p") -- full path

    else
        -- Normal buffer: current file path
        file = vim.fn.expand("%:p")
    end

    -- Safety check: make sure file exists
    if vim.fn.empty(file) == 1 or vim.fn.filereadable(file) == 0 then
        vim.notify("No valid file to preview!", vim.log.levels.ERROR)
        return
    end

    vim.cmd("vsplit") -- vertical split
    vim.cmd("wincmd l") -- move to right split
    vim.cmd("terminal glow " .. vim.fn.fnameescape(file)) -- open terminal running glow
end, {})

vim.api.nvim_create_user_command("Rotate", function()
    local wins = vim.api.nvim_tabpage_list_wins(0)
    if #wins ~= 2 then
        print("Rotate: Only works with exactly two splits.")
        return
    end

    -- Get current window layout direction
    local win1 = wins[1]
    local win2 = wins[2]

    local pos1 = vim.api.nvim_win_get_position(win1)
    local pos2 = vim.api.nvim_win_get_position(win2)

    local is_horizontal = pos1[1] ~= pos2[1]

    -- Save buffers
    local buf1 = vim.api.nvim_win_get_buf(win1)
    local buf2 = vim.api.nvim_win_get_buf(win2)

    -- Close all but one
    vim.cmd("only")

    -- Re-split in the opposite direction
    if is_horizontal then
        vim.cmd("vsplit")
    else
        vim.cmd("split")
    end

    -- Set buffers
    vim.api.nvim_win_set_buf(0, buf1)
    vim.api.nvim_set_current_win(vim.api.nvim_tabpage_list_wins(0)[2])
    vim.api.nvim_win_set_buf(0, buf2)
end, {})
