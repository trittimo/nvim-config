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

-- Note: don't modify the result and expect the base tables to change
-- If there are key collisions, the first table passed will take priority
function M.join_tables(self, ...)
    local args = {...}
    local result = {}
    local indexer = function(table, key)
        for _, t in pairs(args) do
            if t[key] then return t[key] end
        end
    end
    setmetatable(result, {__index = indexer})
    return result
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

function M.system_stdout(self, ...)
    self:trace_enter()
    local args = { ... }
    local result = vim.system(args):wait()
    if result.code ~= 0 then
        self:trace_exit()
        return nil
    end
    self:trace_exit()
    return result.stdout
end

function M.relpath(self, ...)
    return vim.fs.joinpath(vim.fn.stdpath("data"), "lsps", unpack({ ... }))
end

function M.directory_exists(self, path)
    local result = vim.uv.fs_stat(path)
    return result ~= nil and result.type == "directory"
end

function M.file_exists(self, path)
    return vim.uv.fs_stat(path) ~= nil
end

function M.delete_file(self, path)
    vim.fs.rm(path, {recursive = true, force = true})
    return true
end

function M.ensure_dir_exists(self, path)
    local expanded = vim.fs.dirname(vim.fn.expand(path))
    vim.fn.mkdir(expanded, "p")
end

function M.read_entire_file(self, path)
    local stat = vim.uv.fs_stat(path)
    if stat == nil or stat.type ~= "file" then return end
    local f = io.open(path, "r")
    if not f then return nil end
    local result = f:read("*a")
    f:close()
    return result
end

function M.write_as_mpack(self, path, content)
    local f = io.open(path, "w")
    if not f then return nil end
    content = vim.mpack.encode(content)
    f:write(content)
    f:close()
end

function M.read_mpack_file(self, path)
    local content = self:read_entire_file(path)
    if not content then return nil end
    return vim.mpack.decode(content)
end

function M.write_as_json(self, path, content)
    local f = io.open(path, "w")
    if not f then return nil end
    content = vim.json.encode(content)
    f:write(content)
    f:close()
end

function M.read_json_file(self, path)
    local content = self:read_entire_file(path)
    if not content then return nil end
    return vim.json.decode(content, {object=true,array=true})
end

function M.download(self, url, destination)
    assert(self._download, "Missing _download implementation")
    self:trace_enter()
    destination = self:relpath(destination)
    self:delete_file(destination)
    self:ensure_dir_exists(destination)
    self:trace_exit()
    return self:_download(url, destination)
end

function M.unzip(self, file, destination)
    assert(self._unzip, "Missing _unzip implementation")
    self:trace_enter()
    local src = self:relpath(file)
    local destination = self:relpath(destination)
    self:delete_file(destination)
    self:ensure_dir_exists(destination)
    local result = self:_unzip(src, destination)
    self:trace_exit()
    return result
end

function M.http_get(self, url)
    return self:_http_get(url)
end

function M.http_get_json(self, url)
    local response = self:http_get(url)
    if not response then return nil end
    return vim.json.decode(
        response,
        { object = true, array = true }
    )
end

-- OS Specific implementations
if M.is_windows then
    function M.pwsh(self, command)
        return self:system("powershell", "-Command", command)
    end
    function M.pwsh_stdout(self, command)
        return self:system_stdout("powershell", "-Command", command)
    end

    function M._download(self, url, destination)
        return self:pwsh(string.format('Invoke-WebRequest -Uri "%s" -OutFile "%s"', url, destination))
    end

    function M._unzip(self, file, destination)
        assert(file, "Missing an input file")
        assert(destination, "Missing an output destination")
        return self:pwsh(string.format(
            'Expand-Archive -Path "%s" -DestinationPath "%s" -Force', file, destination
        ))
    end

    function M._http_get(self, url)
        return self:pwsh_stdout(string.format(
            '(Invoke-WebRequest -Uri "%s" -UseBasicParsing).Content',
            url
        ))
    end
end

if M.is_linux or M.is_mac then
    function M._download(self, url, destination)
        return self:system("curl", "-sL", url, "-o", destination)
    end

    function M._unzip(self, src, destination)
        self:trace_enter()
        local result = self:system("unzip", src, "-d", destination)
        self:trace_exit()
        return result
    end

    function M._http_get(self, url)
        return self:system_stdout("curl", "-sL", url)
    end
end

return function(log_path)
    local result = {log_path = log_path}
    setmetatable(result, {__index = M})
    return result
end
