#!/usr/bin/env bash
#
# my-neovide installer for Arch-based distros
#   (Arch, Manjaro, EndeavourOS, Garuda, CachyOS, Artix...)
#
# What it does:
#   1. Verifies the system is Arch-based and you are not root.
#   2. Installs every dependency through pacman (Neovim, Neovide, ripgrep,
#      fd, lazygit, Node.js, npm, pandoc, typst, JetBrains Mono Nerd Font,
#      and the right clipboard tool for your session — wl-clipboard on
#      Wayland, xclip on X11).
#   3. Backs up any pre-existing ~/.config/nvim into a timestamped folder.
#   4. Clones this repository into ~/.config/nvim.
#   5. Creates the default Obsidian vault at ~/Documents/Notes.
#   6. Boots Neovim headless to let lazy.nvim install every plugin and Mason
#      pull marksman, ltex-ls, prettier and markdownlint-cli2.
#   7. Adds nv / nvm / nvhere aliases to your shell rc (bash or zsh) inside
#      a clearly marked block so it can be re-run safely.
#
# Re-running the script is safe: each step is idempotent.
# -----------------------------------------------------------------------------

set -euo pipefail

# ── Pretty logging ───────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    BOLD=$(tput bold)
    DIM=$(tput dim)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    RESET=$(tput sgr0)
else
    BOLD="" DIM="" RED="" GREEN="" YELLOW="" BLUE="" RESET=""
fi

step() { printf '\n%s==>%s %s%s%s\n' "$BLUE" "$RESET" "$BOLD" "$*" "$RESET"; }
ok()   { printf '  %s✓%s %s\n'  "$GREEN"  "$RESET" "$*"; }
warn() { printf '  %s!%s %s\n'  "$YELLOW" "$RESET" "$*"; }
die()  { printf '\n%s✗ %s%s\n\n' "$RED" "$*" "$RESET" >&2; exit 1; }

# ── Constants ────────────────────────────────────────────────────────────────
REPO_URL="https://github.com/samuelmonteirotf/my-neovide.git"
NVIM_CONFIG="$HOME/.config/nvim"
NOTES_DIR="$HOME/Documents/Notes"

PACMAN_PACKAGES=(
    base-devel
    curl
    fd
    git
    lazygit
    neovide
    neovim
    nodejs
    npm
    pandoc
    python
    ripgrep
    ttf-jetbrains-mono-nerd
    typst
    unzip
    wget
)

# ── Pre-flight checks ────────────────────────────────────────────────────────
step "Pre-flight checks"

[[ $EUID -ne 0 ]] || die "Do not run this script as root. Run as your user; sudo will be requested when needed."

if [[ ! -f /etc/os-release ]]; then
    die "/etc/os-release not found — cannot detect distribution."
fi

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "arch" ]] && [[ "${ID_LIKE:-}" != *arch* ]]; then
    die "This installer is for Arch-based distros. Detected: ${PRETTY_NAME:-unknown}."
fi
ok "Arch-based distro: ${PRETTY_NAME:-Arch Linux}"

command -v pacman >/dev/null 2>&1 || die "pacman not found in PATH."
command -v sudo   >/dev/null 2>&1 || die "sudo is required."

ok "User: $(whoami)"
ok "pacman + sudo present"

# ── Clipboard package depends on the session type ────────────────────────────
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    PACMAN_PACKAGES+=(wl-clipboard)
    ok "Session: Wayland → installing wl-clipboard"
else
    PACMAN_PACKAGES+=(xclip)
    ok "Session: X11 → installing xclip"
fi

# ── Update package database & install ────────────────────────────────────────
step "Refreshing pacman database (sudo required)"
sudo pacman -Sy --noconfirm
ok "Database refreshed"

step "Installing system packages"
printf '  %s%s%s\n' "$DIM" "${PACMAN_PACKAGES[*]}" "$RESET"
sudo pacman -S --needed --noconfirm "${PACMAN_PACKAGES[@]}"
ok "All system packages present"

# ── Sanity: confirm critical tools are now reachable ─────────────────────────
for cmd in nvim neovide git pandoc typst rg fd lazygit node npm; do
    command -v "$cmd" >/dev/null 2>&1 || die "$cmd is missing after install."
done
ok "Critical tools verified on PATH"

# ── Neovim version (≥ 0.10 required by the config) ───────────────────────────
NVIM_VERSION=$(nvim --version | head -1 | awk '{print $2}' | tr -d 'v')
NVIM_MAJOR=$(printf '%s' "$NVIM_VERSION" | cut -d. -f1)
NVIM_MINOR=$(printf '%s' "$NVIM_VERSION" | cut -d. -f2)
if (( NVIM_MAJOR < 1 )) && (( NVIM_MINOR < 10 )); then
    die "Neovim ≥ 0.10 required. Found: $NVIM_VERSION."
fi
ok "Neovim version: $NVIM_VERSION"

# ── Backup any existing config ───────────────────────────────────────────────
step "Cloning my-neovide into $NVIM_CONFIG"

if [[ -e "$NVIM_CONFIG" ]] && [[ ! -d "$NVIM_CONFIG/.git" ]]; then
    BACKUP="$NVIM_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
    mv "$NVIM_CONFIG" "$BACKUP"
    warn "Existing config moved to $BACKUP"
fi

if [[ -d "$NVIM_CONFIG/.git" ]]; then
    EXISTING_REMOTE=$(git -C "$NVIM_CONFIG" remote get-url origin 2>/dev/null || echo "")
    if [[ "$EXISTING_REMOTE" == *my-neovide* ]]; then
        ok "my-neovide repo already cloned, pulling latest"
        git -C "$NVIM_CONFIG" pull --ff-only
    else
        BACKUP="$NVIM_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
        mv "$NVIM_CONFIG" "$BACKUP"
        warn "Different repo found; moved to $BACKUP"
        git clone "$REPO_URL" "$NVIM_CONFIG"
    fi
else
    git clone "$REPO_URL" "$NVIM_CONFIG"
fi
ok "Repository ready at $NVIM_CONFIG"

# ── Notes vault ──────────────────────────────────────────────────────────────
step "Preparing Obsidian-style vault"
mkdir -p "$NOTES_DIR/daily" "$NOTES_DIR/attachments"
ok "Vault at $NOTES_DIR (with daily/ and attachments/)"

# ── Plugin install (lazy.nvim) ───────────────────────────────────────────────
step "Installing plugins via lazy.nvim (this can take a minute)"
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || warn "lazy sync returned non-zero; continuing"
ok "lazy.nvim sync complete"

# ── Mason packages (run inside Neovide context so docs LSPs are pulled) ──────
step "Installing language servers and formatters via Mason"
nvim --headless --cmd "let g:neovide=v:true" \
     "+Lazy! load mason.nvim" \
     "+MasonInstall marksman ltex-ls prettier markdownlint-cli2" \
     "+sleep 120" +qa 2>&1 | tail -5 || warn "Mason install returned non-zero; you can re-run :Mason inside Neovim"
ok "Mason packages requested"

# ── Shell aliases (bash + zsh, idempotent) ───────────────────────────────────
step "Wiring nv / nvm / nvhere aliases into your shell"

ALIAS_BLOCK=$(cat <<'EOF'
# >>> my-neovide aliases (do not edit between markers) >>>
alias nv='neovide --fork ~/Documents/Notes'
alias nvm='neovide --fork --maximized ~/Documents/Notes'
alias nvhere='neovide --fork .'
# <<< my-neovide aliases <<<
EOF
)

inject_aliases() {
    local rc="$1"
    [[ -f "$rc" ]] || return 0

    if grep -q ">>> my-neovide aliases" "$rc"; then
        # Replace the existing block in place
        local tmp
        tmp=$(mktemp)
        awk -v block="$ALIAS_BLOCK" '
            /^# >>> my-neovide aliases/ { print block; skip=1; next }
            /^# <<< my-neovide aliases/ { skip=0; next }
            !skip
        ' "$rc" > "$tmp"
        mv "$tmp" "$rc"
        ok "Updated alias block in $rc"
    else
        printf '\n%s\n' "$ALIAS_BLOCK" >> "$rc"
        ok "Appended alias block to $rc"
    fi
}

inject_aliases "$HOME/.bashrc"
inject_aliases "$HOME/.zshrc"

# ── Reload current shell rc when sourced (best-effort) ───────────────────────
CURRENT_SHELL=$(basename "${SHELL:-bash}")
case "$CURRENT_SHELL" in
    bash) RC_TO_SOURCE="$HOME/.bashrc" ;;
    zsh)  RC_TO_SOURCE="$HOME/.zshrc"  ;;
    *)    RC_TO_SOURCE="" ;;
esac

# ── Done ─────────────────────────────────────────────────────────────────────
printf '\n%s%s========================================%s\n' "$BOLD" "$GREEN" "$RESET"
printf '%s%s    my-neovide installed successfully%s\n'    "$BOLD" "$GREEN" "$RESET"
printf '%s%s========================================%s\n\n' "$BOLD" "$GREEN" "$RESET"

cat <<EOF
Try it now:

  ${BOLD}source $RC_TO_SOURCE${RESET}      # reload aliases in this shell
  ${BOLD}nv${RESET}                         # open Neovide on your notes vault
  ${BOLD}nvim${RESET}                       # full IDE mode in the terminal

Useful keymaps inside Neovide (leader = <Space>):
  <leader>on   new note          <leader>od   daily note
  <leader>z    zen mode          <leader>mp   browser preview
  <leader>ep   export PDF        <leader>ed   export DOCX
  <leader>cp   LTeX → pt-BR      <leader>ce   LTeX → en-US

EOF

if [[ -n "$RC_TO_SOURCE" ]]; then
    warn "Run 'source $RC_TO_SOURCE' (or open a new terminal) so the new aliases take effect."
fi
