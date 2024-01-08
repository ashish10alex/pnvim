return {
	'nvim-telescope/telescope.nvim', tag = '0.1.5',
	dependencies = {
		'nvim-lua/plenary.nvim' ,
		{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        "LinArcX/telescope-env.nvim",
	},
	config = function()
        local grep_args = { '--hidden' }
        require('telescope').setup {
          defaults = {
            prompt_prefix = "> ",
            file_ignore_patterns = {".git/", ".cache", "%.o", "%.a", "%.out", "%.class",
                "%rpdf", "%.mkv", "%.mp4", "%.zip", "node_modules", "yarn.lock"},
          },
          pickers = {
            find_files = {
              hidden = true,
              git_ignore = false,
            },
            live_grep = {
              additional_args = function(opts)
                return grep_args
              end
            },
            grep_string = {
              additional_args = function(opts)
                return grep_args
              end
            },
            buffers = {
              show_all_buffers = true,
              sort_lastused = true,
              theme = "dropdown",
              previewer = false,
              mappings = {
                n = {
                  ["<c-d>"] = "delete_buffer",
                }
              }
            },
          },
          extensions = {
            fzf = {
              fuzzy = true,                    -- false will only do exact matching
              override_generic_sorter = true,  -- override the generic sorter
              override_file_sorter = true,     -- override the file sorter
              case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                               -- the default case_mode is "smart_case"
            }
          },
        }
        require('telescope').load_extension('fzf')
        require('telescope').load_extension('env')
		local builtin = require("telescope.builtin")
		vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>b', builtin.buffers, {})
        vim.keymap.set('n', '<leader>grep', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>greb', builtin.current_buffer_fuzzy_find, {})
        vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
	end,
}
