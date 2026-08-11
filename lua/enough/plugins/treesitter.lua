-- Treesitter highlighting.
--
-- The branch is pinned deliberately. Upstream made `main` the default branch,
-- and `main` is a rewrite that calls `vim.list.unique()` — a Neovim 0.12 API.
-- On Neovim 0.11 it cannot install a single parser, and because its `setup()`
-- silently ignores `highlight`, `ensure_installed` and `auto_install`, it fails
-- quietly rather than loudly.
--
-- `master` supports Neovim 0.9 through 0.11 and is what this config targets.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  lazy = false,

  config = function()
    ---@diagnostic disable-next-line: missing-fields
    require("nvim-treesitter.configs").setup({
      ensure_installed = require("enough.parsers").wanted(),
      auto_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
}
