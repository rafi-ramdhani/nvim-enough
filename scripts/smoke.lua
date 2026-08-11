-- Boot smoke test.
--
-- Catches the failure mode this config has actually suffered twice: a plugin
-- API changing underneath it, leaving something silently doing nothing.
--
--   nvim --headless -u init.lua -c "luafile scripts/smoke.lua" -c "qa!"

local fail = 0
local function check(label, ok, detail)
  io.write(("%-52s %s%s\n"):format(label, ok and "PASS" or "FAIL", detail and ("  " .. detail) or ""))
  if not ok then
    fail = fail + 1
  end
end

--- pcall returns (ok, value); only the first is wanted here.
---@param module string
---@return boolean
local function loads(module)
  return (pcall(require, module))
end

-- 1. The config loaded at all.
check("enough.config loaded", loads("enough.config"))
check("enough.lang loaded", loads("enough.lang"))
check("enough.parsers loaded", loads("enough.parsers"))

-- 2. lazy.nvim resolved the spec.
local ok_lazy, lazy = pcall(require, "lazy")
check("lazy.nvim available", ok_lazy == true)
if ok_lazy then
  check("plugins resolved", #lazy.plugins() > 0, ("%d"):format(#lazy.plugins()))
end

-- 3. Every shipped language pack is well formed. A typo here would otherwise
--    only surface for whoever enabled that one language.
local lang = require("enough.lang")
for _, name in ipairs(lang.available()) do
  local ok, pack = pcall(require, "enough.lang." .. name)
  local valid = ok
    and type(pack) == "table"
    and (pack.servers == nil or type(pack.servers) == "table")
    and (pack.tools == nil or vim.islist(pack.tools))
    and (pack.parsers == nil or vim.islist(pack.parsers))
    and (pack.formatters == nil or type(pack.formatters) == "table")
    and (pack.setup == nil or type(pack.setup) == "function")
  check("pack is well formed: " .. name, valid)
end

-- 4. Defaults must be language-agnostic apart from lua.
local config = require("enough.config")
check("default languages are { lua }", vim.deep_equal(config.defaults().languages, { "lua" }))

-- 5. Nothing language-specific may leak into global mappings.
local global = {}
for _, mode in ipairs({ "n", "v", "x" }) do
  for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
    global[m.lhs] = true
  end
end
check("no global JSX mapping", global[" xc"] == nil)
check("no global console.log mapping", global[" cl"] == nil)

-- 6. Health check must be reachable, since it is what users are told to run.
check("checkhealth module loads", loads("enough.health"))

io.write("\n")
if fail > 0 then
  io.write(("%d CHECK(S) FAILED\n"):format(fail))
  vim.cmd("cquit 1")
end
io.write("ALL CHECKS PASSED\n")
