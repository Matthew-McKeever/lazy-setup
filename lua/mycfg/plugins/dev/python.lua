return {
  -- Virtual environment selector
  {
    "linux-cultist/venv-selector.nvim",
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

        -- Check if the debugpy path exists, otherwise use system python
        if vim.fn.executable(path) == 0 then
          path = vim.fn.exepath("python3") or vim.fn.exepath("python")
          if path == "" then
            vim.notify("No Python interpreter found for dap-python", vim.log.levels.WARN)
            return
          end
        end
      end

      require("dap-python").setup(path)
    end,
  },

  -- Testing framework (neotest + neotest-python)
  -- Note: Same keybindings as web.lua but won't conflict due to filetype-specific loading
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

      -- Only add sources for tools that are actually installed
      local sources = {}

      if vim.fn.executable("black") == 1 then
        table.insert(sources, null_ls.builtins.formatting.black)
      end

      if vim.fn.executable("isort") == 1 then
        table.insert(sources, null_ls.builtins.formatting.isort)
      end

      if vim.fn.executable("flake8") == 1 then
        table.insert(sources, null_ls.builtins.diagnostics.flake8)
      end

      -- Only setup if we have at least one source
      if #sources > 0 then
        null_ls.setup({ sources = sources })
      end
    end,
  },
}

