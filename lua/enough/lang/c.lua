-- C and C++.
---@type enough.LanguagePack
return {
  servers = {
    clangd = {
      cmd = { "clangd", "--background-index", "--clang-tidy" },
    },
  },

  tools = { "clang-format" },

  parsers = { "c", "cpp" },

  formatters = {
    c = { "clang_format" },
    cpp = { "clang_format" },
  },
}
