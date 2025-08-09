local sysname = vim.loop.os_uname().sysname

require("misc")

require("config.lazy")
require("lazy").setup("plugins")
require("layout")
require("commands")
require("status")


if sysname == "Darwin" then
    require("keymaps.mac")
elseif sysname == "Windows_NT" then
    require("keymaps.windows")
end

require("keymaps.shared")

if vim.g.neovide then require("neovide") end
