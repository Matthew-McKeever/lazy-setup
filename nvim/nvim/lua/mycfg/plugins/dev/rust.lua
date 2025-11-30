return {
  ---------------------------------------------------------------------------
  -- Rust tools (LSP niceties, inlay hints, code actions, etc.)
  ---------------------------------------------------------------------------
  {
    "simrat39/rust-tools.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
    },
    ft = { "rust" },
    config = function()
      local ok, rust_tools = pcall(require, "rust-tools")
      if not ok then
        return
      end

      rust_tools.setup({
        tools = {
          inlay_hints = {
            auto = true,
            only_current_line = false,
            show_parameter_hints = true,
            parameter_hints_prefix = "<- ",
            other_hints_prefix = "=> ",
          },
        },
        -- Important: don't over-configure the server here if you already have a
        -- central LSP setup for `rust_analyzer`. Let that file own on_attach, etc.
        server = {},
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- Cargo.toml / crates helper
  ---------------------------------------------------------------------------
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local ok, crates = pcall(require, "crates")
      if not ok then
        return
      end

      crates.setup({})

      -- Keymaps only really useful in Cargo.toml, but ft = toml is close enough.
      local map = vim.keymap.set
      local opts = { silent = true }

      map("n", "<leader>rc", crates.open_crates_io, vim.tbl_extend("force", opts, {
        desc = "Crates: open on crates.io",
      }))

      map("n", "<leader>ru", crates.update_crate, vim.tbl_extend("force", opts, {
        desc = "Crates: update crate",
      }))

      map("n", "<leader>rU", crates.update_all_crates, vim.tbl_extend("force", opts, {
        desc = "Crates: update all crates",
      }))

      map("n", "<leader>rv", crates.show_versions_popup, vim.tbl_extend("force", opts, {
        desc = "Crates: show versions",
      }))

      map("n", "<leader>rf", crates.show_features_popup, vim.tbl_extend("force", opts, {
        desc = "Crates: show features",
      }))
    end,
  },
}

