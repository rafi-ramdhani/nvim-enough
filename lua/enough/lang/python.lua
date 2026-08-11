-- Python.
--
-- pyright for types, ruff for formatting and lint fixes.
---@type enough.LanguagePack
return {
  servers = {
    pyright = {
      settings = {
        python = {
          analysis = { typeCheckingMode = "basic" },
        },
      },
    },
  },

  tools = { "ruff" },

  parsers = { "python" },

  formatters = {
    python = { "ruff_organize_imports", "ruff_format" },
  },
}
