return {
    "ashish10alex/dataform.nvim",
    dir = '/Users/ashishalex/Documents/personal/repos/plugins/dataform.nvim',
    config = function()
        local opts = {
            timeout            = 10000,
            gcp_project_id_dev = "jlr-it-scanalytics-dev",
            sql_out_buf_path   = "/tmp/output.sql",
            dj_cli_path        = "$HOME/bin/dj",
            compiled_json_path = "/tmp/compiled.json",
            error_message_path = "/tmp/error_message.txt",
        }
        require('dataform').setup(opts)

        vim.api.nvim_set_keymap("n", "<leader>dc",
            ":lua require('dataform').trigger_dataform_diagnostics({in_place=true, get_compiled_query=true})<CR>",
            { noremap = true })

        vim.api.nvim_create_autocmd('BufModifiedSet', {
            -- vim.api.nvim_create_autocmd('BufWritePost', {
            desc = 'Compile dataform and run go cli when a sqlx file is modified',
            group = vim.api.nvim_create_augroup('dataform-nvim-group', { clear = true }),
            pattern = '*.sqlx',
            callback =
                function()
                    vim.cmd("silent! write")
                    vim.cmd('lua require("dataform").trigger_dataform_diagnostics({in_place=true})')
                end
        })
    end
}
