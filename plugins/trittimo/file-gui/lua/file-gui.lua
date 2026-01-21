local M = {}

M.config = {

}

function M.setup(opts)
    -- Merge user config with defaults
    if opts then
        for k, v in pairs(opts) do
            M.config[k] = v
        end
    end
end
function M:create_floating_textbox()
    -- 1. Create a new empty buffer (not listed in buffer list, scratch buffer)
    local buf = vim.api.nvim_create_buf(false, true)

    -- 2. Define the size and position
    local width = 40
    local height = 10

    -- Calculate centered position
    local row = math.ceil((vim.o.lines - height) / 2) - 1
    local col = math.ceil((vim.o.columns - width) / 2)

    -- 3. Set window options
    local opts = {
        relative = "editor", -- Relative to the entire editor
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",    -- No numbers or status line
        border = "rounded",   -- Adds a nice border
    }

    -- 4. Open the window
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Optional: Set some buffer-specific options
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { " Hello!", " Type here...", "" })
end

function M:select_folder()
  -- 1. Create Buffers
  local input_buf = vim.api.nvim_create_buf(false, true)
  local results_buf = vim.api.nvim_create_buf(false, true)

  -- 2. Layout Settings
  local width = 50
  local row = 5
  local col = math.ceil((vim.o.columns - width) / 2)

  -- 3. Open Results Window (Bottom)
  vim.api.nvim_open_win(results_buf, false, {
    relative = "editor",
    width = width,
    height = 8,
    row = row + 3, -- Positioned below input
    col = col,
    style = "minimal",
    border = "rounded",
  })

  -- 4. Open Input Window (Top)
  vim.api.nvim_open_win(input_buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Search ",
    title_pos = "center",
  })

  -- 5. The Logic: Listen for changes in Input Buffer
  vim.api.nvim_buf_attach(input_buf, false, {
    on_lines = function()
      -- Get current text from input buffer
      local lines = vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)
      local query = lines[1] or ""

      -- Example Logic: Filter a list or run a command
      local new_results = { "Results for: " .. query, "---", "Option A", "Option B" }

      -- Update the results buffer
      vim.api.nvim_buf_set_lines(results_buf, 0, -1, false, new_results)
    end,
  })
end

return M
