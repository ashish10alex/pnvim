return {

    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/nvim-cmp",
        "folke/neodev.nvim",
    },

    config = function()
        -- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        -- for type, icon in pairs(signs) do
        -- local hl = "DiagnosticSign" .. type
        -- vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        -- end

        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        local bufopts = { noremap = true, silent = true, buffer = 0 }
        local on_attach = function()
            vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
            vim.keymap.set("n", "L", vim.lsp.buf.signature_help, bufopts)
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
            -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
            vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, bufopts)
            vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
            vim.keymap.set("n", "]e", vim.diagnostic.goto_next, bufopts)
            vim.keymap.set("n", "[e", vim.diagnostic.goto_prev, bufopts)
            vim.keymap.set("n", "qe", vim.diagnostic.setqflist, bufopts)
            vim.keymap.set("n", "ga", vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', '<space>k', function() vim.lsp.buf.format { async = true } end, bufopts)
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics, {
                    severity_sort = { reverse = false }
                }
            )
        end

        local cmp = require("cmp")

        cmp.setup({
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            }
        })


        -- Specify how the border looks like
        local border = {
            { '┌', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '┐', 'FloatBorder' },
            { '│', 'FloatBorder' },
            { '┘', 'FloatBorder' },
            { '─', 'FloatBorder' },
            { '└', 'FloatBorder' },
            { '│', 'FloatBorder' },
        }

        -- Add the border on hover and on signature help popup window
        local handlers = {
            ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
            ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
        }

        -- Add border to the diagnostic popup window
        vim.diagnostic.config({
            virtual_text = {
                prefix = '■ ', -- Could be '●', '▎', 'x', '■', , 
            },
            float = { border = border },
        })

        require("mason").setup()

        require("mason-lspconfig").setup({
            -- library = { plugins = { "nvim-dap-ui" }, types = true },
            ensure_installed = {
                "lua_ls",
                "pyright",
                "tsserver",
                "bashls",
                "gopls",
                "jsonls",
                -- "terraformls",
                -- "tflint",
            },
            handlers = {
                function(server_name)
                    require("lspconfig")[server_name].setup({
                        on_attach = on_attach,
                        handlers = handlers,
                        capabilities = capabilities,
                    })
                end,

                ["lua_ls"] = function()
                    local lspconfig = require("lspconfig")
                    lspconfig.lua_ls.setup {
                        handlers = handlers,
                        capabilities = capabilities,
                        on_attach = on_attach,
                        settings = {
                            Lua = {
                                runtime = { version = 'LuaJIT' },
                                workspace = {
                                    checkThirdParty = false,
                                    -- Tells lua_ls where to find all the Lua files that you have loaded
                                    -- for your neovim configuration.
                                    library = {
                                        '${3rd}/luv/library',
                                        unpack(vim.api.nvim_get_runtime_file('', true)),
                                    },
                                    -- If lua_ls is really slow on your computer, you can try this instead:
                                    -- library = { vim.env.VIMRUNTIME },
                                },
                                completion = {
                                    callSnippet = 'Replace',
                                },
                                -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
                                -- diagnostics = { disable = { 'missing-fields' } },
                            },
                        },

                    }
                end,
                -- ["terraformls"] = function()
                --     local lspconfig = require("lspconfig")
                --     lspconfig.terraformls.setup{
                --         capabilities = capabilities,
                --         on_attach = on_attach,
                --     }
                --     vim.api.nvim_create_autocmd({"BufWritePre"}, {
                --       pattern = {"*.tf", "*.tfvars"},
                --       callback = function()
                --         vim.lsp.buf.format()
                --       end,
                --     })
                -- end,
                -- ["sqlls"] = function()
                --       local lspconfig = require("lspconfig")
                --       lspconfig.sqlls.setup {
                --           cmd = { "sql-language-server", "up", "--method", "stdio"},
                --           filetypes = { "sql" },
                --           root_dir = function() return vim.loop.cwd() end;
                --           on_attach = on_attach,
                --           capabilities = capabilities,
                --       }
                --   end,

            }
        })
    end
}
