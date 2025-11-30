return {
  -- Go development plugin
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua" },
    ft = { "go", "gomod", "gowork", "gotmpl" },
    opts = {
      gofmt = "gofumpt",    -- format tool
      lsp_cfg = false,      -- we use Mason + vim.lsp.config instead
      lsp_inlay_hints = { enable = true },
      trouble = true,
      luasnip = true,
    },
    config = function(_, opts)
      require("go").setup(opts)

      -- Auto format and import on save
      local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          require("go.format").goimport()
        end,
        group = format_sync_grp,
      })
    end,
  },

  -- Go debugger integration
  {
    "leoluz/nvim-dap-go",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = "go",
    config = function()
      require("dap-go").setup()
    end,
  },
}

