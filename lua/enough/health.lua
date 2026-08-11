---@mod enough.health `:checkhealth enough`
---
--- Reports what nvim-enough needs and whether it is actually there. The
--- failures worth catching here are the quiet ones: a missing tree-sitter CLI
--- means no highlighting at all, and nothing else says so.

local health = vim.health

local M = {}

--- Tools the config needs, and what breaks without each.
local TOOLS = {
  {
    cmd = "git",
    what = "cloning, gitsigns and fugitive",
    brew = "git",
  },
  {
    cmd = "rg",
    what = "telescope live grep",
    brew = "ripgrep",
  },
  {
    cmd = "fd",
    what = "telescope file finding",
    brew = "fd",
    optional = true,
  },
  {
    cmd = "tree-sitter",
    what = "building treesitter parsers",
    -- Named explicitly: the `tree-sitter` formula is the library, and
    -- installing it instead leaves parsers failing silently.
    brew = "tree-sitter-cli",
  },
}

local function check_version()
  health.start("Neovim")
  if vim.fn.has("nvim-0.12") == 1 then
    health.ok(("Neovim %s"):format(tostring(vim.version())))
  else
    health.error(("Neovim %s is too old; nvim-enough needs 0.12 or newer"):format(tostring(vim.version())), {
      "nvim-treesitter's main branch calls vim.list.unique(), added in 0.12.",
      "Upgrade with `brew upgrade neovim`.",
    })
  end
end

local function check_tools()
  health.start("External tools")

  for _, tool in ipairs(TOOLS) do
    if vim.fn.executable(tool.cmd) == 1 then
      health.ok(("%s — %s"):format(tool.cmd, tool.what))
    elseif tool.optional then
      health.warn(("%s not found — %s will be slower"):format(tool.cmd, tool.what), {
        ("Install with `brew install %s`."):format(tool.brew),
      })
    else
      health.error(("%s not found — %s will not work"):format(tool.cmd, tool.what), {
        ("Install with `brew install %s`."):format(tool.brew),
      })
    end
  end

  local compiler = vim.fn.executable("cc") == 1 or vim.fn.executable("gcc") == 1 or vim.fn.executable("clang") == 1
  if compiler then
    health.ok("C compiler — building parsers and telescope-fzf-native")
  else
    health.error("no C compiler found", {
      "macOS: xcode-select --install",
      "Linux: install build-essential or equivalent",
    })
  end
end

local function check_languages()
  health.start("Language packs")

  local config = require("enough.config")
  local lang = require("enough.lang")
  local enabled = config.options.languages
  local packs = lang.packs()

  health.info("available: " .. table.concat(lang.available(), ", "))

  if #enabled == 0 then
    health.warn("no language packs enabled", {
      "You will get editing and git, but no LSP, formatting or language parsers.",
      "Set `languages` in lua/user/init.lua. See user.example/init.lua.",
    })
    return
  end

  for _, name in ipairs(enabled) do
    if packs[name] then
      local pack = packs[name]
      local servers = vim.tbl_keys(pack.servers or {})
      table.sort(servers)
      health.ok(("%s — %s"):format(name, #servers > 0 and table.concat(servers, ", ") or "no server"))
    else
      health.error(("%s is not a language pack"):format(name), {
        "Available: " .. table.concat(lang.available(), ", "),
      })
    end
  end
end

local function check_parsers()
  health.start("Treesitter parsers")

  local ok, config = pcall(require, "nvim-treesitter.config")
  if not ok then
    health.warn("nvim-treesitter is not loaded yet; re-run after it starts")
    return
  end

  local installed = {}
  for _, lang in ipairs(config.get_installed()) do
    installed[lang] = true
  end

  local wanted = require("enough.parsers").wanted()
  local missing = vim.tbl_filter(function(lang)
    return not installed[lang]
  end, wanted)

  if #missing == 0 then
    health.ok(("all %d wanted parsers installed"):format(#wanted))
  else
    health.warn(("%d of %d parsers missing: %s"):format(#missing, #wanted, table.concat(missing, ", ")), {
      vim.fn.executable("tree-sitter") == 1 and "Run `:TSInstall " .. table.concat(missing, " ") .. "`."
        or "Install the CLI first: `brew install tree-sitter-cli`.",
    })
  end
end

local function check_user_config()
  health.start("Your configuration")

  local path = vim.fn.stdpath("config") .. "/lua/user/init.lua"
  if vim.fn.filereadable(path) == 1 then
    health.ok("lua/user/init.lua — your settings, never touched by `git pull`")
  else
    health.info("no lua/user/init.lua yet; defaults are in use", {
      "Copy the template with `cp -r user.example lua/user`.",
    })
  end

  local ok, lazy = pcall(require, "lazy")
  if ok then
    health.info(("%d plugins loaded"):format(#lazy.plugins()))
  end
end

function M.check()
  check_version()
  check_tools()
  check_languages()
  check_parsers()
  check_user_config()
end

return M
