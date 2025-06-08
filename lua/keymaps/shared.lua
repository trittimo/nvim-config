-- Remap window movement keys
vim.keymap.set({"n"}, "<C-l>", "<C-w><C-l>")
vim.keymap.set({"n"}, "<C-h>", "<C-w><C-h>")
vim.keymap.set({"n"}, "<C-j>", "<C-w><C-j>")
vim.keymap.set({"n"}, "<C-k>", "<C-w><C-k>")
vim.keymap.set({"n"}, "<C-Right>", "<C-w>L")

-- Reload this config file
vim.keymap.set({"n"}, "<leader>r", "<cmd>:luafile $MYVIMRC<CR>")

-- Exit to normal mode
vim.keymap.set({"i"}, "kj", "<esc>")

-- Show diagnostic under cursor
vim.keymap.set({"n"}, "<C-.>", "<cmd>:lua vim.diagnostic.open_float()<CR>")

-- Resize current window
vim.keymap.set({"n"}, "<C-S-h>", ":vertical resize -2<CR>")
vim.keymap.set({"n"}, "<C-S-l>", ":vertical resize +2<CR>")
vim.keymap.set({"n"}, "<C-S-j>", ":resize +2<CR>")
vim.keymap.set({"n"}, "<C-S-k>", ":resize -2<CR>")

-- LSP configs
vim.keymap.set({"n", "i"}, "<F2>", vim.lsp.buf.rename, { noremap = true, silent = true })
