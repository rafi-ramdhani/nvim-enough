-- Go.
---@type enough.LanguagePack
return {
  servers = {
    gopls = {
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true,
        },
      },
    },
  },

  tools = { "gofumpt", "goimports" },

  parsers = { "go", "gomod", "gosum", "gowork" },

  formatters = {
    -- goimports first so imports are fixed before formatting.
    go = { "goimports", "gofumpt" },
  },
}
