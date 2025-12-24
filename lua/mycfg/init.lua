-- Load core settings first
require("mycfg.settings")

-- Then plugins (bootstrap + plugin specs)
require("mycfg.plugins")

-- Then keymaps (after plugins to avoid being overridden)
require("mycfg.mappings")

-- Optional: environment or language-specific plugin sets
require("mycfg.devselect")

-- Optional: autocommands if you want them separate
pcall(require, "mycfg.autocmds")


