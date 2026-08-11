---@mod enough.parsers Which treesitter parsers a working setup needs.
---
--- Kept in one place so the plugin spec, the installer and CI all agree on the
--- list, rather than each hard-coding its own copy.

local M = {}

--- Parsers worth having whatever you write: the config itself, git output, and
--- the config and markup formats found in every project. Language-specific
--- parsers come from language packs.
---@type string[]
M.core = {
  "bash",
  "diff",
  "git_rebase",
  "gitcommit",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "query",
  "regex",
  "toml",
  "vim",
  "vimdoc",
  "yaml",
}

--- Every parser the current configuration wants.
---@return string[]
function M.wanted()
  return vim.deepcopy(M.core)
end

--- Wanted parsers that are not installed yet.
---@return string[]
function M.missing()
  local ok, info = pcall(require, "nvim-treesitter.info")
  if not ok then
    return M.wanted()
  end

  local installed = {}
  for _, lang in ipairs(info.installed_parsers()) do
    installed[lang] = true
  end

  return vim.tbl_filter(function(lang)
    return not installed[lang]
  end, M.wanted())
end

--- Install everything missing, blocking until done.
---
--- For the installer and CI. Normal startup lets nvim-treesitter handle it via
--- `ensure_installed`, which does not block the editor.
---@return boolean ok
---@return string[] attempted
function M.install_sync()
  local missing = M.missing()
  if #missing == 0 then
    return true, missing
  end

  local ok = pcall(function()
    require("nvim-treesitter.install").ensure_installed_sync(missing)
  end)
  return ok, missing
end

return M
