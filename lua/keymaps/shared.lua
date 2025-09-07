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
vim.keymap.set({"n"}, "<C-S-h>", "<cmd>:vertical resize -2<CR>")
vim.keymap.set({"n"}, "<C-S-l>", "<cmd>:vertical resize +2<CR>")
vim.keymap.set({"n"}, "<C-S-j>", "<cmd>:resize +2<CR>")
vim.keymap.set({"n"}, "<C-S-k>", "<cmd>:resize -2<CR>")

-- LSP configs
vim.keymap.set({"n", "i"}, "<F2>", vim.lsp.buf.rename, { noremap = true, silent = true })

-- Split screen vertically and focus on the new screen
vim.keymap.set({"n"}, "<C-\\>", "<cmd>:vsplit<CR><C-w>l")

-- Split screen horizontally and focus on the new screen
vim.keymap.set({"n"}, "<C-|>", "<cmd>:split<CR><C-w>j")

-- Clear highlights
vim.keymap.set({"n"}, "\\", "<cmd>:noh<CR>")

-- Pageup/Pagedown
vim.keymap.set({"v", "i", "n"}, "<C-j>", "<C-d>")
vim.keymap.set({"v", "i", "n"}, "<C-k>", "<C-u>")
