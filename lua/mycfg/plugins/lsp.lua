return {
  -- Mason: manages external LSP binaries
  { "williamboman/mason.nvim", opts = {} },

  -- Mason + LSP bridge
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "gopls",
        "pyright",
        "emmet_language_server",
        "ts_ls",  -- TypeScript/JavaScript
        "clangd",  -- C/C++
        "rust_analyzer",  -- Rust
      },
      automatic_installation = true,
      handlers = {
        -- Default handler for any installed server
        function(server)
          require("lspconfig")[server].setup({})
        end,

        -- Server-specific configs
        ["lua_ls"] = function()
          require("lspconfig").lua_ls.setup({
            settings = {
              Lua = {
                diagnostics = { globals = { "vim" } },
                workspace = { checkThirdParty = false },
              },
            },
          })
        end,

        ["gopls"] = function()
          require("lspconfig").gopls.setup({
            settings = {
              gopls = {
                analyses = { unusedparams = true },
                staticcheck = true,
              },
            },
          })
        end,

        ["pyright"] = function()
          require("lspconfig").pyright.setup({})
        end,

        ["emmet_language_server"] = function()
          require("lspconfig").emmet_language_server.setup({
            filetypes = {
              "html",
              "css",
              "scss",
              "sass",
              "javascriptreact",
              "typescriptreact",
              "vue",
              "svelte",
            },
          })
        end,

        ["ts_ls"] = function()
          require("lspconfig").ts_ls.setup({})
        end,

        ["clangd"] = function()
          require("lspconfig").clangd.setup({})
        end,

        ["rust_analyzer"] = function()
          require("lspconfig").rust_analyzer.setup({})
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

