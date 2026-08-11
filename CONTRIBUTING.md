# Contributing

New language packs, bug reports and doc fixes are all welcome, and none of
them need a discussion first.

## Running the checks

```sh
make check          # everything CI runs
```

| Command | What it does |
| --- | --- |
| `make smoke` | Boots the config and validates every language pack |
| `make budget` | Fails if the core plugin count changed |
| `make docs` | Fails if the README and the real keymaps disagree |
| `make treesitter` | Installs parsers, asserts highlighting attaches |
| `make lint` | shellcheck on `install.sh` |
| `make fmt` | stylua |

CI runs the same checks on Neovim **stable and nightly**. Nightly is
deliberate: this config has twice been broken by an upstream plugin changing
its API, and catching that a week early is worth the noise.

## The two rules

**Enough, not everything.** The core plugin count is pinned in
`scripts/budget.lua`. Adding a plugin fails CI until that number is raised in
the same commit. Raising it is allowed; raising it silently is not. If a
plugin's job can be done by something Neovim already ships, it should be.

**A language is data, not code.** If you find yourself writing
`if lang == "..."` outside `lua/enough/lang/`, the pack schema is probably
missing a field. Adding the field is usually the better fix.

## Adding a language

One file in `lua/enough/lang/`, named after the pack:

```lua
-- lua/enough/lang/zig.lua
---@type enough.LanguagePack
return {
  servers    = { zls = {} },
  tools      = {},
  parsers    = { "zig" },
  formatters = { zig = { "zigfmt" } },
}
```

| Field | Meaning |
| --- | --- |
| `servers` | Language servers, keyed by lspconfig name. Values are `vim.lsp.Config`. |
| `tools` | Extra mason packages: formatters, linters. |
| `parsers` | Treesitter parsers. |
| `formatters` | conform's `formatters_by_ft`. |
| `setup` | Optional function for anything that is not data, such as filetype-local mappings. |

All fields are optional. `make smoke` validates the shape of every pack, so a
typo fails CI without you writing a test.

Two things worth knowing:

- **Keep mappings buffer-local.** See `lua/enough/lang/typescript.lua`: its JSX
  mappings attach on a `FileType` autocmd rather than becoming global keys
  every user carries.
- **Do not add a tool that ships with the language.** `rust.lua` has no mason
  tools because `rustfmt` comes with the Rust toolchain, and a second copy only
  invites version drift.

## Keymaps

Every mapping needs a `desc`. Without one it is invisible to `:map` and to
which-key, which is the same documentation problem in a different place.
`make docs` enforces this, along with keeping the README's keymap tables in
sync with reality — in both directions.

Before adding a mapping, check whether Neovim already provides it. 0.11+ ships
`grn`, `gra`, `grr`, `gri`, `gO`, `gc`, `[d`/`]d` and treesitter textobjects.

## Testing changes safely

The scripts under `scripts/` are meant to be run against a throwaway
environment, so your own setup is never touched:

```sh
XDG_CONFIG_HOME=/tmp/t/config XDG_DATA_HOME=/tmp/t/data \
XDG_STATE_HOME=/tmp/t/state  XDG_CACHE_HOME=/tmp/t/cache \
  nvim --headless "+Lazy! sync" +qa
```

The installer takes `--dry-run` and `--dir`, so it can be exercised without
touching `~/.config/nvim`.

## Pull requests

Small and focused. Make sure `make check` passes, and if you changed anything
user-facing, update `README.md` and `doc/nvim-enough.txt` in the same PR — the
help file is the canonical reference and drifts easily.
