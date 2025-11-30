return {
  -- Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp", -- or "main" depending on the version you use
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
    dependencies = {
      "mfussenegger/nvim-dap",
      "linux-cultist/venv-selector.nvim",
    },
    ft = { "python" },
    config = function()
      local ok_venv, venv_selector = pcall(require, "venv-selector")
      local path

      if ok_venv and venv_selector.venv then
        path = venv_selector.venv()
      end

      -- fallback if no venv selected
      if not path or path == "" then
        path = vim.fn.expand("~/.virtualenvs/debugpy/bin/python")
      end

      require("dap-python").setup(path)
    end,
  },

  -- Testing framework (neotest + neotest-python)
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "python" },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-python")({
            dap = { justMyCode = false },
            runner = "pytest",
          }),
        },
      })
    end,
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
      local ok, null_ls = pcall(require, "null-ls")
      if not ok then
        return
      end

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

