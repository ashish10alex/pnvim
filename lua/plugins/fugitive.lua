return {
    'tpope/vim-fugitive',
    dependencies = {
        'tpope/vim-rhubarb',
        'shumphrey/fugitive-gitlab.vim',
        'lewis6991/gitsigns.nvim',
    },
    config = function()
        require('gitsigns').setup()
        vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', {silent = true})
        vim.keymap.set('n', '<leader>gp', ':Git push<CR>', {silent = true})
        -- vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', {silent = true})
        -- vim.keymap.set('n', '<leader>gl', ':Git log<CR>', {silent = true})

        vim.keymap.set('n', ']g', ':Gitsigns next_hunk<CR>', {noremap = true, silent = true})
        vim.keymap.set('n', '[g', ':Gitsigns prev_hunk<CR>', {noremap = true, silent = true})
        vim.keymap.set('n', 'guh',':Gitsigns reset_hunk<CR>', {noremap = true, silent = true})
        vim.keymap.set('n', 'gp', ':Gitsigns preview_hunk<CR>', {noremap = true, silent = true})


        vim.g.netrw_banner = 0 -- disable netrw banner for GitBrowse to work
        vim.g.fugitive_gitlab_domains = { os.getenv("JLR_GITLAB_ADDRESS") }
        vim.keymap.set('n', '<leader>gb', ':GBrowse<CR>', {silent = true})

    end
}

