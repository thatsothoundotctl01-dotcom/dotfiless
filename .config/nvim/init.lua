-- ~/.config/nvim/init.lua
-- Entry point for Neovim 0.12+ : only loads the modules below, in order.

local ok_ui2, ui2 = pcall(require, "vim._core.ui2")
if ok_ui2 then ui2.enable({}) end

-- 1. Core settings (no plugins needed)
require("core.options")
require("core.autocmds")
require("core.keymaps")
require("core.commands")

-- 2. Install / register plugins (must come before any plugin config)
require("plugins.pack")

-- 3. Plugin configs (each file is independent)
require("plugins.colorscheme")
require("plugins.code_runner")
require("plugins.mini")
require("plugins.git")
require("plugins.treesitter")
require("plugins.lsp")
