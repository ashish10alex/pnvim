return {
    -- "harrisoncramer/gitlab.nvim",
    dir = "/Users/ashishalex/Documents/personal/repos/gitlab.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "nvim-lua/plenary.nvim",
        "sindrets/diffview.nvim",
        "stevearc/dressing.nvim",                                -- Recommended but not required. Better UI for pickers.
    },
    build = function() require("gitlab.server").build(true) end, -- Builds the Go binary
    config = function()
        require("gitlab").setup()
        vim.api.nvim_set_keymap('n', '<leader>gls', '<cmd>lua require("gitlab").summary()<cr>',
            { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>glo', '<cmd>lua require("gitlab").open_in_browser()<cr>',
            { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>glc', '<cmd>lua require("gitlab").create_mr()<cr>',
            { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>gla', '<cmd>lua require("gitlab").add_assignee()<cr>',
            { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>gla', '<cmd>lua require("gitlab").add_assignee()<cr>',
            { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>glra', '<cmd>lua require("gitlab").add_reviewer()<cr>',
            { silent = true })
        vim.api.nvim_set_keymap('n', '<leader>glp', '<cmd>lua require("gitlab").pipeline()<cr>',
            { silent = true })
    end,
}
