return {
  -- Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp", -- or "main" depending on the version
    dependencies = { "nvim-telescope/telescope.nvim" },
    ft = { "python" },
    opts = {
      name = { "venv", ".venv", "env", ".env" },
      auto_refresh = true,
    },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<CR>", desc = "Select virtualenv" },
      { "<leader>vc", "<cmd>VenvSelectCached<CR>", desc = "Use cached venv" },
    },
  },

  -- Debugger (uses nvim-dap)
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "python" },
    config = function()
      local path = require("venv-selector").venv() or "~/.virtualenvs/debugpy/bin/python"
      require("dap-python").setup(path)
    end,
  },

  -- Testing framework
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "python" },
    opts = {
      adapters = {
        require("neotest-python")({
          dap = { justMyCode = false },
          runner = "pytest",
        }),
      },
    },
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
      { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Open test output" },
    },
  },

  -- Formatting and linting (null-ls / none-ls)
  {
    "nvimtools/none-ls.nvim",
    name = "null-ls",
    ft = { "python" },
    config = function()
      local null_ls = require("null-ls")
      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.black,
          null_ls.builtins.formatting.isort,
          null_ls.builtins.diagnostics.flake8,
        },
      })
    end,
  },
}

