-- PHP.
---@type enough.LanguagePack
return {
  servers = {
    intelephense = {
      -- composer.json as well as index.php: modern projects have the former
      -- and may not have the latter at the root.
      root_markers = { "composer.json", "index.php" },
    },
  },

  parsers = { "php", "phpdoc" },
}
