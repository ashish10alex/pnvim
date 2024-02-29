return {
    {
        'numToStr/Comment.nvim',
        opts = {
        },
        lazy = false,
    },
    { 'inkarkat/vim-ReplaceWithRegister' },
    { 'andres-lowrie/vim-sqlx' },
    {
        'yuttie/comfortable-motion.vim',
        config = function()
            vim.g.comfortable_motion_friction = 80.0
            vim.g.comfortable_motion_air_drag = 12.0
            vim.g.comfortable_motion_scroll_down_key = "j"
            vim.g.comfortable_motion_scroll_up_key = "k"
        end
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' },
        config = function()
            require('lualine').setup()
        end
    },
    -- Highlight todo, notes, etc in comments
    { 'folke/todo-comments.nvim', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

}
