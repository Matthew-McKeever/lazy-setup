-- Bootstrap lazy.nvim if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

-- Load lazy
require("lazy").setup(spec, {
  ui = { border = "rounded" },
  checker = { enabled = false },  -- disable auto-update spam
})

