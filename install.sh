#!/usr/bin/env bash
#
# nvim-enough installer.
#
#   curl -fsSL https://raw.githubusercontent.com/rafi-ramdhani/nvim-enough/main/install.sh | bash
#
# Installs Neovim and the tools this config needs, backs up anything already in
# place, clones the config, and installs plugins and treesitter parsers. It
# shows exactly what it is going to do and asks once before doing any of it.

set -euo pipefail

REPO_URL="${NVIM_ENOUGH_REPO:-https://github.com/rafi-ramdhani/nvim-enough.git}"
REF="main"
TARGET="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
ASSUME_YES=0
DRY_RUN=0
LANGUAGES=""

# Neovim 0.12 is the floor: nvim-treesitter's main branch calls vim.list.unique().
MIN_NVIM_MAJOR=0
MIN_NVIM_MINOR=12

# ---------------------------------------------------------------- output ----

if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GREEN=$'\033[32m'
  YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
else
  BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""
fi

info()  { printf '%s\n' "$*"; }
step()  { printf '%s==>%s %s%s%s\n' "$BLUE" "$RESET" "$BOLD" "$*" "$RESET"; }
warn()  { printf '%s warning:%s %s\n' "$YELLOW" "$RESET" "$*" >&2; }
die()   { printf '%serror:%s %s\n' "$RED" "$RESET" "$*" >&2; exit 1; }
ok()    { printf '  %s+%s %s\n' "$GREEN" "$RESET" "$*"; }
skip()  { printf '  %s-%s %s\n' "$DIM" "$RESET" "$*"; }

usage() {
  cat <<'EOF'
nvim-enough installer

Usage: install.sh [options]

Options:
  --dry-run          Show what would happen, change nothing.
  --yes, -y          Do not ask for confirmation.
  --dir PATH         Install to PATH (default: ~/.config/nvim).
  --ref REF          Branch or tag to install (default: main).
  --languages LIST   Comma-separated language packs, e.g. "go,lua".
                     Skips the interactive prompt.
  --help, -h         Show this message.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y) ASSUME_YES=1 ;;
    --dir) TARGET="${2:?--dir needs a path}"; shift ;;
    --ref) REF="${2:?--ref needs a branch or tag}"; shift ;;
    --languages) LANGUAGES="${2:?--languages needs a list}"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) die "unknown option: $1 (try --help)" ;;
  esac
  shift
done

have() { command -v "$1" >/dev/null 2>&1; }

# Ask on the terminal rather than stdin: when this script is piped from curl,
# stdin is the script itself and `read` would consume it.
ask() {
  local prompt="$1" default="$2" reply
  if [ "$ASSUME_YES" = 1 ] || [ ! -r /dev/tty ]; then
    printf '%s' "$default"
    return
  fi
  printf '%s' "$prompt" > /dev/tty
  IFS= read -r reply < /dev/tty || reply=""
  printf '%s' "${reply:-$default}"
}

# ------------------------------------------------------------ inspection ----

case "$(uname -s)" in
  Darwin) OS=macos ;;
  Linux)  OS=linux ;;
  *)
    die "unsupported platform: $(uname -s)
nvim-enough installs through Homebrew, which covers macOS and Linux.
On Windows, use WSL2 and run this inside your Linux environment."
    ;;
esac

# Neovim needs to be new enough, not merely present.
nvim_too_old() {
  have nvim || return 1
  local version major minor
  version="$(nvim --version | head -1 | sed 's/^NVIM v//')"
  major="${version%%.*}"
  minor="${version#*.}"; minor="${minor%%.*}"
  [ "$major" -lt "$MIN_NVIM_MAJOR" ] ||
    { [ "$major" -eq "$MIN_NVIM_MAJOR" ] && [ "$minor" -lt "$MIN_NVIM_MINOR" ]; }
}

# Formula names, deliberately: `tree-sitter` is the library, `tree-sitter-cli`
# is the binary nvim-treesitter actually needs to build parsers.
MISSING=()
UPGRADE=()

have git || MISSING+=("git")
have rg || MISSING+=("ripgrep")
have fd || MISSING+=("fd")
have tree-sitter || MISSING+=("tree-sitter-cli")

if ! have nvim; then
  MISSING+=("neovim")
elif nvim_too_old; then
  UPGRADE+=("neovim")
fi

NEED_BREW=0
if [ ${#MISSING[@]} -gt 0 ] || [ ${#UPGRADE[@]} -gt 0 ]; then
  NEED_BREW=1
fi

# A C compiler builds telescope-fzf-native and the treesitter parsers.
NEED_COMPILER=0
if [ "$OS" = macos ]; then
  xcode-select -p >/dev/null 2>&1 || NEED_COMPILER=1
else
  have cc || have gcc || NEED_COMPILER=1
fi

BACKUPS=()
STAMP="$(date +%Y%m%d%H%M%S)"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
for dir in "$TARGET" "$DATA" "$STATE" "$CACHE"; do
  [ -e "$dir" ] && BACKUPS+=("$dir")
done

# ------------------------------------------------------------------ plan ----

echo
step "nvim-enough"
echo

if [ "$NEED_BREW" = 1 ]; then
  if have brew; then
    info "Homebrew: ${GREEN}found${RESET}"
  else
    info "Homebrew: ${YELLOW}will be installed${RESET}"
  fi
fi

info "${BOLD}Will install${RESET} (Homebrew)"
if [ ${#MISSING[@]} -eq 0 ] && [ ${#UPGRADE[@]} -eq 0 ]; then
  skip "nothing, all tools already present"
else
  for f in "${MISSING[@]:-}"; do [ -n "$f" ] && ok "$f"; done
  for f in "${UPGRADE[@]:-}"; do [ -n "$f" ] && ok "$f (upgrade: need >= $MIN_NVIM_MAJOR.$MIN_NVIM_MINOR)"; done
fi

if [ "$NEED_COMPILER" = 1 ]; then
  echo
  if [ "$OS" = macos ]; then
    ok "Xcode Command Line Tools (C compiler for parsers)"
  else
    warn "no C compiler found; install build-essential or equivalent first"
  fi
fi

echo
info "${BOLD}Will back up${RESET}"
if [ ${#BACKUPS[@]} -eq 0 ]; then
  skip "nothing, no existing Neovim files"
else
  for dir in "${BACKUPS[@]}"; do ok "$dir -> $dir.bak.$STAMP"; done
fi

echo
info "${BOLD}Will install nvim-enough to${RESET}"
ok "$TARGET  ${DIM}($REPO_URL @ $REF)${RESET}"
echo

if [ "$DRY_RUN" = 1 ]; then
  info "${DIM}--dry-run: nothing was changed.${RESET}"
  exit 0
fi

reply="$(ask "Proceed? [y/N] " "n")"
case "$reply" in
  [yY]|[yY][eE][sS]) ;;
  *) info "Cancelled."; exit 0 ;;
esac

# --------------------------------------------------------------- execute ----

if [ "$NEED_COMPILER" = 1 ] && [ "$OS" = macos ]; then
  step "Installing Xcode Command Line Tools"
  xcode-select --install 2>/dev/null || true
  info "If a dialog opened, finish it and re-run this script."
fi

if [ "$NEED_BREW" = 1 ] && ! have brew; then
  step "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    [ -x "$prefix/bin/brew" ] && eval "$("$prefix/bin/brew" shellenv)" && break
  done
  have brew || die "Homebrew installed but 'brew' is not on PATH; open a new shell and re-run."
fi

if [ ${#MISSING[@]} -gt 0 ]; then
  step "Installing tools"
  brew install "${MISSING[@]}"
fi
if [ ${#UPGRADE[@]} -gt 0 ]; then
  step "Upgrading tools"
  brew upgrade "${UPGRADE[@]}"
fi

if [ ${#BACKUPS[@]} -gt 0 ]; then
  step "Backing up existing Neovim files"
  for dir in "${BACKUPS[@]}"; do
    mv "$dir" "$dir.bak.$STAMP"
    ok "$dir.bak.$STAMP"
  done
fi

step "Cloning nvim-enough"
mkdir -p "$(dirname "$TARGET")"
git clone --branch "$REF" --depth 1 "$REPO_URL" "$TARGET"

# ------------------------------------------------------------- languages ----

if [ -z "$LANGUAGES" ]; then
  available="$(find "$TARGET/lua/enough/lang" -maxdepth 1 -name '*.lua' -not -name 'init.lua' \
    -exec basename {} .lua \; | sort | paste -sd, -)"
  echo
  info "${BOLD}Language packs${RESET}"
  info "Each adds a language server, formatter and treesitter parsers."
  info "Available: ${DIM}${available}${RESET}"
  LANGUAGES="$(ask "Which do you want? [lua] " "lua")"
fi

step "Writing your configuration"
mkdir -p "$TARGET/lua/user"
{
  echo "-- Your settings. This file is gitignored, so \`git pull\` never conflicts."
  echo "-- See user.example/init.lua for everything you can set."
  echo "return {"
  printf '  languages = {'
  first=1
  IFS=',' read -ra langs <<< "$LANGUAGES"
  for lang in "${langs[@]}"; do
    lang="$(echo "$lang" | tr -d '[:space:]')"
    [ -z "$lang" ] && continue
    [ $first = 1 ] && first=0 || printf ','
    printf ' "%s"' "$lang"
  done
  echo " },"
  echo "}"
} > "$TARGET/lua/user/init.lua"
ok "$TARGET/lua/user/init.lua"

# ------------------------------------------------------------- bootstrap ----

step "Installing plugins"
nvim --headless "+Lazy! sync" +qa

step "Installing treesitter parsers"
nvim --headless -c "lua require('enough.parsers').install({ wait = 600000 })" -c "qa!" || {
  warn "some parsers failed to build; run :TSUpdate inside Neovim to retry"
}

# ------------------------------------------------------------------ done ----

echo
step "Done"
info "Start Neovim with ${BOLD}nvim${RESET}."
echo
info "  Your settings   ${DIM}$TARGET/lua/user/init.lua${RESET}"
info "  Health check    ${DIM}:checkhealth enough${RESET}"
info "  Keymaps         ${DIM}:help nvim-enough${RESET}"
if [ ${#BACKUPS[@]} -gt 0 ]; then
  echo
  info "Your previous setup is at ${DIM}${BACKUPS[0]}.bak.$STAMP${RESET} if you want it back."
fi
echo
