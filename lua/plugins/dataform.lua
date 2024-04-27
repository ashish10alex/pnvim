return {
    "ashish10alex/dataform.nvim",
    dir = '/Users/ashishalex/Documents/personal/repos/plugins/dataform.nvim',
    config = function()
        local opts = {
            timeout            = 10000,
            gcp_project_id_dev = vim.env.GCP_PROJECT_ID_DEV,
            sql_out_buf_path   = "/tmp/output.sql",
            dj_cli_path        = "$HOME/bin/dj",
            compiled_json_path = "/tmp/compiled.json",
            error_message_path = "/tmp/error_message.txt",
        }
        require('dataform').setup(opts)
    end
}
