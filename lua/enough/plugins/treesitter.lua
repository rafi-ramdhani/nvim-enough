-- Treesitter highlighting.
--
-- The branch is pinned deliberately. `master` is archived, and `main` is a
-- rewrite: `setup()` no longer accepts `highlight`, `ensure_installed` or
-- `auto_install`, and silently ignores them if passed. Parsers are installed
-- explicitly, and highlighting is started per buffer with
-- `vim.treesitter.start()`.
--
-- `main` requires Neovim 0.12 (it calls `vim.list.unique()`), which is what
-- lua/enough/init.lua checks for before anything else loads.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,

  config = function()
    require("nvim-treesitter").setup()

    -- Non-blocking, so a first run compiles parsers in the background rather
    -- than holding up startup. The installer pre-installs them, so this is
    -- usually a no-op.
    require("enough.parsers").install()

    -- `main` does not attach highlighting itself. Neovim starts treesitter for
    -- the handful of parsers it bundles; everything else needs this.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("enough-treesitter", { clear = true }),
      desc = "Start treesitter highlighting when a parser is available",
      callback = function(args)
        local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
        if lang and vim.treesitter.language.add(lang) then
          vim.treesitter.start(args.buf, lang)
        end
      end,
    })
  end,
}
