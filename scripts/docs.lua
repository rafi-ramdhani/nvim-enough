-- Keymap documentation check.
--
-- The original complaint about this config was that it was poorly documented,
-- and the concrete form of that was ~25 keymaps with nothing describing them.
-- Documentation drifts the moment nobody checks it, so this checks it: every
-- <leader> mapping in the README must exist, and every <leader> mapping that
-- exists must be in the README.
--
--   nvim --headless -c "luafile scripts/docs.lua" -c "qa!"

local fail = 0

--- Every <leader> mapping the running config actually defines.
---@return table<string, string> lhs -> description
local function defined()
  local leader = vim.g.mapleader or " "
  local found = {}
  for _, mode in ipairs({ "n", "v", "x", "o" }) do
    for _, m in ipairs(vim.api.nvim_get_keymap(mode)) do
      if m.lhs:sub(1, #leader) == leader and not m.lhs:match("^<Plug>") then
        found["<leader>" .. m.lhs:sub(#leader + 1)] = m.desc or ""
      end
    end
  end
  return found
end

--- Every <leader> mapping mentioned in the README, in backticks.
---@return table<string, boolean>
local function documented()
  local path = vim.fn.stdpath("config") .. "/README.md"
  local found = {}
  for _, line in ipairs(vim.fn.readfile(path)) do
    for token in line:gmatch("`(<leader>[^`]+)`") do
      -- A cell may hold several keys, e.g. `<leader>lc` / `<leader>lC`.
      for key in (token .. " "):gmatch("(<leader>%S-)[%s/]") do
        found[key] = true
      end
      found[token] = true
    end
  end
  return found
end

local have = defined()
local docs = documented()

local undocumented, missing = {}, {}

for lhs in pairs(have) do
  if not docs[lhs] then
    undocumented[#undocumented + 1] = lhs
  end
end
for lhs in pairs(docs) do
  if not have[lhs] then
    missing[#missing + 1] = lhs
  end
end

table.sort(undocumented)
table.sort(missing)

io.write(("defined: %d   documented: %d\n\n"):format(vim.tbl_count(have), vim.tbl_count(docs)))

if #undocumented > 0 then
  fail = fail + 1
  io.write("Defined but not in the README:\n")
  for _, lhs in ipairs(undocumented) do
    io.write(("  %-16s %s\n"):format(lhs, have[lhs]))
  end
  io.write("\n")
end

if #missing > 0 then
  fail = fail + 1
  io.write("In the README but not defined:\n")
  for _, lhs in ipairs(missing) do
    io.write("  " .. lhs .. "\n")
  end
  io.write("\n")
end

-- A mapping with no description is invisible to :map and to which-key, which
-- is the same problem in a different place.
local nodesc = {}
for lhs, desc in pairs(have) do
  if desc == "" then
    nodesc[#nodesc + 1] = lhs
  end
end
table.sort(nodesc)
if #nodesc > 0 then
  fail = fail + 1
  io.write("Defined with no description:\n")
  for _, lhs in ipairs(nodesc) do
    io.write("  " .. lhs .. "\n")
  end
  io.write("\n")
end

if fail > 0 then
  io.write("FAIL: keymap documentation is out of date\n")
  vim.cmd("cquit 1")
end
io.write("OK\n")
