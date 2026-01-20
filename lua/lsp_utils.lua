local utils = require("utils")("lsp_utils.log")

local M = {}
M.setup = function(self)
    print("Just call =require('lsp_utils'):thelsp:setup()")
    return true
end
M.bin_path = function(self, lsp)
    return utils:relpath(utils:interpolate(lsp.unpack_path, lsp))
end
M.check = function(self, lsp_name)
    if not self[lsp_name] then return false end
    return utils:file_exists(self:bin_path(self[lsp_name]))
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
        M:bin_path(self),
        "--clang-tidy",
        "--background-index",
        "--offset-encoding=utf-8",
    }
end

-- Instructions obtained by following :help lspconfig-all roslyn_ls
M.roslyn = {
    index_url = "https://api.nuget.org/v3-flatcontainer/microsoft.codeanalysis.languageserver.$(platform)/index.json",
    nupkg_url = "https://api.nuget.org/v3-flatcontainer/microsoft.codeanalysis.languageserver.$(platform)/$(version)/microsoft.codeanalysis.languageserver.$(platform).$(version).nupkg",
    -- Not actually used, just a good reference if we need to go take a look at it in the UI
    url = "https://dev.azure.com/azure-public/vside/_artifacts/feed/vs-impl/NuGet/Microsoft.CodeAnalysis.LanguageServer.$(platform)/overview",
    platform = (utils.is_windows and "win-x64") or
               (utils.is_linux and "linux-x64") or
               (utils.is_mac and "osx-x64"),
    unpack_path = "roslyn/unpacked/content/LanguageServer/$(platform)/$(binary_name)",
    binary_name = "Microsoft.CodeAnalysis.LanguageServer.dll",
}

function M.roslyn.cmd(self)
    return {
        "dotnet",
        M:bin_path(self),
        '--logLevel',
        'Information',
        '--extensionLogDirectory',
        vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
        '--stdio'
    }
end

function M.roslyn.setup(self)
    local index_url = utils:interpolate(self.index_url, self)
    local index_dict = utils:http_get_json(index_url)
    if not index_dict then
        vim.notify("Failed to download index.json from " .. index_url)
        return false
    end
    local version = index_dict.versions[1]
    local composite = utils:join_tables({version = version}, self)
    local nupkg_url = utils:interpolate(self.nupkg_url, composite)
    if not utils:download(nupkg_url, "roslyn/roslyn.zip") then
        vim.notify("Failed to download nupkg", vim.log.levels.ERROR)
        return false
    end
    if not utils:unzip("roslyn/roslyn.zip", "roslyn/unpacked/") then
        vim.notify("Failed to unzip nupkg", vim.log.levels.ERROR)
        return false
    end
end

M.lua = {
    unpack_path = "lua/unpacked/bin/$(binary_name)",
    binary_name = (utils.is_windows and "lua-language-server.exe" or "lua-language-server")
}

function M.lua.cmd(self)
    return {
        M:bin_path(self)
    }
end

function M.lua.setup(self)
    print("Not implemented!")
    return false
end

return M
