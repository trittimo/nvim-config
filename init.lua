-- ============= CONSTANTS =============
local sysname = vim.loop.os_uname().sysname
local is_windows = sysname == "Windows_NT"
local is_linux = sysname == "Linux"
local is_mac = sysname == "Darwin"
local is_neovide = vim.g.neovide
local is_vscode = vim.g.vscode
local is_embedded = is_vscode
local is_native = not is_embedded
local saved_sessions_path = vim.fn.stdpath("state") .. "/sessions.mpack"
local max_saved_sessions = 10
local max_whitespace_highlight_filesize = 1024 * 1024 -- 1MB
local utils = require("utils")("init.log")
local match_ids = {} -- window-local match IDs

-- ============= HELPER FUNCTIONS =============
local function toggle_buffer(settings)
    if settings.win and -- We have saved a window
        vim.api.nvim_win_is_valid(settings.win) -- It's still valid
    then
        local current_buf = vim.api.nvim_get_current_buf()
        local current_win = vim.api.nvim_get_current_win()
        if current_buf == settings.buf and current_win == settings.win then
            if settings.close then return settings.close() end
            vim.api.nvim_win_close(settings.win, true)
        else -- Not active
            vim.api.nvim_set_current_win(settings.win) -- Activate it
        end
        return
    end

    vim.api.nvim_create_autocmd("BufEnter", {
        once = true,
        callback = function()
            settings.win = vim.api.nvim_get_current_win()
            settings.buf = vim.api.nvim_get_current_buf()
        end
    })

    if settings.buf and vim.api.nvim_buf_is_valid(settings.buf) and settings.restore then
        -- We found a buffer to restore and we have a restore fn, call it
        settings.restore(settings.buf)
    else
        -- No way to restore, just start
        settings.start()
    end
end

local function should_skip(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    -- Skip all buffers with a set type, such as terminals
    -- Interestingly, just regular files don't have a buftype
    -- Neither does netrw, but that's because netrw is clunky
    if vim.bo[bufnr].buftype ~= "" then
        return true
    end

    -- Skip large files
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return true
    end

    local stat = vim.uv.fs_stat(name)
    if stat and stat.size > max_whitespace_highlight_filesize then
        return true
    end

    return false
end

local function update_whitespace_highlight()
    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()

    if should_skip(bufnr) then
        return
    end

    -- Avoid duplicate matches
    if match_ids[winid] then
        return
    end

    match_ids[winid] = vim.fn.matchadd("ExtraWhitespace", [[\s\+$]])
end

local function remove_whitespace_highlight()
    local winid = vim.api.nvim_get_current_win()

    if match_ids[winid] then
        vim.fn.matchdelete(match_ids[winid])
        match_ids[winid] = nil
    end
end

local function reload_package(packname)
    for k in pairs(package.loaded) do
        if k:match("^" .. packname) then
            package.loaded[k] = nil
        end
    end
    return require(packname)
end

local function get_session_path()
    return vim.fn.getcwd() .. "/Session.vim"
end

local function mksession(session_file)
    local session_path = vim.fs.normalize(get_session_path())
    if session_file and not session_file:match("^%s+$") then
        session_path = vim.fs.normalize(vim.fn.expand(session_file))
    end

    local session_state = utils:read_mpack_file(saved_sessions_path)
    if not session_state or not session_state.current then
        session_state = {current = 1}
    end

    for key, path in pairs(session_state) do
        if path == session_path then
            utils:log(tostring(path) .. " == " .. session_path)
            session_state[key] = nil
        else
            utils:log(tostring(path) .. " ~= " .. session_path)
        end
    end
    if session_state[session_state.current] then
        session_state.current = session_state.current + 1
        if session_state.current > max_saved_sessions then
            session_state.current = 1
        end
    end

    session_state[session_state.current] = session_path

    local bufs = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(bufs) do
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = bufnr })
        local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
        local bufname = vim.api.nvim_buf_get_name(bufnr)

        -- If it's a terminal, help, or nofile buffer, skip it
        if buftype == "terminal" or
            buftype == "help" or
            buftype == "nofile" or
            bufname == "" or
            filetype == "netrw" then
            vim.api.nvim_set_option_value("buflisted", false, { buf = bufnr })
        end
    end
    vim.cmd("mksession! " .. session_path)
    utils:write_as_mpack(saved_sessions_path, session_state)
    return true
end

local function ldsession(session_file, go_previous)
    local session_path = session_file and vim.fs.normalize(vim.fn.expand(session_file))
    if session_path and not utils:file_exists(session_path) then
        session_path = nil
        session_file = nil
    end
    local session_state = utils:read_mpack_file(saved_sessions_path)
    if not session_state then
        session_state = {current = 2}
    end
    if go_previous then
        for i = 1, max_saved_sessions do
            session_state.current = session_state.current - 1
            if session_state.current < 1 then
                session_state.current = max_saved_sessions
            end
            if session_state[session_state.current] then
                session_path = session_state[session_state.current]
                break
            end
        end
    elseif not session_path then
        session_path = session_state[session_state.current]
    end
    if not session_path or not utils:file_exists(session_path) then
        vim.notify("Could not find a valid session path to load!", vim.log.levels.ERROR)
        return false
    end
    utils:log("Found session path to load: " .. session_path)

    -- Now source the session
    vim.cmd("source " .. session_path)
    local tree = require("nvim-tree.api").tree
    local cwd = vim.fn.getcwd()
    tree.open({path = cwd})
    tree.change_root(cwd)
    utils:write_as_mpack(saved_sessions_path, session_state)
    return true
end

utils:log("=============================")
-- ============= MISC =============
-- nvim-tree advises we do this ASAP in our init
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Spacebar is our leader key
vim.g.mapleader = " "

-- Use global clipboard as default
vim.opt.clipboard = "unnamedplus"

-- Go to the correct indent level automatically
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.timeoutlen = 300
-- Defaults are "blank,buffers,curdir,folds,help,tabpages,winsize,terminal"
vim.opt.sessionoptions = "buffers,curdir,folds,tabpages,winsize"
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.opt.termguicolors = true

if is_native then
    -- Make sure we aren't folding anything by default when opening a file
    vim.opt.foldlevel = 99
    vim.opt.foldlevelstart = 99

    vim.cmd("cnoreabbrev grep Grep") -- see ya grep
    -- Use ripgrep for searching
    if vim.fn.executable("rg") == 1 then
        vim.opt.grepprg = "rg --vimgrep --context 2 --smart-case"
        vim.opt.grepformat = "%f:%l:%c:%m"
    end

    vim.cmd("helptags ALL")

    -- Use 4 spaces for tab
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true
    vim.opt.relativenumber = true

    -- Permanent undo file
    -- This file only fills to the undo buffer limit, which is good
    vim.opt.undofile = true

    vim.o.tags = "./tags;,tags"

    -- When opening copen, increase size of editor by default and move it to the right
    vim.api.nvim_create_autocmd("FileType", {
        -- You can find the pattern of a buffer with :set filetype?
        pattern = "qf",
        callback = function()
            -- Move quickfix to the right
            vim.cmd("wincmd L")
            -- Allow quitting out of a copen buffer with q
            vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd<CR>", { noremap = true, silent = true, nowait = true})
        end
    })
end

-- ============= PLUGINS =============
if is_native then
    local lazypath = vim.fn.stdpath("config") .. "/plugin_loader"

    vim.opt.rtp:prepend(lazypath)
    local plugin_spec = require("plugins")

    require("lazy").setup({
        spec = plugin_spec,
        change_detection = {
            enabled = false
        },
        install = {
            missing = false
        },
        readme = {
            root = vim.fn.stdpath("config") .. "/lazy/readme"
        },
        rocks = {
            enabled = false
        },
        state = vim.fn.stdpath("state") .. "/lazy/state.json",
        ---@diagnostic disable-next-line: assign-type-mismatch
        dev = {
            path = vim.fn.stdpath("config") .. "/plugins",
            fallback = false
        }
    })

    vim.api.nvim_create_user_command(
        "PluginAdd",
        function(opts)
            local plugin_path = opts.fargs[1]
            local branch_name = opts.fargs[2]
            local github_path = "https://github.com/" .. plugin_path
            local config_dir = vim.fn.stdpath("config")
            if not branch_name then
                local remotes = vim.system({
                    "git",
                    "-C",
                    config_dir,
                    "ls-remote",
                    "--symref",
                    github_path .. ".git",
                    "HEAD"
                }):wait()
                if remotes.code ~= 0 then
                    print("Unable to query " .. github_path .. " for branch information")
                    return
                end
                local main_branch = remotes.stdout:match("refs/heads/([^%s]+)")
                if not main_branch then
                    print("Odd output from git ls-remote. Cannot parse main branch")
                    print(remotes.stdout)
                    return
                end
                branch_name = main_branch
            end

            local result = vim.system({
                "git",
                "-C",
                config_dir,
                "subtree",
                "add",
                "--prefix=" .. "plugins/" .. plugin_path,
                github_path,
                branch_name,
                "--squash"
            }):wait()
            if result.code ~= 0 then
                print("Unable to add subtree for plugin " .. plugin_path .. ": " .. result.stderr)
            else
                print("Successfully add " .. plugin_path)
                print(result.stderr .. "\n" .. result.stdout)
            end
        end,
        {
            nargs = "+",
            desc = "Download a specific plugin for the first time"
        }
    )
    vim.api.nvim_create_user_command(
        "PluginRemove",
        function(opts)
            local plugin_path = opts.fargs[1]
            local config_dir = vim.fn.stdpath("config")
            local result = vim.system({
                "git",
                "-C",
                config_dir,
                "rm",
                "-r",
                "plugins/" .. plugin_path,
            }):wait()
            if result.code ~= 0 then
                print("Unable to git rm " .. plugin_path .. ": " .. result.stderr)
                return
            end

            result = vim.system({
                "git",
                "-C",
                config_dir,
                "add",
                "-A"
            }):wait()
            if result.code ~= 0 then
                print("Unable to git add: " .. result.stderr)
                return
            end

            result = vim.system({
                "git",
                "-C",
                config_dir,
                "commit",
                "-m",
                "'Remove " .. plugin_path .. "'"
            }):wait()
            if result.code ~= 0 then
                print("Unable to remove plugin: " .. result.stderr)
                return
            end

            print("Successfully removed " .. plugin_path)
            print(result.stderr .. "\n" .. result.stdout)
        end,
        {
            nargs = 1,
            desc = "Remove the specified plugin",
            complete = function(arg_lead, cmd_line, cursor_pos)
                local result = {}
                for _, plugin in pairs(plugin_spec) do
                    result[#result+1] = plugin[1]
                end
                return result
            end
        }
    )

    vim.api.nvim_create_user_command(
        "PluginUpdate",
        function(opts)
            local plugin_path = opts.fargs[1]
            local branch_name = opts.fargs[2]
            local github_path = "https://github.com/" .. plugin_path
            local config_dir = vim.fn.stdpath("config")
            if not branch_name then
                local remotes = vim.system({
                    "git",
                    "-C",
                    config_dir,
                    "ls-remote",
                    "--symref",
                    github_path .. ".git",
                    "HEAD"
                }):wait()
                if remotes.code ~= 0 then
                    print("Unable to query " .. github_path .. " for branch information")
                    return
                end
                local main_branch = remotes.stdout:match("refs/heads/([^%s]+)")
                if not main_branch then
                    print("Odd output from git ls-remote. Cannot parse main branch")
                    print(remotes.stdout)
                    return
                end
                branch_name = main_branch
            end

            local result = vim.system({
                "git",
                "-C",
                config_dir,
                "subtree",
                "pull",
                "--prefix=" .. "plugins/" .. plugin_path,
                github_path,
                branch_name,
                "--squash"
            }):wait()
            if result.code ~= 0 then
                print("Unable to pull subtree for plugin " .. plugin_path .. ": " .. result.stderr)
            else
                print("Successfully updated " .. plugin_path)
                print(result.stderr .. "\n" .. result.stdout)
            end
        end,
        {
            nargs = "+",
            desc = "Update a specific plugin",
            complete = function(arg_lead, cmd_line, cursor_pos)
                local result = {}
                for _, plugin in pairs(plugin_spec) do
                    result[#result+1] = plugin[1]
                end
                return result
            end
        }
    )
end

-- ============= AUTO COMMANDS =============
if is_native then
    vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#ff0000" })

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave" }, {
        callback = update_whitespace_highlight,
    })

    vim.api.nvim_create_autocmd({ "InsertEnter", "BufWinLeave" }, {
        callback = remove_whitespace_highlight,
    })
end

-- ============= LAYOUT =============
if is_native and not is_neovide then
    vim.cmd([[colorscheme habamax]])
end

-- Status
vim.o.laststatus = 2
vim.o.statusline = "%f %y %m %=Ln:%l Col:%c [%p%%]"


-- ============= OS Specific Configurations=============
if is_windows then
    vim.opt.shell = "pwsh"
    vim.o.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    vim.o.shellredir = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    vim.o.shellquote = ""
    vim.o.shellxquote = ""
end

-- ============= KEYBINDS (All Systems) =============
-- Exit to normal mode
vim.keymap.set({"i"}, "kj", "<esc>")

-- Resize current window
vim.keymap.set({"n"}, "<C-S-h>", "<cmd>:vertical resize -2<CR>")
vim.keymap.set({"n"}, "<C-S-l>", "<cmd>:vertical resize +2<CR>")
vim.keymap.set({"n"}, "<C-S-j>", "<cmd>:resize +2<CR>")
vim.keymap.set({"n"}, "<C-S-k>", "<cmd>:resize -2<CR>")

-- Split screen vertically and focus on the new screen
vim.keymap.set({"n"}, "<C-\\>", "<cmd>:vsplit<CR><C-w>l")

-- Split screen horizontally and focus on the new screen
vim.keymap.set({"n"}, "<C-|>", "<cmd>:split<CR><C-w>j")

-- Clear highlights
vim.keymap.set({"n"}, "\\", "<cmd>:noh<CR>")

-- Pageup/Pagedown
vim.keymap.set({"v", "i", "n"}, "<C-j>", "10j")
vim.keymap.set({"v", "i", "n"}, "<C-k>", "10k")

-- Terminal buffer keybinds
-- Change <Esc> to <C-\><C-n>
-- Change <C-\><C-\> to terminal <Esc>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
vim.keymap.set("t", "<C-\\><C-\\>", "<Esc>") -- Note that noremap is the default, so this won't trigger the above
vim.keymap.set("t", "kj", "<C-\\><C-n>")

if is_native then
    -- LSP configs
    vim.keymap.set({"n", "i"}, "<F2>", vim.lsp.buf.rename, { noremap = true, silent = true })

    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set("n", "<C-.>", vim.diagnostic.open_float)

    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end)
    vim.keymap.set("n", "<C-l>", "<cmd>:tabnext<CR>")
    vim.keymap.set("n", "<C-h>", "<cmd>:tabprev<CR>")

    local term_toggle_settings = {
        restore = function(buf)
            vim.cmd("botright sbuffer " .. buf)
            vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.3))
            vim.cmd("startinsert")
        end,
        start = function()
            vim.cmd("botright split | term")
            vim.api.nvim_win_set_height(0, math.floor(vim.o.lines * 0.3))
            vim.cmd("startinsert")
        end
    }

    local vim_tree_settings = {
        -- No need for a restore. The start function will restore it
        start = function()
            vim.cmd("NvimTreeFindFileToggle")
        end,
        close = function()
            vim.cmd("NvimTreeFindFileToggle")
        end,
    }

    vim.keymap.set({"n", "i", "v", "t"}, "<C-`>", function() toggle_buffer(term_toggle_settings) end, { desc = "Toggle terminal split" })

    -- Autocommands for man pages
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "man",
        callback = function()
            -- Use q to quit
            vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd<CR>", { noremap = true, silent = true, nowait = true})

            -- Immediately open the window in a new tab instead of a split
            vim.cmd("wincmd T")
        end,
    })

    -- Auto commands for help files
    vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*.txt",
        callback = function()
            if vim.bo.filetype == "help" then
                -- In the help files, use q to exit
                vim.api.nvim_buf_set_keymap(0, "n", "q", ":bd<CR>", { noremap = true, silent = true, nowait = true})
                -- Open it in a new tab
                vim.cmd("wincmd T")
            end
        end,
    })

    -- Auto create session if we're quitting and didn't start with arguments
    -- vim.api.nvim_create_autocmd("VimLeavePre", {
    --     group = vim.api.nvim_create_augroup("SaveSession", { clear = true }),
    --     callback = function()
    --         if vim.v.dying > 0 then return end
    --
    --         local ok, err = pcall(mksession)
    --
    --         if not ok then
    --             vim.notify(string.format("Failed to save session: %s", err), vim.log.levels.ERROR)
    --         end
    --     end,
    -- })

    -- Auto restore session if it exists
    -- vim.api.nvim_create_autocmd("VimEnter", {
    --     group = vim.api.nvim_create_augroup("RestoreSession", { clear = true }),
    --     nested = true,
    --     once = true,
    --     callback = function()
    --         if vim.fn.argc() > 0 then
    --             return
    --         end
    --
    --         local ok, err = pcall(ldsession)
    --         if not ok then
    --             vim.notify(string.format("Failed to load session: %s", err), vim.log.levels.ERROR)
    --         end
    --     end,
    -- })

    if is_mac then
        vim.keymap.set({"n", "i", "v", "t"}, "<D-C-e>", function() toggle_buffer(vim_tree_settings) end)
        vim.keymap.set("n", "<D-t>", "<cmd>:tabe<CR>")
    elseif is_windows or is_linux then
        vim.keymap.set({"n", "i", "v", "t"}, "<C-M-e>", function() toggle_buffer(vim_tree_settings) end)
        vim.keymap.set({"n", "i", "v", "t"}, "<C-S-e>", function() toggle_buffer(vim_tree_settings) end) -- Workaround for neovide. C-M-e is my preferred keybind.
        vim.keymap.set("n", "<C-S-t>", "<cmd>:tabe<CR>")
    end
end

if is_mac then
    vim.keymap.set('v', '<D-c>', '"+y') -- Copy
    vim.keymap.set("n", "<D-c>", '"+') -- Select global copy buffer, but don't grab anything
    vim.keymap.set('n', '<D-v>', '"+gpv`[=`]') -- Paste normal mode
    vim.keymap.set('c', '<D-v>', '<C-R>"+p') -- Paste command mode
    vim.keymap.set('i', '<D-v>', '<Esc>"+gpa') -- Paste insert mode
    vim.keymap.set("t", '<D-v>', '<C-\\><C-n>l"+gpa') -- Paste terminal mode

    if is_neovide then
        -- Increase font size
        vim.keymap.set('n', '<D-=>', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
        end, { silent = true })

        -- Decrease font size
        vim.keymap.set('n', '<D-->', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1 / 1.1
        end, { silent = true })

        -- Reset font size
        vim.keymap.set('n', '<D-0>', function()
            vim.g.neovide_scale_factor = 1
        end, { silent = true })
    end

    vim.keymap.set({"i", "n"}, "<D-/>", "gcc", { remap = true, silent = true})
    vim.keymap.set("v", "<D-/>", "gc", { remap = true, silent = true})
    vim.keymap.set("i", "<D-Left>", "<Esc>bi")
    vim.keymap.set("i", "<D-Right>", "<Esc>wi")
    vim.keymap.set("n", "<D-Left>", "b")
    vim.keymap.set("n", "<D-Right>", "w")
    vim.keymap.set("n", "<D-a>", "gg^<S-V><S-G>")
    vim.keymap.set("i", "<D-a>", "<Esc>gg^<S-V><S-G>")
elseif is_windows or is_linux then
    vim.keymap.set("v", "<C-S-c>", '"+y') -- Copy
    vim.keymap.set("n", "<C-S-c>", '"+') -- Select global copy buffer, but don't grab anything
    vim.keymap.set("n", "<C-S-v>", '"+gpv`[=`]') -- Paste normal mode
    vim.keymap.set("c", "<C-S-v>", '<C-R>"+p') -- Paste command mode
    vim.keymap.set("i", "<C-S-v>", '<esc>"+gpa') -- Paste insert mode
    vim.keymap.set("t", "<C-S-v>", '<C-\\><C-n>l"+gpa') -- Paste terminal mode

    if is_neovide then
        -- Increase font size
        vim.keymap.set('n', '<C-=>', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1.1
        end, { silent = true })

        -- Decrease font size
        vim.keymap.set('n', '<C-->', function()
            vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * 1 / 1.1
        end, { silent = true })

        -- Reset font size
        vim.keymap.set('n', '<C-0>', function()
            vim.g.neovide_scale_factor = 1
        end, { silent = true })
    end

    vim.keymap.set({"i", "n"}, "<C-/>", "gcc", { remap = true, silent = true})
    vim.keymap.set("v", "<C-/>", "gc", { remap = true, silent = true})
end

-- ============= COMMANDS =============
vim.api.nvim_create_user_command("Cd",
    function(opts)
        local navpath = vim.fn.expand(opts.args)
        if not utils:directory_exists(navpath) then
            vim.notify(string.format("Directory does not exist: '%s'", navpath))
            return
        end
        vim.cmd("Save") -- Create a temporary session we can get back to if things don't work out
        local tree = require("nvim-tree.api").tree
        tree.open({path = navpath})
        tree.change_root(navpath)

        -- Close every buffer except tree
        local tree_bufn = vim.api.nvim_get_current_buf()
        for _, bufn in pairs(vim.api.nvim_list_bufs()) do
            local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
            if bufn ~= tree_bufn and (
                buftype == "terminal" or
                buftype == "nofile" or
                buftype == "help"
            )
            then
                -- We can happily force close terinals and files which aren't real
                local ok, err = pcall(vim.api.nvim_buf_delete, bufn, {force = true})
                if not ok then
                    vim.notify(string.format("Cannot force close one of the open buffers, will not attempt to cd: %s", err), vim.log.levels.ERROR)
                    return
                end
            elseif bufn ~= tree_bufn then
                -- Can't force close these guys
                local ok, err = pcall(vim.api.nvim_buf_delete, bufn, {force = false})
                if not ok then
                    vim.notify(string.format("Cannot close one of the open buffers, will not attempt to cd: %s", err), vim.log.levels.ERROR)
                    return
                end
            end
        end
        local ok, err = pcall(vim.cmd, "cd " .. navpath)
        if not ok then
            vim.notify(string.format("Cannot navigate to path: %s", err), vim.log.levels.ERROR)
            return
        end

        return true
    end,
    {
        nargs = 1,
        complete = "dir"
    })

-- Create a temporary save (not using the global session)
vim.api.nvim_create_user_command("Tags",
    function(opts)
        utils:system("ctags", "--options=.ctags", "-R", ".")
    end,
    {
    })

vim.api.nvim_create_user_command("Save",
    function(opts)
        local session_path = opts.args == "" and get_session_path() or opts.args
        local ok, err = pcall(mksession, session_path)

        if not ok then
            vim.notify(string.format("Failed to save session: %s", err), vim.log.levels.ERROR)
        else
            vim.notify(string.format("Saved session to %s", session_path), vim.log.levels.INFO)
        end
    end,
    {
        nargs = "*",
        complete = "file"
    })

vim.api.nvim_create_user_command("Back", function()
    local ok, err = pcall(ldsession, nil, true)
    if not ok then
        vim.notify(string.format("Failed to load session: %s", err), vim.log.levels.ERROR)
        return
    end
end, {})

vim.api.nvim_create_user_command("Load", function(opts)
    opts.args = opts.args and opts.args:match("%s*(%S+)%s*") -- Somehow we're getting some cursed shit passed in here
    local ok, err = pcall(ldsession, opts.args == "" and nil or opts.args)
    if not ok then
        vim.notify(string.format("Failed to load session: %s", err), vim.log.levels.ERROR)
        return
    end
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("Sessions", function()
    local session_state = utils:read_mpack_file(saved_sessions_path)
    if not session_state then vim.notify("No state file!"); return end
    vim.notify(vim.inspect(session_state))
end, {})

vim.api.nvim_create_user_command("SessionsClear", function()
    utils:delete_file(saved_sessions_path)
end, {})

vim.api.nvim_create_user_command("LspInstall",
    function()
        local lsp_utils = reload_package("lsp_utils")
        vim.notify("About to run installers, this might take a while")
        local ok, err = pcall(lsp_utils.setup, lsp_utils)
        if not ok then
            utils:log(err)
            vim.notify(string.format("Error running installers: %s", err), vim.log.levels.ERROR)
        end
        vim.notify("Finished installing")
    end, {})

vim.api.nvim_create_user_command("Logs",
    function(opts)
        local log_path = vim.fn.expand(vim.fn.stdpath("log") .. "/" .. opts.args)
        vim.cmd("e " .. log_path)
    end, {
        nargs = 1,
        complete = function(ArgLead, CmdLine, CursorPos)
            local files = vim.fn.readdir(vim.fn.expand(vim.fn.stdpath("log")))
            ArgLead = ArgLead or ""
            return vim.tbl_filter(function(f)
                return f:match(ArgLead .. ".*%.log$") ~= nil
            end, files)
        end
    })

vim.api.nvim_create_user_command("Config",
    function()
        vim.cmd("Save")
        local config_session = vim.fn.stdpath("config") .. "/Session.vim"
        vim.cmd("Load " .. config_session)
    end, {})

vim.api.nvim_create_user_command("ConfigSave",
    function(opts)
        if not opts.args then
            vim.notify("Must pass a commit message", vim.log.levels.ERROR)
            return
        end
        local config_dir = vim.fn.stdpath("config")
        local status = vim.system({
            "git",
            "-C",
            config_dir,
            "add",
            "-A"
        }):wait()
        if status.code ~= 0 then
            vim.notify(string.format("Unable to add files: %s", status.err), vim.log.levels.ERROR)
            return
        end
        status = vim.system({
            "git",
            "-C",
            config_dir,
            "commit",
            "-m",
            '"' .. opts.args .. '"'
        }):wait()
        if status.code ~= 0 then
            vim.notify(string.format("Unable to commit files: %s", status.err), vim.log.levels.ERROR)
            return
        end
        status = vim.system({
            "git",
            "-C",
            config_dir,
            "push"
        }):wait()
        if status.code ~= 0 then
            vim.notify(string.format("Unable to push files: %s", status.err), vim.log.levels.ERROR)
            return
        end
        vim.notify("Committed and pushed", vim.log.levels.INFO)
    end,
    {
        nargs = "+"
    })

if is_native then
    vim.api.nvim_create_user_command("Grep", function(opts)
        -- Run grep silently (fills quickfix list)
        local ok, err = pcall(vim.cmd, "silent grep! " .. opts.args)
        if ok then
            if #vim.fn.getqflist() <= 0 then return end
            vim.cmd("copen")
            -- Clear the highlight
            vim.cmd("nohlsearch")
        else
            vim.notify(string.format("Error occurred calling rg: %s", err), vim.log.levels.ERROR)
        end
    end, { nargs = "+", complete = "file" })

    vim.api.nvim_create_user_command('Wrap', function()
        vim.opt.wrap = not vim.o.wrap
        vim.opt.linebreak = not vim.o.wrap
    end, {})
    vim.api.nvim_create_user_command('MessagesToBuffer', function()
        local msgs = vim.api.nvim_command_output('messages')
        local buf = vim.api.nvim_create_buf(false, true) -- [listed=false, scratch=true]

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(msgs, '\n'))
        vim.cmd("split")
        vim.api.nvim_win_set_buf(0, buf)
    end, {})

    vim.api.nvim_create_user_command('Help', function(opts)
        local selected_text

        -- If the command was called with a range (e.g., from Visual Mode)
        if opts.range > 0 then
            -- Get the lines within the range
            local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, false)
            -- In visual mode, we usually just want the first word or the joined line
            selected_text = table.concat(lines, " "):match("^%s*(.-)%s*$")
        else
            -- Fallback: if no range, use the word under the cursor (<cword>)
            selected_text = vim.fn.expand("<cword>")
        end

        -- Execute the native help command
        if selected_text ~= "" then
            vim.cmd("help " .. selected_text)
        else
            print("No text selected for help")
        end
    end,
    {
        range = true,
        desc = "Alias for help using visual selection or current word"
    })

    -- Format the current buffer
    vim.api.nvim_create_user_command("Format", function()
        vim.lsp.buf.format { async = true }
    end, {})

    -- Preview Markdown
    vim.api.nvim_create_user_command("Markdown", function()
        local file

        -- Check if current buffer is netrw
        if vim.bo.filetype == "netrw" then
            -- Get filename under cursor in netrw
            -- netrw shows file names in the buffer, so grab the line text
            local line = vim.api.nvim_get_current_line()
            -- Construct full path: netrw’s directory + filename under cursor
            local dir = vim.fn.expand("%:p:h") -- netrw directory path
            file = vim.fn.fnamemodify(dir .. "/" .. line, ":p") -- full path

        else
            -- Normal buffer: current file path
            file = vim.fn.expand("%:p")
        end

        -- Safety check: make sure file exists
        if vim.fn.empty(file) == 1 or vim.fn.filereadable(file) == 0 then
            vim.notify("No valid file to preview!", vim.log.levels.ERROR)
            return
        end

        vim.cmd("vsplit") -- vertical split
        vim.cmd("wincmd l") -- move to right split
        vim.cmd("terminal glow " .. vim.fn.fnameescape(file)) -- open terminal running glow
    end, {})
end

-- ============= EMBEDDED CONFIGURATION =============
if is_vscode then
    local vscode = require("vscode")
    -- Keybinds
    -- Args can be found here: https://github.com/microsoft/vscode/blob/676ae78fa5f71398c50e42f887f5b0da052d9ec8/src/vs/workbench/contrib/search/browser/searchActionsFind.ts#L241
    -- Example from workbench.action.findInFiles
    --[[
       properties: {
           query: { 'type': 'string' },
           replace: { 'type': 'string' },
           preserveCase: { 'type': 'boolean' },
           triggerSearch: { 'type': 'boolean' },
           filesToInclude: { 'type': 'string' },
           filesToExclude: { 'type': 'string' },
           isRegex: { 'type': 'boolean' },
           isCaseSensitive: { 'type': 'boolean' },
           matchWholeWord: { 'type': 'boolean' },
           useExcludeSettingsAndIgnoreFiles: { 'type': 'boolean' },
           onlyOpenEditors: { 'type': 'boolean' },
           showIncludesExcludes: { 'type': 'boolean' }
        }
    --]]
    -- Find
    vim.keymap.set({"n"}, "<leader>f", function()
        vscode.action("workbench.action.findInFiles")
    end)
    vim.keymap.set({"v"}, "<leader>f", function()
        vscode.action("workbench.action.findInFiles", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)

    -- Replace (local file)
    vim.keymap.set({"n"}, "<leader>h", function()
        vscode.action("editor.action.startFindReplaceAction")
    end)
    vim.keymap.set({"v"}, "<leader>h", function()
        vscode.action("editor.action.startFindReplaceAction", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)

    -- Replace (all files)
    vim.keymap.set({"v"}, "<leader>r", function()
        vscode.action("workbench.action.replaceInFiles", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)
    vim.keymap.set({"n"}, "<leader>r", function()
        vscode.action("workbench.action.replaceInFiles")
    end)

    -- Open (ctrl+p menu)
    vim.keymap.set({"n"}, "<leader>o", function()
        vscode.action("workbench.action.quickOpen", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)

    -- Create new file (location relative to currently active file)
    vim.keymap.set({"n"}, "<leader>n", function()
        vscode.action("welcome.showNewFileEntries")
    end)

    -- Hover tooltip
    vim.keymap.set({"n"}, "<C-,>", function()
        vscode.action("editor.action.showHover")
    end)

    vim.keymap.set({"n"}, "]d", function()
        vscode.action("editor.action.marker.next")
    end)

    vim.keymap.set({"n"}, "[d", function()
        vscode.action("editor.action.marker.prev")
    end)
end

-- ============= NEOVIDE CONFIGURATION =============
if is_neovide then
    -- Bring these back if we're on a computer that just doesn't handle these well
    -- vim.g.neovide_position_animation_length = 0
    -- vim.g.neovide_cursor_animation_length = 0.00
    -- vim.g.neovide_cursor_trail_size = 0
    -- vim.g.neovide_cursor_animate_in_insert_mode = false
    -- vim.g.neovide_cursor_animate_command_line = false
    -- vim.g.neovide_scroll_animation_far_lines = 0
    -- vim.g.neovide_scroll_animation_length = 0.00
end
