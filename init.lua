-- ============= HELPER FUNCTIONS/CONSTANTS =============
local sysname = vim.loop.os_uname().sysname
local is_windows = sysname == "Windows_NT"
local is_linux = sysname == "Linux"
local is_mac = sysname == "Darwin"
local is_neovide = vim.g.neovide
local is_embedded = vim.g.vscode
local is_vscode = vim.g.vscode
local is_native = not is_embedded

-- ============= MISC =============
-- Spacebar is our leader key
vim.g.mapleader = " "

-- Go to the correct indent level automatically
vim.opt.autoindent = true
vim.opt.smartindent = true

if is_native then
    -- Use ripgrep for searching
    if vim.fn.executable("rg") == 1 then
        vim.opt.grepprg = "rg --no-heading --vimgrep"
        vim.opt.grepformat = "%f:%l:%c:%m"
    end

    -- Use 4 spaces for tab
    vim.opt.tabstop = 4
    vim.opt.shiftwidth = 4
    vim.opt.expandtab = true

    -- Permanent undo file
    -- This file only fills to the undo buffer limit, which is good
    vim.opt.undofile = true

    -- :help vim.opt
    vim.cmd(":set relativenumber")

    vim.o.tags = "./tags;,tags"
end

-- ============= PLUGINS =============
if is_native then
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "WarningMsg" },
          { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
      end
    end

    vim.opt.rtp:prepend(lazypath)

    require("lazy").setup({
        spec = {
            { import = "plugins" }
        },
        change_detection = {
            enabled = false
        }
    })
end

-- ============= WHITESPACE =============
if is_native then
    vim.api.nvim_set_hl(0, "ExtraWhitespace", { bg = "#ff0000" })

    local function update_whitespace_highlight()
        vim.cmd([[match ExtraWhitespace /\s\+$/]])
    end

    local function remove_whitespace_highlight()
        vim.cmd([[call clearmatches()]])
    end

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "InsertLeave" }, {
      pattern = "*",
      callback = update_whitespace_highlight,
    })

    vim.api.nvim_create_autocmd({ "InsertEnter", "BufWinLeave" }, {
        pattern = "*",
        callback = remove_whitespace_highlight,
    })
end

-- ============= LAYOUT =============
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_altv = 1
vim.g.netrw_winsize = 25
vim.cmd([[set nowrap]])

if is_native and not is_neovide then
    vim.cmd([[colorscheme habamax]])
end

-- Status
vim.o.laststatus = 2
vim.o.statusline = "%f %y %m %=Ln:%l Col:%c [%p%%]"


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


if is_native then
    -- LSP configs
    vim.keymap.set({"n", "i"}, "<F2>", vim.lsp.buf.rename, { noremap = true, silent = true })

    -- See `:help vim.diagnostic.*` for documentation on any of the below functions
    vim.keymap.set("n", "<C-.>", vim.diagnostic.open_float)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
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
if is_native then
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

    vim.api.nvim_create_user_command("Rotate", function()
        local wins = vim.api.nvim_tabpage_list_wins(0)
        if #wins ~= 2 then
            print("Rotate: Only works with exactly two splits.")
            return
        end

        -- Get current window layout direction
        local win1 = wins[1]
        local win2 = wins[2]

        local pos1 = vim.api.nvim_win_get_position(win1)
        local pos2 = vim.api.nvim_win_get_position(win2)

        local is_horizontal = pos1[1] ~= pos2[1]

        -- Save buffers
        local buf1 = vim.api.nvim_win_get_buf(win1)
        local buf2 = vim.api.nvim_win_get_buf(win2)

        -- Close all but one
        vim.cmd("only")

        -- Re-split in the opposite direction
        if is_horizontal then
            vim.cmd("vsplit")
        else
            vim.cmd("split")
        end

        -- Set buffers
        vim.api.nvim_win_set_buf(0, buf1)
        vim.api.nvim_set_current_win(vim.api.nvim_tabpage_list_wins(0)[2])
        vim.api.nvim_win_set_buf(0, buf2)
    end, {})
end

-- ============= EMBEDDED CONFIGURATION =============
if is_vscode then
    local vscode = require("vscode")
    -- Keybinds
    vim.keymap.set({"n", "v"}, "<leader>f", function()
        vscode.action("workbench.view.search.focus", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)
    vim.keymap.set({"n", "v"}, "<leader>h", function()
        vscode.action("editor.action.startFindReplaceAction", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)
    vim.keymap.set({"n", "v"}, "<leader>r", function()
        vscode.action("workbench.action.replaceInFiles", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)
    vim.keymap.set({"n"}, "<leader>o", function()
        vscode.action("workbench.action.quickOpen", {
            args = { query = vim.fn.expand('<cword>') }
        })
    end)
    vim.keymap.set({"n"}, "<leader>n", function()
        vscode.action("welcome.showNewFileEntries")
    end)
end

-- ============= NEOVIDE CONFIGURATION =============
if is_neovide then
    vim.g.neovide_position_animation_length = 0
    vim.g.neovide_cursor_animation_length = 0.00
    vim.g.neovide_cursor_trail_size = 0
    vim.g.neovide_cursor_animate_in_insert_mode = false
    vim.g.neovide_cursor_animate_command_line = false
    vim.g.neovide_scroll_animation_far_lines = 0
    vim.g.neovide_scroll_animation_length = 0.00
end
