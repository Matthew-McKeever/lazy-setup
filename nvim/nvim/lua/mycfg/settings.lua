-- Leader key must be set before plugins load
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- General editing behavior
vim.opt.number = true                -- show line numbers
vim.opt.relativenumber = true        -- relative numbers for navigation
vim.opt.mouse = "a"                  -- enable mouse support
vim.opt.clipboard = "unnamedplus"    -- use system clipboard
vim.opt.swapfile = false             -- no swap files
vim.opt.backup = false
vim.opt.undofile = true              -- persistent undo
vim.opt.ignorecase = true            -- case-insensitive search...
vim.opt.smartcase = true             -- ...unless uppercase letters
vim.opt.incsearch = true             -- live search feedback
vim.opt.hlsearch = true              -- highlight search results
vim.opt.wrap = false                 -- don’t soft-wrap lines
vim.opt.scrolloff = 8                -- context above/below cursor

-- Indentation and tabs
vim.opt.expandtab = true             -- convert tabs to spaces
vim.opt.tabstop = 4                  -- number of spaces per tab
vim.opt.shiftwidth = 4               -- number of spaces for indentation
vim.opt.smartindent = true           -- autoindent new lines

-- UI
vim.opt.termguicolors = true         -- full color support
vim.opt.signcolumn = "yes"           -- never shift text due to signs
vim.opt.cursorline = true            -- highlight current line
vim.opt.splitbelow = true            -- horizontal splits open below
vim.opt.splitright = true            -- vertical splits open right
vim.opt.cmdheight = 1                -- keep command line compact
vim.opt.laststatus = 3               -- global statusline

-- Timing
vim.opt.updatetime = 300             -- faster diagnostics and swaps
vim.opt.timeoutlen = 400             -- faster key sequence timeout

-- Files and paths
vim.opt.autoread = true              -- reload files changed outside nvim
vim.opt.hidden = true                -- keep buffers in background

-- Appearance tweaks
vim.opt.colorcolumn = "100"          -- guide for line length
vim.opt.fillchars = { eob = " " }    -- hide ~ at end of buffer
vim.opt.pumheight = 10               -- limit popup menu height

-- Enable better folding (use treesitter later)
vim.opt.foldmethod = "indent"
vim.opt.foldlevel = 99

--set colour scheme
pcall(vim.cmd, "colorscheme wal.vim")
