return {
  -- Auto-close/rename HTML, JSX/TSX tags
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "xml", "javascriptreact", "typescriptreact", "svelte", "vue" },
    opts = { enable_close = true, enable_rename = true, enable_close_on_slash = true },
  },

  -- Correct comment syntax per context (JSX, TSX, Vue, etc.)
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact", "tsx", "jsx", "vue", "svelte", "html", "css", "scss" },
    config = function()
      -- integrate with Comment.nvim if you're using it in core.lua
      local ok, comment = pcall(require, "Comment")
      if ok then
        comment.setup({
          pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
      else
        require("ts_context_commentstring").setup({})
      end
    end,
  },

  -- Color previews in CSS/JSX/Tailwind classes
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "css", "scss", "sass", "less", "html", "javascriptreact", "typescriptreact", "vue", "svelte" },
    opts = { user_default_options = { names = false } },
  },

  -- Formatting + linting via none-ls (prettier, eslint)
  {
    "nvimtools/none-ls.nvim",
    name = "null-ls",
    ft = {
      "javascript", "javascriptreact", "typescript", "typescriptreact",
      "vue", "svelte", "html", "css", "scss", "json", "yaml", "markdown",
    },
    config = function()
      local null = require("null-ls")
      null.setup({
        sources = {
          -- Formatter
          null.builtins.formatting.prettier,
          -- Linter + code actions (fast daemonized version)
          null.builtins.diagnostics.eslint_d,
          null.builtins.code_actions.eslint_d,
        },
      })
    end,
  },

  -- Optional: Emmet (snippets/expansions for HTML/JSX)
  {
    "olrtg/emmet-language-server",
    ft = { "html", "css", "sass", "scss", "javascriptreact", "typescriptreact", "vue", "svelte" },
    config = function()
      -- use new Neovim LSP API
      vim.lsp.start(vim.lsp.config("emmet_ls", {}))
    end,
  },
}

