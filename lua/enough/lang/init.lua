---@mod enough.lang Opt-in language packs.
---
--- A pack is data, not code: it names the language server, the tools mason
--- should install, the treesitter parsers and the formatters for one language.
--- The core reads only the packs a user enabled, so nothing loads for
--- languages they do not write.

local M = {}

---@class enough.LanguagePack
---@field servers? table<string, table> Language servers, keyed by lspconfig name.
---@field tools? string[] Extra mason packages: formatters, linters.
---@field parsers? string[] Treesitter parsers.
---@field formatters? table<string, string[]> conform's `formatters_by_ft`.
---@field setup? fun() Anything that is not data, such as filetype keymaps.

---@type table<string, enough.LanguagePack>?
local cache

--- Load every enabled pack, warning once about names that do not exist.
---@return table<string, enough.LanguagePack>
function M.packs()
  if cache then
    return cache
  end

  cache = {}
  local unknown = {}

  for _, name in ipairs(require("enough.config").options.languages) do
    local ok, pack = pcall(require, "enough.lang." .. name)
    if ok and type(pack) == "table" then
      cache[name] = pack
    else
      unknown[#unknown + 1] = name
    end
  end

  if #unknown > 0 then
    vim.schedule(function()
      vim.notify(
        ("nvim-enough: unknown language pack(s): %s\nAvailable: %s"):format(
          table.concat(unknown, ", "),
          table.concat(M.available(), ", ")
        ),
        vim.log.levels.WARN
      )
    end)
  end

  return cache
end

--- Every pack that ships with nvim-enough.
---@return string[]
function M.available()
  local dir = vim.fn.stdpath("config") .. "/lua/enough/lang"
  local names = {}
  for _, path in ipairs(vim.fn.glob(dir .. "/*.lua", false, true)) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    if name ~= "init" then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end

--- Language servers contributed by enabled packs.
---@return table<string, table>
function M.servers()
  local servers = {}
  for _, pack in pairs(M.packs()) do
    for name, opts in pairs(pack.servers or {}) do
      servers[name] = opts
    end
  end
  return servers
end

--- Extra mason packages contributed by enabled packs.
---@return string[]
function M.tools()
  local tools = {}
  for _, pack in pairs(M.packs()) do
    vim.list_extend(tools, pack.tools or {})
  end
  return require("enough.util").uniq(tools)
end

--- Treesitter parsers contributed by enabled packs.
---@return string[]
function M.parsers()
  local parsers = {}
  for _, pack in pairs(M.packs()) do
    vim.list_extend(parsers, pack.parsers or {})
  end
  return require("enough.util").uniq(parsers)
end

--- conform's `formatters_by_ft`, contributed by enabled packs.
---@return table<string, string[]>
function M.formatters()
  local formatters = {}
  for _, pack in pairs(M.packs()) do
    for ft, list in pairs(pack.formatters or {}) do
      formatters[ft] = list
    end
  end
  return formatters
end

--- Run the non-data part of each pack, if it has one.
function M.setup()
  for _, pack in pairs(M.packs()) do
    if type(pack.setup) == "function" then
      pack.setup()
    end
  end
end

return M
