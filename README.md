Neovim configuration that is just enough.

### Comes with:

- LSP Setup & Installer (Mason)
  - [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
  - [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
  - [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim)
  - [WhoIsSethDaniel/mason-tool-installer.nvim](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim)
- Finder (Telescope)
  - [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
  - [nvim-telescope/telescope-fzf-native.nvim](https://github.com/nvim-telescope/telescope-fzf-native.nvim)
- Completions & Snippets
  - [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
  - [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
  - [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
  - [hrsh7th/cmp-buffer](https://github.com/hrsh7th/cmp-buffer)
  - [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
  - [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
- Formatter (Conform)
  - [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim)
- Git Support (fugitive & gitsigns)
  - [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)
  - [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- UI/UX Improvement
  - [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
  - [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
  - [j-hui/fidget.nvim](https://github.com/j-hui/fidget.nvim)

### Required software:

- `git`
- `npm` (required to install Javascript/Typescript language server)

### How to install:

> The below instructions are for Linux/Mac users only. If you are using Windows... I feel sorry for you, but you can follow the steps below and google or ask ChatGPT on how each step can be done in Windows.

#### 1. Back-up existing config

If you have an existing config, make sure to back it up. Just rename the old nvim config directory.

```
mv ~/.config/nvim ~/.config/nvim-old
```

#### 2. Clone the repo

```
git clone https://github.com/rafi-ramdhani/nvim-enough.git ~/.config/nvim
```

#### 3. Initialize neovim

Before initializing neovim, you might want to remove old plugins and cache if you think you have some (if not, you can still do it with no harm). You can do that with the command below.

```
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
```

This setup uses [lazy.nvim](https://github.com/folke/lazy.nvim), which if you don't know is a neovim package manager. Run the command below to launch neovim, and `lazy.nvim` will initialize your neovim plugins.

```
nvim
```

That's it! You should now have a neovim setup that is just enough.

### What's next?

- Read keymaps.lua in the lua directory. Tweak or add some based on your needs.
- Install the recommended software below.

### Recommended software:

- [ripgrep](https://github.com/BurntSushi/ripgrep) (Telescope will use this for faster finding)

### Inspired by [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim/tree/master)
