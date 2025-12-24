-- Bootstrap lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Gather plugin specs
local spec = {}
vim.list_extend(spec, require("mycfg.plugins.core"))
vim.list_extend(spec, require("mycfg.plugins.lsp"))
vim.list_extend(spec, require("mycfg.plugins.dev.yuck"))
vim.list_extend(spec, require("mycfg.plugins.dev.go"))
vim.list_extend(spec, require("mycfg.plugins.dev.cpp"))
vim.list_extend(spec, require("mycfg.plugins.dev.python"))
vim.list_extend(spec, require("mycfg.plugins.dev.web"))
vim.list_extend(spec, require("mycfg.plugins.dev.lua"))
vim.list_extend(spec, require("mycfg.plugins.dev.rust"))

-- Load lazy
require("lazy").setup(spec, {
  ui = { border = "rounded" },
  checker = { enabled = false },  -- disable auto-update spam
})

