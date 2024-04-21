return {
	"nvim-telescope/telescope.nvim",
     branch = 'master',
	dependencies = {
		'nvim-lua/plenary.nvim' ,
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        "LinArcX/telescope-env.nvim",
        "zane-/cder.nvim",
	},
	config = function()
        local grep_args = { '--hidden' }
        require('telescope').setup {
          defaults = {
            prompt_prefix = "> ",
            file_ignore_patterns = {".git/", ".cache", "%.o", "%.a", "%.out", "%.class",
                "%rpdf", "%.mkv", "%.mp4", "%.zip", "node_modules", "yarn.lock"},
            path_display = {
              filename_first = {
              reverse_directories = false
             }
            },
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
            },
            -- change current working directory in context of telescope
            cder = {
              previewer = false,
              dir_command = { 'fd', '--type=d', '.', vim.loop.cwd(), '--hidden', '--exclude', '.git' },
            },
          },
        }

        require('telescope').load_extension('fzf')
        require('telescope').load_extension('env')

        require('telescope').load_extension('cder')
        vim.keymap.set('n', '<leader>cd', ':Telescope cder<CR>', {})

		local builtin = require("telescope.builtin")

		vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>b', builtin.buffers, {})

        vim.keymap.set('n', '<leader>grep', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>greb', builtin.current_buffer_fuzzy_find, {})
        vim.keymap.set('n', '<leader>ps', function()
        builtin.grep_string({search = vim.fn.input("Grep > ") })
        end)

        vim.keymap.set('n', '<leader>grw', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({search = word})
        end)

        vim.keymap.set('n', '<leader>grW', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({search = word})
        end)

        vim.keymap.set('n', '<leader>df', function() -- make it easier to search Dataform files references by $ref{file_name}
            local word = vim.fn.expand("<cword>")
            builtin.find_files({search_file = word})
        end)

        -- vim.keymap.set('n', '<leader>greb', builtin.live_grep, {grep_on_open_files = true})
        vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
        vim.keymap.set('n', '<leader>gf', builtin.git_files, {})
        vim.keymap.set('n', '<leader>gd', builtin.lsp_definitions, {})
        vim.keymap.set('n', '<leader>de', builtin.diagnostics, {})
        vim.keymap.set('n', '<leader>gv', builtin.lsp_references, {})
		vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, {})
		vim.keymap.set('n', '<leader>ws', builtin.lsp_dynamic_workspace_symbols, {})


	end,
}
