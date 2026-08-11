---@mod enough.config Defaults, and the user overlay that sits on top of them.

local M = {}

---@class enough.Config
---@field languages string[] Language packs to enable. See lua/enough/lang/.
---@field colorscheme string Colorscheme applied at startup.
---@field format_on_save boolean Run the configured formatter when writing.

---@type enough.Config
local defaults = {
  -- `lua` is on by default because configuring Neovim *is* editing Lua, so a
  -- bare install can still work on itself.
  languages = { "lua" },
  colorscheme = "tokyonight",
  format_on_save = false,
}

---@type enough.Config
M.options = vim.deepcopy(defaults)

---@return enough.Config
function M.defaults()
  return vim.deepcopy(defaults)
end

--- Merge `lua/user/init.lua` over the defaults, if it exists.
---@return enough.Config
function M.load()
  local ok, user = pcall(require, "user")
  if not ok or type(user) ~= "table" then
    return M.options
  end

  M.options = vim.tbl_deep_extend("force", M.options, user)

  -- Lists are replaced wholesale rather than merged index by index, so a user
  -- can narrow `languages` — including to none at all — instead of only ever
  -- adding to the default.
  if user.languages ~= nil then
    M.options.languages = vim.deepcopy(user.languages)
  end

  return M.options
end

--- True when a language pack is enabled.
---@param name string
---@return boolean
function M.has_language(name)
  return vim.tbl_contains(M.options.languages, name)
end

return M
