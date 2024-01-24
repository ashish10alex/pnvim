
SQL_OUT_BUF_PATH = "/private/tmp/temp.sqlx"

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
    if buf_name == name then
      return bufnr
    end
  end
  return -1
end

local reset_diagnostics = function(bufnr)
    -- TODO: Can we do better - what are 1 and 0 (namespace, bufnr) ?)
    if bufnr ~= -1 then
        vim.diagnostic.reset(1, bufnr) -- remove all diagnostics from the buffer
    else
        vim.diagnostic.reset(1, 0) -- remove all diagnostics from the buffer
    end
end

local parse_dataform_tags = function(args)
    local tagsString = ""
    local include_deps = false
    if args == nil then
        print("No args passed")
    else
        local parsedArgs = args.args
        local test = load("return " .. parsedArgs)() -- load the string as a lua table
        include_deps = test.include_deps

        -- print('test.tags: ' .. vim.inspect(test.tags))
        -- print('test.include_deps ' .. vim.inspect(test.include_deps))

        for w in test.tags:gmatch("([^,]+)") do -- split the string by comma
            w = string.gsub(w, "%s+", "") -- trim white space
            tagsString = tagsString .. '--tags=' .. w .. ' '
        end

    end
    return tagsString, include_deps
end

local read_stderr_and_get_line_col_numbers = function(stderr_message)
    local line_number = 0
    local column_index = 0
    local _line_number, _column_index = stderr_message:match("%[(%d+):(%d+)%]") -- takes out [line_number:column_index] from the stderr message
    if _line_number ~= nil and _column_index ~= nil then
        line_number, column_index = _line_number, _column_index
        line_number = tonumber(line_number) - 1 -- lua is 1 indexed
        column_index = tonumber(column_index)
        return line_number, column_index
    else
        return line_number, column_index
    end
end

local set_diagnostics_to_buffer = function(bufnr, diagnostics_table, buf_name)
    if bufnr ~= -1 then -- buffer already open
        vim.diagnostic.set(1, bufnr, diagnostics_table, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_set_current_buf(bufnr) -- move the cursor to this buffer
        vim.api.nvim_command("normal gg") -- goto top of the file
    else -- Buffer not open, create a new one
        vim.api.nvim_command("edit " .. buf_name)
        vim.diagnostic.set(1, 0, diagnostics_table, {}) -- TODO: get the line number from another cli output
    end
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
      command = '/Users/ashishalex/bin/go_dry_run', -- TODO Add go_dry_run to path
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

local check_if_cwd_is_dataform_project_root = function()
    local dataform_json_file_path = vim.loop.cwd() .. "/dataform.json"
    local dataform_json_file_exists = vim.fn.filereadable(dataform_json_file_path)
    if dataform_json_file_exists == 0 then
        error("Not in dataform project root, dataform.json not found in current working directory")
        return nil
    end
    return true
end

local compile_dataform = function()
    -- TODO: To be deprecated ... (No need to compile the whole project from Neovim. Use cli instead)

    local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_wt_tag.sh"
    -- local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_all.sh"

    local dataform_compile_cmd = read_file(dataform_compile_cmd_path)
    local output = vim.fn.system(dataform_compile_cmd) -- output is sent to a file /private/tmp/temp.sqlx; TODO: Use plenary to capture stdout and stderr

    local bufnr = find_buffer_by_name(SQL_OUT_BUF_PATH)
    reset_diagnostics(bufnr)

    local lnum, col, stderr_message, stdout_message = compile_sql_on_bigquery_backend()


    local diagnostics_table = process_dianostics(bufnr, lnum, col, stderr_message, stdout_message)

    if bufnr ~= -1 then -- buffer already open
        vim.diagnostic.set(1, bufnr, diagnostics_table, {}) -- TODO: get the line number from another cli output

        vim.api.nvim_command("wincmd h")  -- move the cursor to the left buffer
        vim.api.nvim_command("wincmd k")  -- move the cursor to the top buffer
        vim.api.nvim_command("edit")      -- refresh the buffer
        vim.api.nvim_command("normal gg") -- goto top of the file

    else -- Buffer not open, create a new one
        vim.api.nvim_command("vsplit " .. SQL_OUT_BUF_PATH)
        vim.diagnostic.set(1, 0, diagnostics_table, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_command("wincmd h") -- move the cursor to this buffer and execute edit to load the file
    end
end

local compile_dataform_file = function()

    local in_dataform_project_root = check_if_cwd_is_dataform_project_root()
    if in_dataform_project_root == nil then
        return
    end

    local filepath_wrt_project_root = vim.fn.expand("%h")
    -- print('filepath_wrt_project_root: ' .. vim.inspect(filepath_wrt_project_root))

    -- check if file ends with .sqlx

    local file_extension = vim.fn.expand("%:e")
    if file_extension ~= "sqlx" then
        error("File extension must be .sqlx")
        return
    end

    local dataform_compile_file_cmd = [[
        echo "-- $(date)" > ]] .. SQL_OUT_BUF_PATH .. [[ ;

        dataform compile --json | \
        jq -r '.tables[] |
        select( .fileName == "]].. filepath_wrt_project_root.. [[") |
        "-- } " + .fileName + "\n" + "-- { tags " + (.tags | tojson) + "\n" + .query + "; \n" '  >> ]] .. SQL_OUT_BUF_PATH .. [[ ;

    ]]

    -- Remove assertions from compile to make it faster
    -- dataform compile --json | \
    -- jq -r '.assertions[] |
    -- select( .fileName == "]].. filepath_wrt_project_root.. [[") |
    -- "-- } " + .fileName + "\n" + "-- { tags " + (.tags | tojson) + "\n" + .query + "; \n" '  >> ]] .. SQL_OUT_BUF_PATH .. [[ ;
    -- ]]

    local _ = vim.fn.system(dataform_compile_file_cmd)
    local lnum, col, stderr_message, stdout_message = compile_sql_on_bigquery_backend()

    local bufnr = find_buffer_by_name(SQL_OUT_BUF_PATH)

    reset_diagnostics(bufnr)
    local diagnostics_table = process_dianostics(bufnr, lnum, col, stderr_message, stdout_message)
    set_diagnostics_to_buffer(bufnr, diagnostics_table, SQL_OUT_BUF_PATH)

end


local compile_dataform_wt_tag = function(args)

    local in_dataform_project_root = check_if_cwd_is_dataform_project_root()
    if in_dataform_project_root == nil then
        return
    end

    local tagsString, include_deps = parse_dataform_tags(args)
    print('tagsString: ' .. tagsString .. ' include_deps: ' .. vim.inspect(include_deps))
    if include_deps == true then
        tagsString = tagsString .. '--include-deps '
    end

    local dataform_compile_cmd_wt_tag = [[
        echo "-- $(date)" > ]] .. SQL_OUT_BUF_PATH .. [[ ;
        dataform run --dry-run  --json  ]] .. tagsString ..  [[  | jq -r '.actions | .[] | "-- " +  .tableType + " \n -- " + .fileName + "\n \n" + .tasks[].statement + " \n ;" ' >> ]] .. SQL_OUT_BUF_PATH .. [[
    ]]

    local _ = vim.fn.system(dataform_compile_cmd_wt_tag)
    local lnum, col, stderr_message, stdout_message = compile_sql_on_bigquery_backend()

    local bufnr = find_buffer_by_name(SQL_OUT_BUF_PATH)
    reset_diagnostics(bufnr)
    local diagnostics_table = process_dianostics(bufnr, lnum, col, stderr_message, stdout_message)
    set_diagnostics_to_buffer(bufnr, diagnostics_table, SQL_OUT_BUF_PATH)

end

-- vim.api.nvim_create_user_command("CompileDataform", compile_dataform, {})
vim.api.nvim_create_user_command("CompileDataformFile", compile_dataform_file, {})
vim.api.nvim_create_user_command("CompileDataformWtTag", compile_dataform_wt_tag, {nargs='*'})

--create keymap
vim.api.nvim_set_keymap('n', '<leader>ef', ':CompileDataformFile<CR>', {noremap = true, silent = true})
