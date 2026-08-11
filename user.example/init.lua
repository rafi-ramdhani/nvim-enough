-- Copy this directory to lua/user/ to customise nvim-enough:
--
--     cp -r user.example lua/user
--
-- lua/user/ is gitignored, so `git pull` will never conflict with it.
-- Anything you return here is merged over the defaults in
-- lua/enough/config.lua.

return {
  -- Language packs to enable. Each one adds an LSP server, a formatter and
  -- treesitter parsers, and nothing loads for languages you leave out.
  --
  -- Available: typescript, go, python, rust, lua, c, php, csharp
  languages = { "lua" },

  -- colorscheme = "tokyonight",
  -- format_on_save = true,
}
