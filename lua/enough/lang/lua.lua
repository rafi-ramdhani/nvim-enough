-- Lua. Enabled by default, because configuring Neovim is editing Lua.
--
-- lazydev, configured alongside the LSP, supplies the Neovim API types.
---@type enough.LanguagePack
return {
  servers = {
    lua_ls = {
      settings = {
        Lua = {
          -- lazydev handles the library and runtime paths.
          workspace = { checkThirdParty = false },
          telemetry = { enable = false },
          format = { enable = false }, -- stylua does this
        },
      },
    },
  },

  tools = { "stylua" },

  parsers = { "lua", "luadoc" },

  formatters = {
    lua = { "stylua" },
  },
}
