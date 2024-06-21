return {
    "NeogitOrg/neogit",
    branch="master",
    dependencies = {
        "nvim-lua/plenary.nvim",  -- required
        "sindrets/diffview.nvim", -- optional - Diff integration

        -- Only one of these is needed, not both.
        "nvim-telescope/telescope.nvim", -- optional
    },
    config = function()
        local neogit = require('neogit')
        neogit.setup({
            filewatcher = { enabled = false }
        })

        vim.keymap.set('n', '<leader>gs', ':Neogit<CR>', { silent = true })

    end

}
