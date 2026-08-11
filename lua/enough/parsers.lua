---@mod enough.parsers Which treesitter parsers a working setup needs.
---
--- nvim-treesitter's `main` branch installs nothing on its own, so this is the
--- single place that decides what a working setup needs. It is shared by the
--- plugin spec (which installs in the background at startup) and by the
--- installer and CI (which need to block until it is done).

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

--- Wanted parsers that this nvim-treesitter supports but has not installed.
---
--- Filtering against the supported list keeps a parser that upstream renames
--- or drops from turning into a warning on every startup.
---@return string[]
function M.missing()
  local config = require("nvim-treesitter.config")

  local installed, available = {}, {}
  for _, lang in ipairs(config.get_installed()) do
    installed[lang] = true
  end
  for _, lang in ipairs(config.get_available()) do
    available[lang] = true
  end

  return vim.tbl_filter(function(lang)
    return available[lang] and not installed[lang]
  end, M.wanted())
end

--- Install whatever is missing.
---
--- Asynchronous by default so startup is never blocked. Pass `wait` to block,
--- which is what the installer and CI want.
---@param opts? { wait?: integer } milliseconds to block for
---@return boolean ok
---@return string[] attempted
function M.install(opts)
  opts = opts or {}
  local missing = M.missing()
  if #missing == 0 then
    return true, missing
  end

  -- Without the CLI, nvim-treesitter's `main` branch installs nothing and
  -- reports success, so say so rather than leaving the user with a config that
  -- looks fine and highlights nothing.
  if vim.fn.executable("tree-sitter") == 0 then
    vim.schedule(function()
      vim.notify(
        "nvim-enough: tree-sitter CLI not found, so no parsers can be installed.\n"
          .. "Install it with `brew install tree-sitter-cli` (the `tree-sitter` formula is the library, not the CLI).",
        vim.log.levels.WARN
      )
    end)
    return false, missing
  end

  local task = require("nvim-treesitter").install(missing)
  if not opts.wait then
    return true, missing
  end

  local ok = pcall(function()
    task:wait(opts.wait)
  end)
  return ok, missing
end

return M
