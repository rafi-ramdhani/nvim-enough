-- Rust.
--
-- No mason tools: rustfmt ships with the Rust toolchain, and installing a
-- second copy through mason only invites version drift.
---@type enough.LanguagePack
return {
  servers = {
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { allFeatures = true },
          checkOnSave = { command = "clippy" },
        },
      },
    },
  },

  parsers = { "rust", "ron" },

  formatters = {
    rust = { "rustfmt" },
  },
}
