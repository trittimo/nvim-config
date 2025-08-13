local sysname = vim.loop.os_uname().sysname
require("misc")

if not vim.g.vscode then
    require("config.lazy")
    require("lazy").setup("plugins")
    require("layout")
    require("commands")
    require("status")
    require("keymaps.shared")
end

if sysname == "Darwin" then
    require("keymaps.mac")
elseif sysname == "Windows_NT" then
    require("keymaps.windows")
end

if vim.g.neovide then require("neovide") end
if vim.g.vscode then require("vscodium") end
