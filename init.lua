local sysname = vim.loop.os_uname().sysname

require("misc")
require("layout")
require("commands")
require("status")

if sysname == "Darwin" then
    require("keymaps.mac")
elseif sysname == "Windows_NT" then
    require("keymaps.windows")
end

require("keymaps.shared")
require("config.lazy")
require("lazy").setup("plugins")

