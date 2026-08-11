-- Language servers.
--
-- Servers are declared here, installed by mason, and configured with Neovim
-- 0.11's native `vim.lsp.config` / `vim.lsp.enable`. The older
-- `mason-lspconfig` handler callback is gone in mason-lspconfig v2, and the
-- `require("lspconfig")` framework is deprecated for removal in v3, so neither
-- is used.
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
          -- Shipped inside lua-language-server itself, so this needs no
          -- extra plugin.
          { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        },
      },
    },
  },
  config = function()
    ---@type table<string, vim.lsp.Config>
    local servers = {
      ts_ls = {},
      lua_ls = {},
      clangd = {},
      tailwindcss = {},
      cssls = {},
      html = {},
      cssmodules_ls = {},

      intelephense = {
        root_markers = { "index.php" },
      },

      omnisharp = {
        cmd = { "omnisharp" },
        -- `root_markers` matches literal file names only, so a glob such as
        -- "*.sln" silently never matches. Walk up with a predicate instead.
        root_dir = function(bufnr, on_dir)
          on_dir(vim.fs.root(vim.api.nvim_buf_get_name(bufnr), function(name)
            return name:match("%.sln$") ~= nil
          end))
        end,
      },
    }

    -- Formatters and linters, which are not language servers and so are not
    -- mason-lspconfig's business.
    local tools = { "stylua", "prettierd" }

    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = vim.tbl_keys(servers),
      -- Servers are enabled explicitly below; mason must not also enable them
      -- behind our back with default settings.
      automatic_enable = false,
    })
    require("mason-tool-installer").setup({ ensure_installed = tools })

    local capabilities = vim.tbl_deep_extend(
      "force",
      vim.lsp.protocol.make_client_capabilities(),
      require("cmp_nvim_lsp").default_capabilities()
    )

    -- Applies to every server, including any a user adds from lua/user/.
    vim.lsp.config("*", { capabilities = capabilities })

    for name, opts in pairs(servers) do
      if not vim.tbl_isempty(opts) then
        vim.lsp.config(name, opts)
      end
    end

    vim.lsp.enable(vim.tbl_keys(servers))
  end,
}
