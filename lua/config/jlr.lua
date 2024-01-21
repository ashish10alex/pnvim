
local read_file = function(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local content = file:read "*a" -- *a or *all reads the whole file
  file:close()
  return content
end

local find_buffer_by_name = function(name)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local buf_name = vim.api.nvim_buf_get_name(bufnr)
    -- print("searching buffer" .. buf_name .. " with bufnr: " .. bufnr)
    if buf_name == name then
      -- print("found buffer" .. buf_name .. " with bufnr: " .. bufnr)
      return bufnr
    end
  end
  return -1
end

local read_stderr_and_get_line_col_numbers = function(stderr_message)
    local line_number, column_index = stderr_message:match("%[(%d+):(%d+)%]") -- takes out [line_number:column_index] from the stderr message
    -- print("line_number: " .. line_number)
    -- print("column_index: " .. column_index)
    line_number = tonumber(line_number) - 1 -- lua is 1 indexed
    column_index = tonumber(column_index)
    return line_number, column_index
end

local compile_sql_on_bigquery_backend = function()
    local GCP_PROJECT_ID_DEV = os.getenv("GCP_PROJECT_ID_DEV")

    local lnum = 0
    local col = 0
    local stderr_message = nil
    local stdout_message = nil

    local Job = require'plenary.job'
    Job:new({
      command = '/Users/ashishalex/Documents/work/jlr/repos/test/go_dry_run/go_dry_run', -- TODO Add go_dry_run to path
      args = { '/private/tmp/temp.sqlx' }, -- TODO: why /private ?
      cwd = '/usr/bin',
      env = { ['GCP_PROJECT_ID_DEV'] = GCP_PROJECT_ID_DEV },

      on_stdout = function(j, data)
        stdout_message = data
      end,

      on_stderr = function(j, data)
        if data ~= nil then
            stderr_message = data
            lnum, col = read_stderr_and_get_line_col_numbers(data)
        end
      end,

      on_exit = function(j, return_val) -- TODO: Handle stderr and stdout separately
         -- print(vim.inspect(j:result()))
      end,

    }):sync() -- or start()
    return lnum, col, stderr_message, stdout_message
end

local compile_dataform = function()
    local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_wt_tag.sh"
    local dataform_compile_cmd = read_file(dataform_compile_cmd_path)
    local output = vim.fn.system(dataform_compile_cmd) -- output is sent to a file /private/tmp/temp.sqlx

    local buf_name = "/private/tmp/temp.sqlx"
    local bufnr = find_buffer_by_name(buf_name)

    local lnum, col, stderr_message, stdout_message = compile_sql_on_bigquery_backend()
    if bufnr ~= -1 then -- buffer already open
        -- TODO: clear previous the diagnostics (Can we do better - whats 1 and 0 (namespace, bufnr) ?)
        vim.diagnostic.reset(1, 0) -- remove all diagnostics from the buffer

        -- TODO: Convert this paragraph to a function
        local diagnostics_table = {}
        diagnostics_table[1] = {bufnr=bufnr, lnum=0, col=0, end_col=1, severity = vim.diagnostic.severity.INFO, message = stdout_message,}
        if stderr_message ~= nil then
            diagnostics_table[2] = {bufnr=bufnr, lnum=lnum, col=col, end_col=2, severity = vim.diagnostic.severity.ERROR, message = stderr_message,}
        end

        vim.diagnostic.set(1, 0, diagnostics_table, {}) -- TODO: get the line number from another cli output

        vim.api.nvim_command("wincmd h")  -- move the cursor to this buffer
        vim.api.nvim_command("edit")      -- refresh the buffer
        vim.api.nvim_command("normal gg") -- goto top of the file

    else -- Buffer not open, create a new one
        local diagnostics_table = {}
        diagnostics_table[1] = {bufnr=bufnr, lnum=0, col=0, end_col=1, severity = vim.diagnostic.severity.INFO, message = stdout_message,}

        if stderr_message ~= nil then
            diagnostics_table[2] = {bufnr=bufnr, lnum=lnum, col=col, end_col=2, severity = vim.diagnostic.severity.ERROR, message = stderr_message,}
        end

        vim.api.nvim_command("vsplit " .. buf_name)
        vim.diagnostic.set(1, 0, diagnostics_table, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_command("wincmd h") -- move the cursor to this buffer and execute edit to load the file

    end
end
vim.api.nvim_create_user_command("CompileDataform", compile_dataform, {})

