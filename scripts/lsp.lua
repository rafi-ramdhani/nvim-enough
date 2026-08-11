-- End-to-end language server test.
--
-- Everything else in scripts/ checks configuration. This checks the thing
-- users actually care about: that mason installs a server, it attaches to a
-- real file, and it answers a real question about real code.
--
-- It is slow, because it downloads language servers. It runs nightly rather
-- than on every pull request.
--
--   nvim --headless -c "luafile scripts/lsp.lua" -c "qa!"
--
-- Only languages that are enabled *and* have a fixture below are exercised.

local fail = 0
local function check(label, ok, detail)
  io.write(("  %-48s %s%s\n"):format(label, ok and "PASS" or "FAIL", detail and ("  " .. detail) or ""))
  if not ok then
    fail = fail + 1
  end
end

--- Each fixture proves something semantic — a type inferred, or an error found
--- — because a server that merely connects is not evidence of anything.
local FIXTURES = {
  lua = {
    package = "lua-language-server",
    server = "lua_ls",
    file = "main.lua",
    lines = {
      "local greeting = 'hello'",
      "local upper = greeting:upper()",
      "print(upper)",
    },
    -- lua_ls should infer `string` from the assignment.
    hover = { row = 2, col = 15, expect = "string" },
  },

  python = {
    package = "pyright",
    server = "pyright",
    file = "main.py",
    lines = {
      "def greet(name: str) -> str:",
      '    return "hello " + name',
      "",
      "result = greet(123)",
    },
    -- Passing an int where a str is declared is a real type error.
    diagnostic = "cannot be assigned",
  },
}

--- Install a mason package, blocking until it is done.
---@param name string
---@return boolean
local function install(name)
  local registry = require("mason-registry")
  local pending = true

  registry.refresh(function()
    local ok, pkg = pcall(registry.get_package, name)
    if not ok then
      pending = false
      return
    end
    if pkg:is_installed() then
      pending = false
      return
    end
    pkg:install():once("closed", function()
      pending = false
    end)
  end)

  vim.wait(900000, function()
    return not pending
  end, 500)

  local ok, pkg = pcall(registry.get_package, name)
  return ok and pkg:is_installed()
end

--- Open a fixture file in its own project directory and wait for a client.
---@param fixture table
---@return vim.lsp.Client?, integer
local function attach(fixture)
  local root = vim.fn.tempname()
  -- A root marker, or the server correctly declines to pick a workspace.
  vim.fn.mkdir(root .. "/.git", "p")
  local path = root .. "/" .. fixture.file
  vim.fn.writefile(fixture.lines, path)

  vim.cmd.edit(path)
  local buf = vim.api.nvim_get_current_buf()

  vim.wait(120000, function()
    return #vim.lsp.get_clients({ bufnr = buf }) > 0
  end, 250)

  return vim.lsp.get_clients({ bufnr = buf })[1], buf
end

---@param client vim.lsp.Client
---@param buf integer
---@param fixture table
local function check_hover(client, buf, fixture)
  vim.api.nvim_win_set_cursor(0, { fixture.hover.row, fixture.hover.col })

  local text
  -- Servers answer before they have finished indexing, replying "Workspace
  -- loading" and nothing useful, so poll until a real answer arrives.
  vim.wait(120000, function()
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    local res = vim.lsp.buf_request_sync(buf, "textDocument/hover", params, 15000)
    for _, r in pairs(res or {}) do
      if r.result and r.result.contents then
        local c = r.result.contents
        local value = type(c) == "table" and (c.value or c[1]) or c
        if value and not tostring(value):match("Workspace loading") then
          text = tostring(value)
          return true
        end
      end
    end
    return false
  end, 2000)

  local found = text ~= nil and text:find(fixture.hover.expect, 1, true) ~= nil
  check("hover reports " .. fixture.hover.expect, found, text and text:gsub("%s+", " "):sub(1, 60) or "no answer")
end

---@param buf integer
---@param fixture table
local function check_diagnostic(buf, fixture)
  local diags = {}
  vim.wait(120000, function()
    diags = vim.diagnostic.get(buf)
    return #diags > 0
  end, 1000)

  local matched = false
  for _, d in ipairs(diags) do
    if d.message:find(fixture.diagnostic, 1, true) then
      matched = true
    end
  end
  check("reports the expected type error", matched, diags[1] and diags[1].message:gsub("\n.*", ""):sub(1, 60) or "none")
end

-- ---------------------------------------------------------------------------

local enabled = require("enough.config").options.languages
io.write("languages: " .. table.concat(enabled, ", ") .. "\n\n")

local ran = 0
for _, language in ipairs(enabled) do
  local fixture = FIXTURES[language]
  if fixture then
    ran = ran + 1
    io.write(("%s (%s)\n"):format(language, fixture.server))

    check("mason installed " .. fixture.package, install(fixture.package))

    local client, buf = attach(fixture)
    check("server attached", client ~= nil, client and client.name or "none")

    if client then
      check("it is " .. fixture.server, client.name == fixture.server, client.name)

      -- The capability that a dead mason-lspconfig handler used to drop.
      local snippet =
        vim.tbl_get(client.config.capabilities or {}, "textDocument", "completion", "completionItem", "snippetSupport")
      check("live client advertises snippetSupport", snippet == true, "got " .. tostring(snippet))

      if fixture.hover then
        check_hover(client, buf, fixture)
      end
      if fixture.diagnostic then
        check_diagnostic(buf, fixture)
      end
    end
    io.write("\n")
  end
end

if ran == 0 then
  io.write("no enabled language has a fixture; nothing to prove\n")
  vim.cmd("cquit 1")
end

if fail > 0 then
  io.write(("%d CHECK(S) FAILED\n"):format(fail))
  vim.cmd("cquit 1")
end
io.write("ALL CHECKS PASSED\n")
