local M = {
    log_path = "utils.log",
    trace_enabled = false
}

M.sysname = vim.loop.os_uname().sysname
M.is_windows = M.sysname == "Windows_NT"
M.is_linux = M.sysname == "Linux"
M.is_mac = M.sysname == "Darwin"

function M.log(self, msg, vars)
    local log_path = vim.fn.stdpath("log") .. "/" .. self.log_path
    msg = self:interpolate(msg or "", vars or self)
    local f = io.open(log_path, "a")
    if f then
        f:write(string.format("[%s] %s\n", os.date("%H:%M:%S"), msg))
        f:close()
    end
end

function M.trace_enter(self)
    if not self.trace_enabled then return end
    -- Level 2 is the function that called :enter()
    local info = debug.getinfo(2, "nSl")
    local fn_name = info.name or "unknown_func"
    local line = info.currentline
    local source = info.short_src:match("[^/]*.lua$") or info.short_src

    local args = {}
    local i = 1
    while true do
        local name, value = debug.getlocal(2, i)
        if not name then break end

        -- Filter out 'self' and internal lua variables
        if name ~= "self" and not name:match("^%(") then
            -- Clean up the inspected value for single-line logging
            local val_str = vim.inspect(value):gsub("\n", " "):gsub("%s+", " ")
            table.insert(args, string.format("%s=%s", name, val_str))
        end
        i = i + 1
    end

    local arg_str = table.concat(args, ", ")

    self:log("-> ENTER: $(src):$(line) | $(fn)($(args))", {
        src = source,
        line = line,
        fn = fn_name,
        args = arg_str
    })
end

function M.trace_exit(self)
    if not self.trace_enabled then return end
    local info = debug.getinfo(2, "nSl")
    local fn_name = info.name or "unknown_func"
    local line = info.currentline
    local source = info.short_src:match("[^/]*.lua$") or info.short_src

    self:log("<- EXIT:  $(src):$(line) | $(fn)", {
        src = source,
        line = line,
        fn = fn_name
    })
end

-- Usage:  M:interpolate("Hello $(name)", {name = 'Mike'})
function M.interpolate(self, str, vars)
    return (str:gsub("%$%(([%w_]+)%)", function(key)
        return tostring(vars[key] or "$(" .. key .. ")")
    end))
end

function M.system(self, ...)
    self:trace_enter()
    local args = { ... }
    self:log("system($(args))", {args = vim.inspect(args)})
    local result = vim.system(args):wait()
    if result.code ~= 0 then
        vim.notify(string.format("Failed to execute command: %s", result.stderr), vim.log.levels.ERROR)
        self:trace_exit()
        return false
    end
    self:trace_exit()
    return true
end

function M.relpath(self, ...)
    return vim.fs.joinpath(vim.fn.stdpath("data"), "lsps", unpack({ ... }))
end

function M.file_exists(self, path)
    return vim.uv.fs_stat(path) ~= nil
end

function M.ensure_dir_exists(self, path)
    local expanded = vim.fs.dirname(vim.fn.expand(path))
    vim.fn.mkdir(expanded, "p")
end

function M.download(self, url, destination)
    assert(self._download, "Missing _download implementation")
    self:trace_enter()
    destination = self:relpath(destination)
    if self:file_exists(destination) then return true end
    self:ensure_dir_exists(destination)
    self:trace_exit()
    return self:_download(url, destination)
end

function M.unzip(self, file, destination)
    assert(self._unzip, "Missing _unzip implementation")
    self:trace_enter()
    local src = self:relpath(file)
    local destination = self:relpath(destination)
    if self:file_exists(destination) then
        self:trace_exit()
        return true
    end
    self:ensure_dir_exists(destination)
    self:_unzip(src, destination)
    self:trace_exit()
end

-- OS Specific implementations
if M.is_windows then
    function M.pwsh(self, command)
        return self:system("powershell", "-Command", command)
    end

    function M._download(self, url, destination)
        return self:pwsh(string.format('Invoke-WebRequest -Uri "%s" -OutFile "%s"', url, destination))
    end

    function M._unzip(self, file, destination)
        return self:pwsh(string.format('Expand-Archive -Path "%s" -DestinationPath "%s"', src, destination))
    end
end

if M.is_linux or M.is_mac then
    function M:_download(url, destination)
        return self:system("curl", "-L", url, "-o", destination)
    end

    function M:_unzip(src, destination)
        self:trace_enter()
        local result = self:system("unzip", src, "-d", destination)
        self:trace_exit()
        return result
    end
end

return function(log_path)
    local result = {log_path = log_path}
    setmetatable(result, {__index = M})
    return result
end
