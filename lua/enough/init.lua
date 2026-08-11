---@mod enough nvim-enough: a Neovim configuration that is just enough.

local M = {}

--- Load the configuration.
---
--- Order matters: the user overlay is read first because everything else
--- consults it, and options run before lazy.nvim because the leader key must
--- be set before any plugin defines a mapping against it.
function M.setup()
  require("enough.config").load()
  require("enough.options")
  require("enough.lazy").setup()
  require("enough.keymaps")
  require("enough.autocmds")
end

return M
