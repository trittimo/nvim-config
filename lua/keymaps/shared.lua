-- Remap window movement keys
vim.keymap.set({"n"}, "<C-l>", "<C-w><C-l>") vim.keymap.set({"n"}, "<C-h>",
"<C-w><C-h>") vim.keymap.set({"n"}, "<C-j>", "<C-w><C-j>")
vim.keymap.set({"n"}, "<C-k>", "<C-w><C-k>")
vim.keymap.set({"n"}, "<C-Right>", "<C-w>L")

-- Reload this config file
vim.keymap.set({"n"}, "<leader>r", "<cmd>:luafile $MYVIMRC<CR>")


-- Exit to normal mode
vim.keymap.set({"i"}, "kj", "<esc>")

-- Next/previous error
vim.keymap.set({"n"}, "<C-.>", "<cmd>:cnext<CR>")
vim.keymap.set({"n"}, "<C-,>", "<cmd>:cprev<CR>")

