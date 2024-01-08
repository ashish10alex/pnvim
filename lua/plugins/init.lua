return {
    {
        "catppuccin/nvim", name = "catppuccin", priority = 1000 ,
        lazy = false,
        config = function()
            vim.cmd.colorscheme "catppuccin"
        end
    },
    { 'tpope/vim-commentary'},
    { 'dstein64/vim-startuptime'},
    { 'inkarkat/vim-ReplaceWithRegister'},
    { 'yuttie/comfortable-motion.vim', 
        config = function()
            vim.g.comfortable_motion_friction = 80.0
            vim.g.comfortable_motion_air_drag = 12.0
            vim.g.comfortable_motion_scroll_down_key = "j"
            vim.g.comfortable_motion_scroll_up_key = "k"
        end
    },
}
