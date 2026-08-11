# nvim-enough

A Neovim configuration that is just enough.

[![CI](https://github.com/rafi-ramdhani/nvim-enough/actions/workflows/ci.yml/badge.svg)](https://github.com/rafi-ramdhani/nvim-enough/actions/workflows/ci.yml)
![Neovim](https://img.shields.io/badge/Neovim-0.12%2B-57A143?logo=neovim&logoColor=white)
![Plugins](https://img.shields.io/badge/plugins-19-blue)

One command installs Neovim, the tools it needs, and a working editor. Nothing
is left for you to fix afterwards.

```sh
curl -fsSL https://raw.githubusercontent.com/rafi-ramdhani/nvim-enough/main/install.sh | bash
```

It shows you exactly what it will install and back up, and asks once before
touching anything.

---

## What this is

A **starter config**, not a framework. It is small enough to read in an
afternoon, and it stops there on purpose.

- **19 plugins.** The count is checked in CI, so it cannot creep up quietly.
- **Nothing loads for languages you do not write.** Language support is opt-in:
  a Go developer installs no Node toolchain.
- **Your changes live in a directory we never touch,** so `git pull` cannot
  conflict with them.
- **It installs its own dependencies,** including Neovim itself.

## What this is not

Not [LazyVim](https://github.com/LazyVim/LazyVim), [AstroNvim](https://github.com/AstroNvim/AstroNvim)
or [NvChad](https://github.com/NvChad/NvChad). Those are excellent, and they do
far more than this. If you want a full IDE experience out of the box, use one of
them.

Not [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) either, which
is a single annotated file you are meant to read and rewrite. This one is meant
to be *used*, and extended from the outside.

## Requirements

Neovim **0.12+**, macOS or Linux. The installer handles everything else:
`git`, `ripgrep`, `fd`, the `tree-sitter` CLI, and a C compiler.

Windows is not supported. Use WSL2 and install inside your Linux environment.

## Installation

```sh
curl -fsSL https://raw.githubusercontent.com/rafi-ramdhani/nvim-enough/main/install.sh | bash
```

<details>
<summary>Options</summary>

```
--dry-run          Show what would happen, change nothing.
--yes, -y          Do not ask for confirmation.
--dir PATH         Install to PATH (default: ~/.config/nvim).
--languages LIST   Comma-separated packs, e.g. "go,lua". Skips the prompt.
```

Anything already at `~/.config/nvim`, `~/.local/share/nvim`,
`~/.local/state/nvim` or `~/.cache/nvim` is moved to `<path>.bak.<timestamp>`.
Nothing is overwritten, and the installer tells you where your old setup went.

</details>

<details>
<summary>Installing by hand</summary>

```sh
brew install neovim ripgrep fd tree-sitter-cli
git clone https://github.com/rafi-ramdhani/nvim-enough.git ~/.config/nvim
nvim
```

Note the formula name: `tree-sitter` is the library, `tree-sitter-cli` is the
binary that builds parsers. Install the wrong one and you get no syntax
highlighting, with nothing to tell you why.

</details>

## Languages

Nothing language-specific loads unless you ask for it.

```lua
-- lua/user/init.lua
return {
  languages = { "go", "typescript" },
}
```

| Pack | Server | Formatter |
| --- | --- | --- |
| `c` | clangd | clang-format |
| `csharp` | omnisharp | — |
| `go` | gopls | goimports, gofumpt |
| `lua` | lua_ls | stylua |
| `php` | intelephense | — |
| `python` | pyright | ruff |
| `rust` | rust_analyzer | rustfmt |
| `typescript` | ts_ls, html, cssls, cssmodules_ls, tailwindcss | prettier |

Each pack also brings its treesitter parsers. `lua` is on by default, because
configuring Neovim is editing Lua.

Adding a language is one file in `lua/enough/lang/`, and it is plain data — see
[CONTRIBUTING.md](CONTRIBUTING.md).

## Keymaps

Leader is <kbd>Space</kbd>.

### Finding things

| Key | Does |
| --- | --- |
| `<leader>sf` | Search files |
| `<leader>sg` | Search by grep |
| `<leader>sw` | Search word under cursor |
| `<leader>s.` | Search recent files |
| `<leader>sr` | Resume last search |

### Code

| Key | Does |
| --- | --- |
| `gd` | Go to definition |
| `<leader>fm` | Format buffer |
| `<leader>e` | Diagnostic under cursor |
| `<leader>q` | Diagnostics to location list |

### Debug printing

echolog prints the expression under the cursor in whatever language you are in,
with the file, line and enclosing function filled in.

| Key | Does |
| --- | --- |
| `<leader>lp` | Print expression under cursor (or selection) |
| `<leader>lP` | Print above the statement |
| `<leader>lv` | Print every variable on the line |
| `<leader>lo` | Print over a motion — takes one, as in `iw` or `i(` |
| `<leader>ll` | Breadcrumb, no values |
| `<leader>lc` / `<leader>lC` | Delete statements: buffer / project |
| `<leader>lq` | Statements to quickfix |
| `<leader>lt` | Comment statements out |
| `<leader>lr` | Reset the statement counter |

`.` repeats the last print wherever you move to.

### Editing and windows

| Key | Does |
| --- | --- |
| `<Esc>` | Clear search highlight |
| `<C-d>` / `<C-u>` | Half page down / up, centred |
| `n` / `N` | Next / previous match, centred |
| `J` / `K` *(visual)* | Move selection down / up |
| `<leader>ee` | Open file explorer |
| `<leader>hs` / `<leader>vs` | Split horizontally / vertically |

### Completion

| Key | Does |
| --- | --- |
| `<C-n>` / `<C-p>` | Next / previous item |
| `<C-y>` | Accept |
| `<C-Space>` | Show menu / documentation |
| `<C-b>` / `<C-f>` | Scroll documentation |
| `<C-l>` / `<C-h>` | Next / previous snippet placeholder |
| `<C-e>` | Dismiss |

### What Neovim already gives you

These are not ours, and are deliberately not re-mapped. Worth knowing, because
they are why this config needs so few plugins:

| Key | Does |
| --- | --- |
| `grn` | Rename symbol |
| `gra` | Code action |
| `grr` | References |
| `gri` | Implementation |
| `gO` | Document symbols |
| `gc` / `gcc` | Toggle comment |
| `[d` / `]d` | Previous / next diagnostic |
| `[q` / `]q` | Previous / next quickfix item |
| `an` / `in` | Select outer / inner treesitter node |

## Customising

Your configuration lives in `lua/user/`, which is gitignored. `git pull` will
never conflict with it.

```sh
cp -r user.example lua/user
```

```lua
-- lua/user/init.lua
return {
  languages = { "go", "rust" },
  colorscheme = "tokyonight",
  format_on_save = true,
}
```

Any file in `lua/user/plugins/` is picked up automatically:

```lua
-- lua/user/plugins/extra.lua
return {
  { "folke/todo-comments.nvim", event = "VeryLazy", opts = {} },
}
```

To check whether a problem is yours or ours:

```sh
NVIM_ENOUGH_NO_USER=1 nvim
```

## What is included

| | |
| --- | --- |
| Plugin manager | lazy.nvim |
| LSP | nvim-lspconfig, mason, fidget, lazydev |
| Completion | blink.cmp, friendly-snippets |
| Finding | telescope, telescope-fzf-native |
| Syntax | nvim-treesitter |
| Formatting | conform.nvim |
| Git | gitsigns, fugitive |
| Debug printing | [echolog.nvim](https://github.com/rafi-ramdhani/echolog.nvim) |
| Look | tokyonight, lualine |

## Troubleshooting

```vim
:checkhealth enough
```

Reports the Neovim version, every external tool and what breaks without it,
which language packs are active, and which treesitter parsers are missing.

Most problems are a missing `tree-sitter` CLI, which produces no highlighting
and no error message. `:checkhealth enough` says so explicitly.

## Contributing

```sh
make check    # everything CI runs
```

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
