
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

local compile_dataform = function()
    local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_wt_tag.sh"
    local dataform_compile_cmd = read_file(dataform_compile_cmd_path)
    local output = vim.fn.system(dataform_compile_cmd) -- output is sent to a file using >>

    local buf_name = "/private/tmp/temp.sqlx"
    local bufnr = find_buffer_by_name(buf_name)

    if bufnr ~= -1 then -- buffer already open
        -- TODO: clear previous the diagnostics ?
        vim.diagnostic.set(1, 0, {{bufnr=bufnr, lnum=55, col=1, end_col=2, severity = vim.diagnostic.severity.ERROR, message = "Syntax error NEW: BigQuery test",}}, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_command("wincmd h") -- move the cursor to this buffer and execute edit to load the file
        vim.api.nvim_command("edit")

    else -- buffer not open, create a new one
        vim.api.nvim_command("vsplit " .. buf_name)
        vim.diagnostic.set(1, 0, {{bufnr=bufnr, lnum=55, col=1, end_col=2, severity = vim.diagnostic.severity.ERROR, message = "Syntax error: BigQuery test",}}, {}) -- TODO: get the line number from another cli output
        vim.api.nvim_command("wincmd h") -- move the cursor to this buffer and execute edit to load the file

    end
end
vim.api.nvim_create_user_command("CompileDataform", compile_dataform, {})

