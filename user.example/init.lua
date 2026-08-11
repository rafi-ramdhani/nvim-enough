-- Copy this directory to lua/user/ to customise nvim-enough:
--
--     cp -r user.example lua/user
--
-- lua/user/ is gitignored, so `git pull` will never conflict with it.
-- Anything you return here is merged over the defaults in
-- lua/enough/config.lua.

return {
  -- Language packs to enable. Each one adds a language server, the tools mason
  -- should install, treesitter parsers and a formatter. Nothing at all loads
  -- for languages you leave out, so a Go developer installs no Node tooling.
  --
  -- Available: c, csharp, go, lua, php, python, rust, typescript
  --
  -- Keep `lua` unless you never intend to edit this config.
  languages = { "lua" },

  -- colorscheme = "tokyonight",

  -- Format on write. Off by default: formatting a file the moment someone
  -- opens and saves it is a surprising first impression.
  -- format_on_save = true,
}
