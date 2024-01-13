return {
  "kndndrj/nvim-dbee",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  build = function()
    -- Install tries to automatically detect the install method.
    -- if it fails, try calling it with one of these parameters:
    --    "curl", "wget", "bitsadmin", "go"
    -- require("dbee").install()
  end,
   config = function()
  require("dbee").setup {
    sources = {
      require("dbee.sources").MemorySource:new({
        {
          name = "jlr bigquery",
          type = "bigquery",
          url = "bigquery://jlr-it-scanalytics-dev",
        },
        {
          name = "test_sqllite",
          type = "sqlite",
          url = "/Users/ashishalex/Documents/personal/repos/test/mydatabase.db",
        },
        -- ...
      }),

      -- require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
      require("dbee.sources").FileSource:new(vim.fn.stdpath("cache") .. "/dbee/persistence.json"),
    },
  }
    vim.api.nvim_create_user_command("DBExec",
        function(arg)
            local selected_text = vim.api.nvim_buf_get_lines(0, arg.line1 - 1, arg.line2, false)
            local query = table.concat(selected_text, " ")
            require("dbee").execute(query)
        end,
        {
            desc = "Execute a query.",
            range = "%",
            nargs = 0,
        })
    end
}

