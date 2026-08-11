return {
  "stevearc/conform.nvim",
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier" },
        html = { "prettierd", "prettier" },
        css = { "prettierd", "prettier" },
        javascriptreact = { "prettierd", "prettier" },
        json = { "prettierd", "prettier" },
        markdown = { "prettierd", "prettier" },
        scss = { "prettierd", "prettier" },
        typescript = { "prettierd", "prettier" },
        typescriptreact = { "prettierd", "prettier" },
        yaml = { "prettierd", "prettier" },
        graphql = { "prettierd", "prettier" },
        less = { "prettierd", "prettier" },
      },
    })

    local format = function()
      require("conform").format({ async = true, lsp_fallback = true })
    end

    vim.keymap.set("n", "<leader>fm", format)
  end,
}
