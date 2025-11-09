return {
  -- Mason: manages external LSP binaries
  { "williamboman/mason.nvim", opts = {} },

  -- Mason + LSP bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "lua_ls", "gopls", "pyright" },
      automatic_installation = true,
      handlers = {
        -- Default handler for any installed server
        function(server)
          vim.lsp.start(vim.lsp.config(server))
        end,

        -- Server-specific configs
        ["lua_ls"] = function()
          vim.lsp.start(vim.lsp.config("lua_ls", {
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
              },
            },
          }))
        end,

        ["gopls"] = function()
          vim.lsp.start(vim.lsp.config("gopls", {
            settings = {
              gopls = {
                analyses = { unusedparams = true },
                staticcheck = true,
              },
            },
          }))
        end,

        ["pyright"] = function()
          vim.lsp.start(vim.lsp.config("pyright", {}))
        end,
      },
    },
  },

  -- Optional: completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    opts = function()
      local cmp = require("cmp")
      return {
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      }
    end,
  },
}

