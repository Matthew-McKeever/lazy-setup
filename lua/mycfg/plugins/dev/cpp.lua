-- lua/mycfg/plugins/cpp.lua

return {
  -- Extra goodies for clangd (inlay hints, AST, etc.)
  {
    "p00f/clangd_extensions.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    ft = { "c", "cpp", "objc", "objcpp" },
    opts = {
      inlay_hints = {
        inline = true,
        only_current_line = false,
        show_parameter_hints = true,
        parameter_hints_prefix = "<- ",
        other_hints_prefix = "=> ",
      },
    },
    config = function(_, opts)
      local ok, clangd_ext = pcall(require, "clangd_extensions")
      if not ok then
        return
      end

      clangd_ext.setup({
        -- do NOT reconfigure clangd here; assume you do that centrally via lspconfig + mason
        server = {},
        extensions = {
          inlay_hints = opts.inlay_hints,
        },
      })
    end,
  },

  -- Base DAP (you might already have this globally; if so, you can drop this block)
  {
    "mfussenegger/nvim-dap",
    ft = { "c", "cpp" },
  },

  -- DAP UI for C/C++
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "c", "cpp" },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- CMake integration (if you use CMake; if not, delete this block)
  {
    "Civitasv/cmake-tools.nvim",
    ft = { "c", "cpp", "cmake" },
    opts = {
      cmake_command = "cmake",
      cmake_build_directory = "build",
      cmake_generate_options = { "-DCMAKE_EXPORT_COMPILE_COMMANDS=1" },
    },
    config = function(_, opts)
      require("cmake-tools").setup(opts)
    end,
  },
}

