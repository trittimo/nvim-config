vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#ff0000" })

local function update_whitespace_highlight()
    vim.cmd([[match ExtraWhitespace /\s\+$/]])
end

local function remove_whitespace_highlight()
    vim.cmd([[call clearmatches()]])
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave" }, {
  pattern = "*",
  callback = update_whitespace_highlight,
})

vim.api.nvim_create_autocmd({ "InsertEnter", "BufWinLeave" }, {
    pattern = "*",
    callback = remove_whitespace_highlight,
})
