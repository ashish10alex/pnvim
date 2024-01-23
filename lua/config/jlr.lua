
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
    local TIMEOUT = 10000 -- go_dry_run must return in 10 seconds!!

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

      on_exit = function(j, return_val)
         -- print(vim.inspect(j:result()))
      end,

    }):sync(TIMEOUT) -- or start()
    return lnum, col, stderr_message, stdout_message
end

-- @param bufnr: number
-- @param lnum: number
-- @param col: number
-- @param stderr_message: string
-- @param stdout_message: string
local process_dianostics = function(bufnr, lnum, col, stderr_message, stdout_message)
    local diagnostics_table = {}
    if stderr_message ~= nil then
        diagnostics_table[1] = {bufnr=bufnr, lnum=0, col=0, end_col=1, severity = vim.diagnostic.severity.ERROR, message = stderr_message,}
        diagnostics_table[2] = {bufnr=bufnr, lnum=lnum, col=col, end_col=2, severity = vim.diagnostic.severity.ERROR, message = stderr_message,}
    else
        diagnostics_table[1] = {bufnr=bufnr, lnum=0, col=0, end_col=1, severity = vim.diagnostic.severity.INFO, message = stdout_message,}
    end
    return diagnostics_table
end

local compile_dataform = function()

    local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_wt_tag.sh"
    -- local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_all.sh"

    local dataform_compile_cmd = read_file(dataform_compile_cmd_path)
    local output = vim.fn.system(dataform_compile_cmd) -- output is sent to a file /private/tmp/temp.sqlx; TODO: Use plenary to capture stdout and stderr

    local buf_name = "/private/tmp/temp.sqlx"
    local bufnr = find_buffer_by_name(buf_name)

    local lnum, col, stderr_message, stdout_message = compile_sql_on_bigquery_backend()

    -- TODO: Can we do better - what are 1 and 0 (namespace, bufnr) ?)
    if bufnr ~= -1 then
        vim.diagnostic.reset(1, bufnr) -- remove all diagnostics from the buffer
    else
        vim.diagnostic.reset(1, 0) -- remove all diagnostics from the buffer
    end

    local diagnostics_table = process_dianostics(bufnr, lnum, col, stderr_message, stdout_message)

    if bufnr ~= -1 then -- buffer already open
        vim.diagnostic.set(1, bufnr, diagnostics_table, {}) -- TODO: get the line number from another cli output

        vim.api.nvim_command("wincmd h")  -- move the cursor to the left buffer
        vim.api.nvim_command("wincmd k")  -- move the cursor to the top buffer
        vim.api.nvim_command("edit")      -- refresh the buffer
        vim.api.nvim_command("normal gg") -- goto top of the file

    else -- Buffer not open, create a new one
        vim.api.nvim_command("vsplit " .. buf_name)
        vim.diagnostic.set(1, 0, diagnostics_table, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_command("wincmd h") -- move the cursor to this buffer and execute edit to load the file
    end
end

local compile_dataform_file = function()
    -- get filename from the root directory of the project
    local filepath_wrt_project_root = vim.fn.expand("%h")

    local dataform_compile_cmd = [[
        echo "-- $(date)" > /tmp/temp.sqlx

        dataform compile --json | \
        jq -r '.tables[] |
        select( .fileName == "]].. filepath_wrt_project_root.. [[") |
        "-- } " + .fileName + "\n" + "-- { tags " + (.tags | tojson) + "\n" + .query + "; \n" '  >> /private/tmp/temp.sqlx ;

        dataform compile --json | \
        jq -r '.assertions[] |
        select( .fileName == "]].. filepath_wrt_project_root.. [[") |
        "-- } " + .fileName + "\n" + "-- { tags " + (.tags | tojson) + "\n" + .query + "; \n" '  >> /private/tmp/temp.sqlx ;
    ]]
    local output = vim.fn.system(dataform_compile_cmd)
    local lnum, col, stderr_message, stdout_message = compile_sql_on_bigquery_backend()

    local buf_name = "/private/tmp/temp.sqlx"
    local bufnr = find_buffer_by_name(buf_name)

    -- TODO: Can we do better - what are 1 and 0 (namespace, bufnr) ?)
    if bufnr ~= -1 then
        vim.diagnostic.reset(1, bufnr) -- remove all diagnostics from the buffer
    else
        vim.diagnostic.reset(1, 0) -- remove all diagnostics from the buffer
    end

    local diagnostics_table = process_dianostics(bufnr, lnum, col, stderr_message, stdout_message)

    if bufnr ~= -1 then -- buffer already open
        vim.diagnostic.set(1, bufnr, diagnostics_table, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_set_current_buf(bufnr) -- move the cursor to this buffer
        vim.api.nvim_command("normal gg") -- goto top of the file
    else -- Buffer not open, create a new one
        vim.api.nvim_command("edit " .. buf_name)
        vim.diagnostic.set(1, 0, diagnostics_table, {}) -- TODO: get the line number from another cli output
    end
end

vim.api.nvim_create_user_command("CompileDataform", compile_dataform, {})
vim.api.nvim_create_user_command("CompileDataformFile", compile_dataform_file, {})

