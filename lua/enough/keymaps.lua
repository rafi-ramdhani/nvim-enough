-- Mappings that are not tied to a plugin or a language.
--
-- Every mapping has a description, so `:map`, which-key and any other lister
-- can say what it does. Anything Neovim already provides is left alone: 0.11+
-- ships `grn` rename, `gra` code action, `grr` references, `gri`
-- implementation, `gO` document symbols, `gc` comment toggle, `[d`/`]d`
-- diagnostic jumps, and `[q`/`]q` quickfix navigation. Re-mapping those would
-- be noise.
--
-- Language-specific mappings live in lua/enough/lang/, buffer-local to the
-- filetypes that can use them.

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

-- Clear search highlight.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- Diagnostics. `[d` and `]d` are Neovim defaults and are deliberately not
-- redefined here.
map("n", "<leader>e", vim.diagnostic.open_float, "Diagnostic under cursor")
map("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to location list")

-- Keep the cursor centred when moving in large jumps.
map("n", "<C-d>", "<C-d>zz", "Half page down, centred")
map("n", "<C-u>", "<C-u>zz", "Half page up, centred")
map("n", "n", "nzzzv", "Next search match, centred")
map("n", "N", "Nzzzv", "Previous search match, centred")

-- Move the selection up and down, reindenting as it goes.
map("v", "J", ":m '>+1<CR>gv=gv", "Move selection down")
map("v", "K", ":m '<-2<CR>gv=gv", "Move selection up")

-- File explorer.
map("n", "<leader>ee", vim.cmd.Ex, "Open file explorer")

-- Windows.
map("n", "<leader>hs", "<cmd>split<CR>", "Split horizontally")
map("n", "<leader>vs", "<cmd>vsplit<CR>", "Split vertically")
