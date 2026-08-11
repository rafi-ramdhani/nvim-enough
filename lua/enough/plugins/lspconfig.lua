return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
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
          { path = "luvit-meta/library", words = { "vim%.uv" } },
        },
      },
      dependencies = {
        { "Bilal2453/luvit-meta", lazy = true },
      },
    },
  },
  config = function()
    local servers = {
      ts_ls = {},
      lua_ls = {},
      clangd = {},
      intelephense = {
        root_dir = require("lspconfig").util.root_pattern("index.php"),
      },
      omnisharp = {
        cmd = { "omnisharp" },
        root_dir = require("lspconfig").util.root_pattern("*.sln"),
      },
      -- eslint = {},
      tailwindcss = {},
      cssls = {},
      html = {},
      cssmodules_ls = {},
    }

    require("mason").setup()

    local ensure_installed = vim.tbl_keys(servers or {})
    vim.list_extend(ensure_installed, {
      "stylua",
      "prettierd",
    })

    require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

    require("mason-lspconfig").setup({
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
          require("lspconfig")[server_name].setup(server)
        end,
      },
    })
  end,
}
