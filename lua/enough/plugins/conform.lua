-- Formatting.
--
-- Which formatter runs for which filetype comes from the enabled language
-- packs, so this file names no language itself. See lua/enough/lang/.
return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  keys = {
    {
      "<leader>fm",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  config = function()
    local format_on_save = require("enough.config").options.format_on_save

    require("conform").setup({
      formatters_by_ft = require("enough.lang").formatters(),
      format_on_save = format_on_save and function()
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end or nil,
    })
  end,
}
