return {
  ---------------------------------------------------------------------------
  -- Better Lua dev (Neovim-aware completion, types, etc.)
  ---------------------------------------------------------------------------
  {
    "folke/neodev.nvim",
    ft = "lua",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      local ok, neodev = pcall(require, "neodev")
      if not ok then
        return
      end

      neodev.setup({
        -- uses sane defaults; integrates with lua_ls / sumneko_lua
      })

      -- If you configure lua_ls in a central LSP file, make sure it uses neodev:
      -- require("lspconfig").lua_ls.setup(require("neodev").lua_ls())
      -- but keep that in your global LSP config, not here.
    end,
  },

  ---------------------------------------------------------------------------
  -- Lua debugger (nvim-dap + one-small-step-for-vimkind)
  ---------------------------------------------------------------------------
  {
    "jbyuki/one-small-step-for-vimkind",
    ft = "lua",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local ok_dap, dap = pcall(require, "dap")
      if not ok_dap then
        return
      end

      dap.adapters.nlua = function(callback, config)
        callback({
          type = "server",
          host = config.host or "127.0.0.1",
          port = config.port or 8086,
        })
      end

      dap.configurations.lua = {
        {
          type = "nlua",
          request = "attach",
          name = "Attach to running Neovim instance",
          host = function()
            return "127.0.0.1"
          end,
          port = function()
            return 8086
          end,
        },
      }
    end,
  },

  ---------------------------------------------------------------------------
  -- Small Lua niceties: reload current module quickly
  ---------------------------------------------------------------------------
  {
    "nvim-lua/plenary.nvim",
    ft = "lua",
    config = function()
      -- Simple keymap to reload current Lua file/module
      vim.keymap.set("n", "<leader>lr", function()
        local file = vim.fn.expand("%:p")
        if not file:match("%.lua$") then
          return
        end

        -- Convert path to module name (very naive, but fine for user config)
        local config_path = vim.fn.stdpath("config")
        local module = file
          :gsub("^" .. config_path .. "/lua/", "")
          :gsub("%.lua$", "")
          :gsub("/", ".")

        package.loaded[module] = nil
        require(module)
        vim.notify("Reloaded Lua module: " .. module)
      end, { desc = "Reload current Lua module" })
    end,
  },
}

