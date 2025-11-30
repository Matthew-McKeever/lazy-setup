-- Detect which development environment to load.
-- You can drive this by an environment variable or by the current directory.

local devmode = vim.env.DEV_MODE or ""  -- e.g. export DEV_MODE=python

-- helper to pull in plugin lists
local function add_plugins(mod)
  local ok, plugins = pcall(require, mod)
  if not ok then return end
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then return end
  for _, p in ipairs(plugins) do
    lazy.add(p)
  end
end

-- Option 1: explicit environment variable
if devmode == "python" then
  add_plugins("mycfg.plugins.dev.python")
elseif devmode == "go" then
  add_plugins("mycfg.plugins.dev.go")
elseif devmode == "web" then
  add_plugins("mycfg.plugins.dev.web")
elseif devmode == "cpp" then
  add_plugins("mycfg.plugins.dev.cpp")
end

-- Option 2: automatic detection by project folder name
if devmode == "" then
  local cwd = vim.loop.cwd()
  if cwd:match("python") or vim.fn.glob("**/requirements%.txt") ~= "" then
    add_plugins("mycfg.plugins.dev.python")
  elseif cwd:match("go") or vim.fn.glob("**/go%.mod") ~= "" then
    add_plugins("mycfg.plugins.dev.go")
  elseif cwd:match("web") or vim.fn.glob("**/package%.json") ~= "" then
    add_plugins("mycfg.plugins.dev.web")
  end
end

