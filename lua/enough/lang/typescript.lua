-- TypeScript and JavaScript, plus the web formats that travel with them.
--
-- prettier formats JSON, YAML and Markdown too. Those live here rather than in
-- the core because prettier is a Node tool: someone writing only Go should not
-- have to install a JavaScript toolchain to edit a config file. If you want
-- prettier without TypeScript, add it in lua/user/.
---@type enough.LanguagePack
return {
  servers = {
    ts_ls = {},
    html = {},
    cssls = {},
    cssmodules_ls = {},
    tailwindcss = {},
  },

  tools = { "prettierd" },

  parsers = {
    "javascript",
    "jsdoc",
    "tsx",
    "typescript",
    "css",
    "scss",
    "html",
    "graphql",
  },

  formatters = (function()
    local prettier = { "prettierd", "prettier" }
    local by_ft = {}
    for _, ft in ipairs({
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "html",
      "css",
      "scss",
      "less",
      "json",
      "jsonc",
      "yaml",
      "markdown",
      "graphql",
    }) do
      by_ft[ft] = prettier
    end
    return by_ft
  end)(),

  setup = function()
    -- JSX comment helpers, which only make sense in these buffers, so they are
    -- filetype-local rather than global.
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("enough-lang-typescript", { clear = true }),
      pattern = { "javascriptreact", "typescriptreact" },
      desc = "JSX comment mappings",
      callback = function(args)
        local opts = { buffer = args.buf, silent = true }
        vim.keymap.set("n", "<leader>xc", '_v$<left>da{/*<space><C-r>"<space>*/}<esc>', opts)
        vim.keymap.set("n", "<leader>uxc", "_xxxx$xxxx", opts)
        vim.keymap.set("v", "<leader>xc", "c{/*<enter>*/}<esc><up>p", opts)
        vim.keymap.set("v", "<leader>uxc", "dp<up><up>dddd", opts)
      end,
    })
  end,
}
