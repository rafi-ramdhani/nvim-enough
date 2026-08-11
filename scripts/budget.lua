-- Plugin budget.
--
-- "Enough, not everything" is easy to say and easy to erode one convenient
-- plugin at a time. This is the number made enforceable: CI fails if the core
-- plugin count changes, so adding one means editing this file, in a diff a
-- reviewer can see and argue with.
--
-- Raising it is allowed. Raising it silently is not.
--
-- Must run with the user overlay disabled, or someone's own plugins would be
-- counted against the shipped config's budget:
--
--   NVIM_ENOUGH_NO_USER=1 nvim --headless -c "luafile scripts/budget.lua" -c "qa!"

local BUDGET = 19

if require("enough.config").user_enabled() then
  io.write("refusing to measure: set NVIM_ENOUGH_NO_USER=1 so lua/user/ is excluded\n")
  vim.cmd("cquit 2")
end

local plugins = require("lazy").plugins()
local names = {}
for _, plugin in ipairs(plugins) do
  names[#names + 1] = plugin.name
end
table.sort(names)

local count = #names

io.write(("core plugins: %d / budget %d\n"):format(count, BUDGET))
io.write("  " .. table.concat(names, "\n  ") .. "\n")

if count > BUDGET then
  io.write(("\nFAIL: %d plugins exceeds the budget of %d.\n"):format(count, BUDGET))
  io.write("If the new plugin earns its place, raise BUDGET in scripts/budget.lua\n")
  io.write("in the same commit, so the tradeoff is visible in review.\n")
  vim.cmd("cquit 1")
elseif count < BUDGET then
  io.write(("\nNOTE: %d is under the budget of %d. Consider lowering BUDGET.\n"):format(count, BUDGET))
end

io.write("\nOK\n")
