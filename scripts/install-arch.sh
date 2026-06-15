#!/usr/bin/env bash
#
# my-neovide installer for Arch-based distros
#   (Arch, Manjaro, EndeavourOS, Garuda, CachyOS, Artix...)
#
# What it does:
#   1. Verifies the system is Arch-based and you are not root.
#   2. Installs the core dependencies through pacman (Neovim, Neovide, ripgrep,
#      fd, lazygit, Node, Python, Go, a Nerd Font, clipboard tool).
#   3. Best-effort installs the DevOps CLIs surfaced in the UI (kubectl, helm,
#      k9s, lazydocker, ansible, opentofu, docker, shellcheck, shfmt, yamllint).
#      Anything not in the official repos is skipped with a note (use the AUR).
#   4. Backs up any existing ~/.config/nvim, then clones this repo there.
#   5. Boots Neovim headless so lazy.nvim installs every plugin and Mason pulls
#      the language servers / linters / formatters.
#   6. Adds nv / nvp aliases inside a clearly marked, re-runnable block.
#
# Re-running the script is safe: each step is idempotent.
# -----------------------------------------------------------------------------

set -euo pipefail

# ── Pretty logging ───────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    BOLD=$(tput bold); DIM=$(tput dim); RED=$(tput setaf 1)
    GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); BLUE=$(tput setaf 4)
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

# Must be present for the editor to work at all.
CORE_PACKAGES=(
    base-devel curl wget git unzip
    neovim neovide
    ripgrep fd lazygit
    nodejs npm python python-pip go
    ttf-jetbrains-mono-nerd
)

# DevOps CLIs the IDE drives. Installed best-effort: ones missing from the
# official repos (e.g. terraform proper, hadolint, tflint) are left to the AUR
# or Mason and do not abort the install.
DEVOPS_PACKAGES=(
    kubectl helm k9s lazydocker
    ansible opentofu
    docker docker-buildx docker-compose
    shellcheck shfmt yamllint
)

# ── Pre-flight checks ────────────────────────────────────────────────────────
step "Pre-flight checks"
[[ $EUID -ne 0 ]] || die "Do not run as root. Run as your user; sudo is requested when needed."
[[ -f /etc/os-release ]] || die "/etc/os-release not found — cannot detect distribution."

# shellcheck disable=SC1091
. /etc/os-release
if [[ "${ID:-}" != "arch" ]] && [[ "${ID_LIKE:-}" != *arch* ]]; then
    die "This installer is for Arch-based distros. Detected: ${PRETTY_NAME:-unknown}."
fi
ok "Arch-based distro: ${PRETTY_NAME:-Arch Linux}"

command -v pacman >/dev/null 2>&1 || die "pacman not found in PATH."
command -v sudo   >/dev/null 2>&1 || die "sudo is required."
ok "User: $(whoami) — pacman + sudo present"

# ── Clipboard depends on the session type ────────────────────────────────────
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
    CORE_PACKAGES+=(wl-clipboard); ok "Session: Wayland → wl-clipboard"
else
    CORE_PACKAGES+=(xclip); ok "Session: X11 → xclip"
fi

# ── Install ──────────────────────────────────────────────────────────────────
step "Refreshing pacman database (sudo required)"
sudo pacman -Sy --noconfirm
ok "Database refreshed"

step "Installing core packages"
printf '  %s%s%s\n' "$DIM" "${CORE_PACKAGES[*]}" "$RESET"
sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"
ok "Core packages present"

step "Installing DevOps CLIs (best-effort)"
for pkg in "${DEVOPS_PACKAGES[@]}"; do
    if sudo pacman -S --needed --noconfirm "$pkg" >/dev/null 2>&1; then
        ok "$pkg"
    else
        warn "$pkg not in official repos — install via AUR or let Mason handle it"
    fi
done

# ── Sanity: confirm the essentials are reachable ─────────────────────────────
for cmd in nvim git rg fd node npm python go; do
    command -v "$cmd" >/dev/null 2>&1 || die "$cmd is missing after install."
done
ok "Essential tools verified on PATH"

# ── Neovim version (≥ 0.10) ──────────────────────────────────────────────────
NVIM_VERSION=$(nvim --version | head -1 | awk '{print $2}' | tr -d 'v')
NVIM_MINOR=$(printf '%s' "$NVIM_VERSION" | cut -d. -f2)
if (( NVIM_MINOR < 10 )); then
    die "Neovim ≥ 0.10 required. Found: $NVIM_VERSION."
fi
ok "Neovim version: $NVIM_VERSION"

# ── Clone / update the config ────────────────────────────────────────────────
step "Installing my-neovide into $NVIM_CONFIG"
if [[ -e "$NVIM_CONFIG" ]] && [[ ! -d "$NVIM_CONFIG/.git" ]]; then
    BACKUP="$NVIM_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
    mv "$NVIM_CONFIG" "$BACKUP"; warn "Existing config moved to $BACKUP"
fi
if [[ -d "$NVIM_CONFIG/.git" ]]; then
    EXISTING_REMOTE=$(git -C "$NVIM_CONFIG" remote get-url origin 2>/dev/null || echo "")
    if [[ "$EXISTING_REMOTE" == *my-neovide* ]]; then
        ok "Repo already cloned, pulling latest"; git -C "$NVIM_CONFIG" pull --ff-only
    else
        BACKUP="$NVIM_CONFIG.backup.$(date +%Y%m%d-%H%M%S)"
        mv "$NVIM_CONFIG" "$BACKUP"; warn "Different repo found; moved to $BACKUP"
        git clone "$REPO_URL" "$NVIM_CONFIG"
    fi
else
    git clone "$REPO_URL" "$NVIM_CONFIG"
fi
ok "Repository ready at $NVIM_CONFIG"

# ── Plugin install (lazy.nvim) ───────────────────────────────────────────────
step "Installing plugins via lazy.nvim (this can take a minute)"
nvim --headless "+Lazy! sync" +qa 2>&1 | tail -5 || warn "lazy sync returned non-zero; continuing"
ok "lazy.nvim sync complete"

# ── Mason language servers / linters / formatters ────────────────────────────
step "Installing DevOps language servers via Mason"
MASON_TOOLS="lua-language-server stylua bash-language-server shellcheck shfmt \
yaml-language-server json-lsp taplo dockerfile-language-server \
docker-compose-language-service ansible-language-server ansible-lint \
terraform-ls tflint helm-ls gopls gofumpt delve pyright ruff debugpy \
marksman prettier hadolint yamllint"
# shellcheck disable=SC2086
nvim --headless "+Lazy! load mason.nvim" "+MasonInstall $MASON_TOOLS" "+sleep 180" +qa 2>&1 \
    | tail -5 || warn "Mason install returned non-zero; re-run :Mason inside Neovim"
ok "Mason packages requested (the rest auto-install on first launch)"

# ── Shell aliases (bash + zsh, idempotent) ───────────────────────────────────
step "Wiring nv / nvp aliases into your shell"
ALIAS_BLOCK=$(cat <<'EOF'
# >>> my-neovide aliases (do not edit between markers) >>>
alias nv='neovide'
alias nvp='neovide .'        # open the current project (cwd) in Neovide
# <<< my-neovide aliases <<<
EOF
)

inject_aliases() {
    local rc="$1"; [[ -f "$rc" ]] || return 0
    if grep -q ">>> my-neovide aliases" "$rc"; then
        local tmp; tmp=$(mktemp)
        awk -v block="$ALIAS_BLOCK" '
            /^# >>> my-neovide aliases/ { print block; skip=1; next }
            /^# <<< my-neovide aliases/ { skip=0; next }
            !skip
        ' "$rc" > "$tmp"
        mv "$tmp" "$rc"; ok "Updated alias block in $rc"
    else
        printf '\n%s\n' "$ALIAS_BLOCK" >> "$rc"; ok "Appended alias block to $rc"
    fi
}
inject_aliases "$HOME/.bashrc"
inject_aliases "$HOME/.zshrc"

CURRENT_SHELL=$(basename "${SHELL:-bash}")
case "$CURRENT_SHELL" in
    bash) RC_TO_SOURCE="$HOME/.bashrc" ;;
    zsh)  RC_TO_SOURCE="$HOME/.zshrc"  ;;
    *)    RC_TO_SOURCE="" ;;
esac

# ── Done ─────────────────────────────────────────────────────────────────────
printf '\n%s%s========================================%s\n'   "$BOLD" "$GREEN" "$RESET"
printf '%s%s    my-neovide installed successfully%s\n'        "$BOLD" "$GREEN" "$RESET"
printf '%s%s========================================%s\n\n'   "$BOLD" "$GREEN" "$RESET"

cat <<EOF
Try it now:

  ${BOLD}source ${RC_TO_SOURCE:-~/.bashrc}${RESET}   # reload aliases
  ${BOLD}nvp${RESET}                         # open the current project in Neovide
  ${BOLD}nvim${RESET}                        # or stay in the terminal

DevOps keymaps (leader = <Space>):
  <leader>tk  k9s            <leader>tl  lazydocker
  <leader>gg  lazygit        <leader>gn  Neogit
  <leader>or  run task       <leader>ot  task list
  <F5>        debug          <leader>Rs  send REST request
EOF

[[ -n "$RC_TO_SOURCE" ]] && warn "Run 'source $RC_TO_SOURCE' (or open a new terminal) for the aliases."
