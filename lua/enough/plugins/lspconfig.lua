-- Language servers.
--
-- This file knows nothing about any particular language. Servers, and the
-- mason packages behind them, come from whichever language packs are enabled
-- in lua/user/init.lua. See lua/enough/lang/.
--
-- Servers are configured with Neovim 0.11+'s native `vim.lsp.config` /
-- `vim.lsp.enable`. The older `mason-lspconfig` handler callback is gone in
-- mason-lspconfig v2, and the `require("lspconfig")` framework is deprecated
-- for removal in v3, so neither is used.
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "saghen/blink.cmp",
    "nvim-telescope/telescope.nvim",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    { "j-hui/fidget.nvim", opts = {} },
    {
      "folke/lazydev.nvim",
      ft = "lua",
      opts = {
        library = {
          -- Shipped inside lua-language-server itself, so this needs no extra
          -- plugin.
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    local lang = require("enough.lang")
    local servers = lang.servers()

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
      -- Servers are enabled explicitly below; mason must not also enable them
      -- behind our back with default settings.
      automatic_enable = false,
    })
    require("mason-tool-installer").setup({ ensure_installed = lang.tools() })

    -- blink.cmp advertises what it can actually do (snippets, resolve support,
    -- and so on); servers tailor their replies to it.
    local capabilities = require("blink.cmp").get_lsp_capabilities()

    -- Applies to every server, including any a user adds from lua/user/.
    vim.lsp.config("*", { capabilities = capabilities })

    for name, opts in pairs(servers) do
      if not vim.tbl_isempty(opts) then
        vim.lsp.config(name, opts)
      end
    end

    if not vim.tbl_isempty(servers) then
      vim.lsp.enable(vim.tbl_keys(servers))
    end
  end,
}
