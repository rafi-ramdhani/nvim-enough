vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("TextYankPost-highlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
