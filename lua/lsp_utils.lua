local utils = require("utils")("lsp_utils.log")

local M = {}
M.setup = function(self)
    for name, config in pairs(self) do
        if type(config) == "table" and config.check and not config:check() then
            config:setup()
        end
    end
end

M.clangd = {
    version = "21.1.8",
    os_name = (utils.is_windows and "windows") or
              (utils.is_linux and "linux") or
              (utils.is_mac and "mac"),
    url = "https://github.com/clangd/clangd/releases/download/$(version)/clangd-$(os_name)-$(version).zip",
    unpack_path = "clangd/unpacked/clangd_$(version)/bin/$(binary_name)",
    binary_name = (utils.is_windows and "clangd.exe") or "clangd",
}

function M.clangd.bin_path(self)
    return utils:relpath(utils:interpolate(self.unpack_path, self))
end

function M.clangd.check(self)
    utils:file_exists(self:bin_path())
end

function M.clangd.setup(self)
    local url = utils:interpolate(self.url, self)
    if not utils:download(url, "clangd/clangd.zip") then
        vim.notify("Failed to download clangd/clangd.zip", vim.log.levels.ERROR)
        return false
    end
    if not utils:unzip("clangd/clangd.zip", "clangd/unpacked/") then
        vim.notify("Failed to unzip clangd/clangd.zip", vim.log.levels.ERROR)
        return false
    end
end

function M.clangd.cmd(self)
    return {
        self:bin_path(),
        "--clang-tidy",
        "--background-index",
        "--offset-encoding=utf-8",
    }
end

return M
