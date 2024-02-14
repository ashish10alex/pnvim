local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("config.defaults")
require("config.keymaps")
require("config.autocmds")
require("config.jlr")

require("lazy").setup({
	{import = 'plugins'},
    {
        "ashish10alex/dataform.nvim",
        dir = '/Users/ashishalex/Documents/personal/repos/plugins/dataform.nvim',
        config = function()
            local opts = {
                timeout = 10000,
                gcp_project_id_dev = "jlr-it-scanalytics-dev",
                sql_out_buf_path = "/tmp/output.sql",
                go_dry_run_cli_path = "$HOME/bin/go_dry_run",
            }
            require('dataform').setup(opts)
        end
    },
})

