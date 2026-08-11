---@mod enough.lazy Bootstrap lazy.nvim and assemble the plugin spec.

local M = {}

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

--- Clone lazy.nvim on first run.
local function ensure_lazy()
  if (vim.uv or vim.loop).fs_stat(lazypath) then
    return true
  end

  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "nvim-enough: could not install lazy.nvim\n", "ErrorMsg" },
      { result, "WarningMsg" },
    }, true, {})
    return false
  end
  return true
end

--- User plugins are optional. lazy.nvim raises "No specs found for module" for
--- both a missing *and* an empty directory, so check for actual spec files
--- rather than just the directory.
---@return boolean
local function has_user_plugins()
  local dir = vim.fn.stdpath("config") .. "/lua/user/plugins"
  if vim.fn.isdirectory(dir) ~= 1 then
    return false
  end
  return #vim.fn.glob(dir .. "/*.lua", false, true) > 0
end

function M.setup()
  if not ensure_lazy() then
    return
  end
  vim.opt.rtp:prepend(lazypath)

  local spec = { { import = "enough.plugins" } }
  if has_user_plugins() then
    spec[#spec + 1] = { import = "user.plugins" }
  end

  require("lazy").setup({
    spec = spec,
    change_detection = { enabled = false },
    checker = { enabled = false },
    install = { colorscheme = { require("enough.config").options.colorscheme } },
  })
end

return M
