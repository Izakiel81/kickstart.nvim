-- Set leader keys FIRST (before anything else)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Load core config
require 'core.options'
require 'core.keymaps'
require 'core.autocmds'

require 'custom.plugins'

-- Diagnostics config (after plugins are loaded)
vim.diagnostic.config {
  virtual_text = true,
  signs = true,
  update_in_insert = false,
}
