local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- File explorer
map("n", "<leader>e", ":NvimTreeToggle<CR>", opts)

-- Save / quit shortcuts
map("n", "<leader>w", ":w<CR>", opts)
map("n", "<leader>q", ":confirm q<CR>", opts)  -- confirm prompts if unsaved changes
map("n", "<leader>Q", ":q!<CR>", opts)  -- force quit without saving

-- Clear search highlight
map("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Better window navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Telescope shortcuts
map("n", "<leader>ff", ":Telescope find_files<CR>", opts)
map("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
map("n", "<leader>fb", ":Telescope buffers<CR>", opts)
map("n", "<leader>fh", ":Telescope help_tags<CR>", opts)

