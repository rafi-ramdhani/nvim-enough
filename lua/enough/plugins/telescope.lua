return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  config = function()
    require("telescope").load_extension("fzf")

    local builtin = require("telescope.builtin")
    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
    end

    map("n", "<leader>sf", builtin.find_files, "Search files")
    map("n", "<leader>sg", builtin.live_grep, "Search by grep")
    map({ "n", "v" }, "<leader>sw", builtin.grep_string, "Search word under cursor")
    map("n", "<leader>s.", builtin.oldfiles, "Search recent files")
    map("n", "<leader>sr", builtin.resume, "Resume last search")

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("LspAttach-telescope-keymap", { clear = true }),
      callback = function(args)
        local bufnr = args.buf
        local opts = { buffer = bufnr, desc = "Go to definition" }
        -- Neovim provides grn, gra, grr, gri and gO itself; only `gd` is
        -- added, routed through telescope so multiple definitions get a picker.
        vim.keymap.set("n", "gd", builtin.lsp_definitions, opts)
      end,
    })
  end,
}
