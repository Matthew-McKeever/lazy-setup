return {
  -- Colorscheme
  {
    "dylanaraps/wal.vim"
  },


  -- File icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = {
      view = { width = 35 },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    },
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto",  -- auto-detect from colorscheme
        globalstatus = true,
        section_separators = "",
        component_separators = "",
      },
    },
  },

  -- Buffer line
  {
    "romgrk/barbar.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      animation = true,
      clickable = true,
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Telescope",
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top" },
      },
    },
  },

  -- Syntax highlighting and code folding
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        "lua",
        "python",
        "javascript",
        "typescript",
        "go",
        "bash",
        "json",
        "yaml",
        "html",
        "css",
      },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },

  -- Comment toggling
  { "numToStr/Comment.nvim", opts = {} },

  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
      },
    },
  },
}


