

return {

    "neovim/nvim-lspconfig",

    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },

    config = function()

        -- local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        -- for type, icon in pairs(signs) do
				-- local hl = "DiagnosticSign" .. type
				-- vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        -- end

        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        local bufopts = { noremap=true, silent=true, buffer=0 }
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
            -- Show line diagnostics automatically in hover window
            vim.cmd([[
              autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, { focus = false })
            ]])
        end

        require("mason").setup()

        require("mason-lspconfig").setup({
            -- library = { plugins = { "nvim-dap-ui" }, types = true },
            ensure_installed = {
                "lua_ls",
                "pyright",
                "tsserver",
                "bashls",
                "gopls",
                -- "sqlls",
          },
          handlers = {

                function(server_name)
                    require("lspconfig")[server_name].setup({
                        on_attach = on_attach,
                        capabilities = capabilities,
                    })
                end,

               ["lua_ls"] = function ()
                   local lspconfig = require("lspconfig")
                   lspconfig.lua_ls.setup {
                       settings = {
                           Lua = {
                               diagnostics = {
                                   globals = { "vim", "feedkey", "has_words_before" },
                               }
                           }
                       }
                   }
               end,

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
