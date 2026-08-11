-- C#.
---@type enough.LanguagePack
return {
  servers = {
    omnisharp = {
      cmd = { "omnisharp" },
      -- `root_markers` matches literal file names only, so a glob such as
      -- "*.sln" silently never matches. Walk up with a predicate instead.
      root_dir = function(bufnr, on_dir)
        on_dir(vim.fs.root(vim.api.nvim_buf_get_name(bufnr), function(name)
          return name:match("%.sln$") ~= nil or name:match("%.csproj$") ~= nil
        end))
      end,
    },
  },

  parsers = { "c_sharp" },
}
