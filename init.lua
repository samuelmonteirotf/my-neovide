--------------------------------------------------------------------------------
-- Entry point. Bootstrap order matters.
--------------------------------------------------------------------------------

require("config.lazy") -- bootstrap lazy.nvim + LazyVim + plugins
require("config.neovide") -- Neovide GUI tuning (no-op in terminal)
