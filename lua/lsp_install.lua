-- See `:help lspconfig-all` for installation instructions

local sysname = vim.loop.os_uname().sysname
local is_windows = sysname == "Windows_NT"
local is_linux = sysname == "Linux"
local is_mac = sysname == "Darwin"

local lsps = {
    run = function()
        for lsp_name, lsp_config in pairs(lsps) do
            if not lsp_config.check() then
                lsp_config.setup()
            end
        end
    end
}
lsps.clangd = {check=nil,setup=nil,cmd=nil}

local unzip = nil
local download = nil

local function log(path, msg)
    local log_path = vim.fn.stdpath("log") .. "/lsp_install.log"
    local f = io.open(log_path, "a")
    if f then
        f:write(string.format("[%s] [%s] %s\n", os.date("%H:%M:%S"), path or "BAD", msg or "nil"))
        f:close()
    end
end

log("start", "===============================")

local function system(...)
    local args = {...}
    log("system_enter", vim.inspect(args))
    local result = vim.system(args):wait()
    if result.code ~= 0 then
        vim.notify(string.format("Failed to execute command: %s", result.stderr), vim.log.levels.ERROR)
        log("system_exit", string.format("false, failed to execute command: %s", result.stderr))
        return false
    end
    log("system_exit", "true")
    return true
end

local function ensure_dir_exists(path)
    log("ensure_dir_exists_enter", path)
    local expanded = vim.fs.dirname(vim.fn.expand(path))
    log("ensure_dir_exists:expanded", expanded)

    local result = vim.fn.mkdir(expanded, "p")
    log("ensure_dir_exists:mkdir", result)
    log("ensure_dir_exists_exit")
end

local function relpath(...)
    log("relpath_enter", vim.inspect({...}))
    local result = vim.fs.joinpath(vim.fn.stdpath("state"), "lsps", unpack({...}))
    log("relpath_exit", result)
    return result
end

local function file_exists(path)
    return vim.uv.fs_stat(path)
end

local function download_rel(url, destination)
    if file_exists(destination) then return true end
    log("download_rel_enter", string.format("%s -> %s", url, destination))
    local destination = relpath(destination)
    ensure_dir_exists(destination)
    log("download_rel_exit")
    return download(url, destination)
end

local function unzip_rel(file, destination)
    if file_exists(destination) then return true end
    log("unzip_rel_enter", string.format("%s -> %s", file, destination))
    destination = relpath(destination)
    file = relpath(file)
    ensure_dir_exists(destination)
    local result = unzip(file, destination)
    log("unzip_rel_exit", result)
    return result
end


if is_windows then
    local function pwsh(command)
        log("pwsh_enter", command)
        local result = system("powershell", "-Command", command)
        log("pwsh_exit", result)
        return result
    end
    download = function(url, destination)
        log("download_enter", string.format("%s -> %s", url, destination))
        local result = pwsh(
            string.format(
                'Invoke-WebRequest -Uri "%s" -OutFile "%s"',
                url,
                destination
            )
        )
        log("download_exit", result)
        return result
    end
    unzip = function(file, destination)
        log("unzip_enter", string.format("%s -> %s", url, destination))
        local result = pwsh(
            string.format(
                'Expand-Archive -Path "%s" -DestinationPath "%s"',
                file,
                destination
            )
        )
        log("unzip_exit", result)
        return result
    end

    lsps.clangd.check = function()
        return false
    end

    lsps.clangd.setup = function()
        if not download_rel(
            "https://github.com/clangd/clangd/releases/download/21.1.8/clangd-windows-21.1.8.zip",
            "clangd/clangd.zip"
        ) then return false end
        if not unzip_rel("clangd/clangd.zip", "clangd/unpacked/") then return false end
    end

    lsps.clangd.cmd = function()
        return {
            relpath("clangd/unpacked/clangd_21.1.8/bin/clangd.exe"),
            "--clang-tidy",
            "--background-index",
            "--offset-encoding=utf-8",
        }
    end
end

return lsps
