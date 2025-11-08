-- Load core settings first
require("mycfg.settings")

-- Then keymaps
require("mycfg.mappings")

-- Then plugins (bootstrap + plugin specs)
require("mycfg.plugins")

-- Optional: environment or language-specific plugin sets
require("mycfg.devselect")

-- Optional: autocommands if you want them separate
pcall(require, "mycfg.autocmds")

