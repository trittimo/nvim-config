local sysname = vim.loop.os_uname().sysname
require("misc")

if not vim.g.vscode then
    require("whitespace")
    require("config.lazy")
    require("lazy").setup("plugins")
    require("layout")
    require("status")
    require("keymaps.shared")
end

require("commands")

if sysname == "Darwin" then
    require("keymaps.mac")
elseif sysname == "Windows_NT" then
    require("layout.windows")
    require("keymaps.windows")
elseif sysname == "Linux" then
    require("layout.linux")
    require("keymaps.linux")
end

if vim.g.neovide then require("neovide") end
if vim.g.vscode then require("vscodium") end
