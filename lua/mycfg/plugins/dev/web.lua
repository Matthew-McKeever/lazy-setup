-- lua/mycfg/plugins/dev/web.lua

return {
  ---------------------------------------------------------------------------
  -- TypeScript / JavaScript tools
  ---------------------------------------------------------------------------
  {
    "jose-elias-alvarez/typescript.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    config = function()
      local ok, typescript = pcall(require, "typescript")
      if not ok then
        return
      end

      -- If you configure tsserver in a central LSP file,
      -- this just adds helpers/commands.
      typescript.setup({
        server = {
          -- keep empty to avoid fighting your global LSP config
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Auto-close & rename HTML/JSX/TSX tags
  ---------------------------------------------------------------------------
  {
    "windwp/nvim-ts-autotag",
    ft = {
      "html",
      "xml",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "svelte",
      "vue",
    },
    config = function()
      local ok, autotag = pcall(require, "nvim-ts-autotag")
      if not ok then
        return
      end
      autotag.setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- Jest testing via neotest (JS/TS)
  -- Note: Same keybindings as python.lua but won't conflict due to filetype-specific loading
  ---------------------------------------------------------------------------
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = {
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
    },
    config = function()
      local ok, neotest = pcall(require, "neotest")
      if not ok then
        return
      end

      neotest.setup({
        adapters = {
          require("neotest-jest")({
            -- tweak these per project if needed
            jestCommand = "npm test --",
            jestConfigFile = "jest.config.js",
            env = { CI = true },
            cwd = function()
              return vim.fn.getcwd()
            end,
          }),
        },
      })
    end,
    keys = {
      {
        "<leader>tt",
        function()
          require("neotest").run.run()
        end,
        desc = "Run nearest test (Jest)",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand("%"))
        end,
        desc = "Run file tests (Jest)",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open({ enter = true })
        end,
        desc = "Open test output (Jest)",
      },
    },
  }, 
  {
  "NvChad/nvim-colorizer.lua",
  ft = {
    "css",
    "scss",
    "sass",
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  config = function()
    require("colorizer").setup({
      filetypes = {
        "css",
        "scss",
        "sass",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
      },
      user_default_options = {
        names = false,       -- no “red”, “blue” etc.
        RGB = true,          -- RGB(...) styling
        RRGGBB = true,       -- #RRGGBB hex
        RRGGBBAA = true,
        rgb_fn = true,       -- rgb(), rgba()
        hsl_fn = true,       -- hsl(), hsla()
        mode = "background", -- gives you a clean color block behind the text
      },
    })
  end,
  }
}

