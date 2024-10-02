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

-- Console.log
vim.keymap.set("n", "<leader>cl", 'yiwoconsole.log("")<esc><left><left>pa: <esc><right>a, <esc>p')
vim.keymap.set("v", "<leader>cl", 'yoconsole.log("")<esc><left><left>pa: <esc><right>a, <esc>p')

-- Comment JSX
vim.keymap.set("v", "<leader>xc", "c{/*<enter>*/}<esc><up>p")
vim.keymap.set("v", "<leader>uxc", "dp<up><up>dddd")
vim.keymap.set("n", "<leader>xc", '_v$<left>da{/*<space><C-r>"<space>*/}<esc>')
vim.keymap.set("n", "<leader>uxc", "_xxxx$xxxx")

-- Netrw
vim.keymap.set("n", "<leader>ee", vim.cmd.Ex)

-- Split
vim.keymap.set("n", "<leader>hs", ":split<CR>")
vim.keymap.set("n", "<leader>vs", ":vsplit<CR>")
