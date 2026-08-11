-- Completion.
--
-- blink.cmp replaces nvim-cmp and its source plugins, and uses Neovim's native
-- `vim.snippet` rather than a separate snippet engine. That is six plugins
-- (nvim-cmp, cmp-nvim-lsp, cmp-path, cmp-buffer, cmp_luasnip, LuaSnip) down to
-- one, without losing snippets: friendly-snippets is a collection of JSON
-- files, so it stays.
return {
  "saghen/blink.cmp",
  -- Pinned to v1. Upstream describes v2 as "under active development with many
  -- breaking changes" and recommends this for anyone wanting stability.
  version = "1.*",
  event = "InsertEnter",
  dependencies = { "rafamadriz/friendly-snippets" },

  ---@module "blink.cmp"
  ---@type blink.cmp.Config
  opts = {
    -- The nvim-cmp bindings this config used, kept so muscle memory survives
    -- the swap.
    keymap = {
      preset = "none",
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<C-b>"] = { "scroll_documentation_up", "fallback" },
      ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-l>"] = { "snippet_forward", "fallback" },
      ["<C-h>"] = { "snippet_backward", "fallback" },
      ["<C-e>"] = { "hide", "fallback" },
    },

    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Native vim.snippet, which also reads friendly-snippets.
    snippets = { preset = "default" },

    completion = {
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      menu = { draw = { treesitter = { "lsp" } } },
    },

    -- Downloads a prebuilt binary and falls back to the Lua matcher with a
    -- warning if that is not possible, so a fresh install cannot hard-fail.
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },

  -- Lets lua/user/ append sources without restating the defaults.
  opts_extend = { "sources.default" },
}
