---@mod enough nvim-enough: a Neovim configuration that is just enough.

local M = {}

--- Oldest Neovim this config supports. nvim-treesitter's `main` branch calls
--- `vim.list.unique()`, which does not exist before 0.12.
local MIN_VERSION = "nvim-0.12"

--- Fail loudly rather than half-loading on an unsupported Neovim.
---@return boolean
local function supported()
  if vim.fn.has(MIN_VERSION) == 1 then
    return true
  end
  vim.schedule(function()
    vim.api.nvim_echo({
      { "nvim-enough requires Neovim 0.12 or newer.\n", "ErrorMsg" },
      { ("You are running %s.\n"):format(tostring(vim.version())), "WarningMsg" },
      { "Upgrade with `brew upgrade neovim`, or see the README.", "None" },
    }, true, {})
  end)
  return false
end

--- Load the configuration.
---
--- Order matters: the user overlay is read first because everything else
--- consults it, and options run before lazy.nvim because the leader key must
--- be set before any plugin defines a mapping against it.
function M.setup()
  if not supported() then
    return
  end

  require("enough.config").load()
  require("enough.options")
  require("enough.lazy").setup()
  require("enough.keymaps")
  require("enough.autocmds")
  -- Anything a language pack needs that is not data, such as filetype-local
  -- mappings. Runs last so packs can rely on everything else existing.
  require("enough.lang").setup()
end

return M
