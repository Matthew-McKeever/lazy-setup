-- Leaders must be set before anything else touches keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- If you use nvim-tree, kill netrw early to avoid dumb conflicts
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Load your real config from lua/mycfg/*
local ok, err = pcall(require, "mycfg")
if not ok then
  vim.notify("Failed to load mycfg: " .. tostring(err), vim.log.levels.ERROR)
end

