-- Remove hlsearch
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist)

-- Center position
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Drag and drop lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- The console.log mappings that used to live here are gone: echolog does the
-- same thing in every language, with the file, line and function filled in.
-- <leader>lp to print, `.` to repeat, <leader>lc to remove them all.
--
-- The JSX comment mappings moved to lua/enough/lang/typescript.lua, where they
-- are buffer-local to the filetypes that can use them.

-- Netrw
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)

-- Split
vim.keymap.set("n", "<leader>hs", ":split<CR>")
vim.keymap.set("n", "<leader>vs", ":vsplit<CR>")
