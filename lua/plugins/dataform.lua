return {
    "ashish10alex/dataform.nvim",
    dependencies = {
        "hrsh7th/nvim-cmp",
        "onsails/lspkind.nvim"
    },
    dir = '/Users/ashishalex/Documents/personal/repos/plugins/dataform.nvim',
    config = function()
        local opts = {
            timeout            = 10000,
            gcp_project_id     = vim.env.GCP_PROJECT_ID_DEV,
            sql_out_buf_path   = "/tmp/output.sql",
            dj_cli_path        = "$HOME/bin/dj",
            compiled_json_path = "/tmp/compiled.json",
            error_message_path = "/tmp/error_message.txt",
            create_autocmds    = true,
        }
        require('dataform').setup(opts)

        vim.api.nvim_set_keymap("n", "<leader>dc",
            ":lua require('dataform').trigger_dataform_diagnostics({in_place=true, get_compiled_query=true})<CR>",
            { noremap = true }
        )
    end
}

--[[
return {
  'magal1337/dataform.nvim',
  dir = '/Users/ashishalex/Documents/personal/repos/dataform.nvim',
  dependencies = {
    'rcarriga/nvim-notify',
  },
}
--]]
