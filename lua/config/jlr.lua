
local read_file = function(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local content = file:read "*a" -- *a or *all reads the whole file
  file:close()
  return content
end

local compile_dataform = function()
    local dataform_compile_cmd_path = os.getenv("HOME") .. "/.config/nvim/lua/config/dataform_compile_wt_tag.sh"
    local dataform_compile_cmd = read_file(dataform_compile_cmd_path)
    local output = vim.fn.system(dataform_compile_cmd) -- output is sent to a file using >>
    print("Compiled dataform output to /tmp/temp.sqlx")

    local buf_name = "/tmp/temp.sqlx"
    local bufnr = vim.fn.bufnr(buf_name, true)
    if bufnr ~= -1 then
        print("Buffer number: " .. bufnr)
        vim.api.nvim_command("vsplit " .. buf_name)
        vim.diagnostic.set(1, 0, {{bufnr=bufnr, lnum=55, col=1, end_col=2, severity = vim.diagnostic.severity.ERROR, message = "Syntax error: Missing closing parenthesis",}}, {}) -- TODO: get the line number from another cli output
    else
        print("Buffer number: " .. bufnr)
        vim.api.nvim_command("edit " .. buf_name)
    end
end
vim.api.nvim_create_user_command("CompileDataform", compile_dataform, {})

