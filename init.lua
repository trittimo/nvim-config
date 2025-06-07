local sysname = vim.loop.os_uname().sysname

require("misc")
require("layout")

if uname == "Darwin" then
	require("keymaps.mac")
elseif uname == "Windows_NT" then
	require("keymaps.windows")
end

require("keymaps.shared")
