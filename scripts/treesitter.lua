-- Treesitter regression test.
--
-- This config shipped for a while with zero parsers and no highlighting,
-- because nvim-treesitter's setup() silently ignored the options it was given.
-- Nothing complained. This is the check that would have caught it.
--
--   nvim --headless -c "luafile scripts/treesitter.lua" -c "qa!"

local fail = 0
local function check(label, ok, detail)
  io.write(("%-50s %s%s\n"):format(label, ok and "PASS" or "FAIL", detail and ("  " .. detail) or ""))
  if not ok then
    fail = fail + 1
  end
end

io.write("nvim: " .. tostring(vim.version()) .. "\n")

if vim.fn.executable("tree-sitter") == 0 then
  io.write("tree-sitter CLI missing; cannot build parsers\n")
  vim.cmd("cquit 1")
end

local ok, attempted = require("enough.parsers").install({ wait = 900000 })
io.write(("install: ok=%s attempted=%d\n"):format(tostring(ok), #attempted))

local installed = require("nvim-treesitter.config").get_installed()
table.sort(installed)
io.write(("installed (%d): %s\n\n"):format(#installed, table.concat(installed, ", ")))

check("parsers installed", #installed > 0, "count " .. #installed)

--- Open a buffer of `ft` and report whether treesitter highlighting attached.
local function highlights(ft, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = ft
  vim.wait(500)
  return vim.treesitter.highlighter.active[buf] ~= nil
end

-- bash and yaml are not bundled with Neovim, so these can only pass if a
-- parser was really installed and highlighting really started.
check("highlighter attaches for bash", highlights("sh", { "x=1", "echo $x" }))
check("highlighter attaches for yaml", highlights("yaml", { "a: 1" }))

io.write("\n")
if fail > 0 then
  io.write(("%d CHECK(S) FAILED\n"):format(fail))
  vim.cmd("cquit 1")
end
io.write("ALL CHECKS PASSED\n")
