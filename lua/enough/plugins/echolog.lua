-- Debug-print statements for the expression under the cursor, in whatever
-- language the buffer happens to be. <leader>lp to print, `.` to repeat,
-- <leader>lc to remove them all again. See :help echolog.
return {
  "rafi-ramdhani/echolog.nvim",
  version = "v1.0.0",
  event = "VeryLazy",
  opts = {
    keymaps = true,
  },
}
