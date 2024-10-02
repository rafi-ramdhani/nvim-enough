return {
  "lewis6991/gitsigns.nvim",
  config = function()
    require("gitsigns").setup({
      on_attach = function()
        local gitsigns = require("gitsigns")
        vim.keymap.set("n", "[g", gitsigns.prev_hunk)
        vim.keymap.set("n", "]g", gitsigns.next_hunk)
      end,
    })
  end,
}
