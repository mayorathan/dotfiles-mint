#!/usr/bin/env bash
#
# dotfiles-mint — install script for Linux Mint (targets Mint 22.x / Ubuntu 24.04 base)

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
info()    { printf "${BLUE}→${NC}  %s\n" "$1"; }
success() { printf "${GREEN}✓${NC}  %s\n" "$1"; }
warn()    { printf "${YELLOW}!${NC}  %s\n" "$1"; }
die()     { printf "${RED}✗${NC}  %s\n" "$1"; exit 1; }

DOTFILES="${DOTFILES:-$HOME/.config}"

echo ""
echo "  dotfiles-mint install"
echo "  ═════════════════════"
echo ""

# ── Preflight ────────────────────────────────────────────────────────────────
command -v apt-get &>/dev/null || die "apt-get not found — this script targets Linux Mint / Ubuntu."

sudo -v || die "This script needs sudo to install packages."
# Keep sudo alive in the background for the duration of the script
( while true; do sudo -v; sleep 60; done ) & SUDO_KEEP_PID=$!
trap 'kill "$SUDO_KEEP_PID" 2>/dev/null || true' EXIT

info "Updating apt package lists..."
sudo apt-get update -y

# ── apt packages ─────────────────────────────────────────────────────────────
PACKAGES="$DOTFILES/apt/packages.list"
if [[ -f "$PACKAGES" ]]; then
  info "Installing packages from $PACKAGES..."
  mapfile -t APT_PKGS < <(grep -vE '^\s*#|^\s*$' "$PACKAGES")
  sudo apt-get install -y "${APT_PKGS[@]}"
  success "apt packages installed"
else
  warn "No package list at $PACKAGES — skipping"
fi

# ── GitHub CLI (third-party apt repo) ────────────────────────────────────────
if ! command -v gh &>/dev/null; then
  info "Installing GitHub CLI..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  keyring="$(mktemp)"
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "$keyring"
  sudo cp "$keyring" /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  rm -f "$keyring"
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y gh
  success "GitHub CLI installed"
else
  success "GitHub CLI already installed"
fi

# ── lazygit (official PPA) ───────────────────────────────────────────────────
if ! command -v lazygit &>/dev/null; then
  info "Installing lazygit..."
  sudo add-apt-repository -y ppa:lazygit-team/release
  sudo apt-get update -y
  sudo apt-get install -y lazygit
  success "lazygit installed"
else
  success "lazygit already installed"
fi

# ── Ghostty (community PPA for Ubuntu 24.04 / Mint 22) ───────────────────────
if ! command -v ghostty &>/dev/null; then
  info "Installing Ghostty..."
  sudo add-apt-repository -y ppa:mkasberg/ghostty-ubuntu
  sudo apt-get update -y
  sudo apt-get install -y ghostty
  success "Ghostty installed"
else
  success "Ghostty already installed"
fi

# ── bottom / btm (GitHub release .deb, not in Mint repos) ────────────────────
if ! command -v btm &>/dev/null; then
  info "Installing bottom (btm)..."
  arch="$(dpkg --print-architecture)"   # amd64 or arm64
  tmp="$(mktemp -d)"
  url="$(curl -fsSL https://api.github.com/repos/ClementTsang/bottom/releases/latest \
    | grep -oE 'https://[^"]+_[^"]+_'"${arch}"'\.deb' | head -n1)"
  [[ -n "$url" ]] || die "Could not find a bottom .deb for arch $arch"
  curl -fsSL -o "$tmp/bottom.deb" "$url"
  sudo apt-get install -y "$tmp/bottom.deb"
  rm -rf "$tmp"
  success "bottom installed"
else
  success "bottom already installed"
fi

# ── starship (official installer → ~/.local/bin) ─────────────────────────────
if ! command -v starship &>/dev/null; then
  info "Installing starship..."
  curl -sS https://starship.rs/install.sh | sh -s -- -y
  success "starship installed"
else
  success "starship already installed"
fi

# ── atuin (official installer → ~/.local/bin) ────────────────────────────────
if ! command -v atuin &>/dev/null; then
  info "Installing atuin..."
  bash <(curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh)
  success "atuin installed"
else
  success "atuin already installed"
fi

# ── JetBrains Mono Nerd Font ─────────────────────────────────────────────────
if ! fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
  info "Installing JetBrains Mono Nerd Font..."
  mkdir -p "$HOME/.local/share/fonts"
  curl -fsSL -o /tmp/JetBrainsMono.zip \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
  unzip -o /tmp/JetBrainsMono.zip -d "$HOME/.local/share/fonts/JetBrainsMono"
  rm -f /tmp/JetBrainsMono.zip
  fc-cache -f
  success "Nerd Font installed"
else
  success "JetBrains Mono Nerd Font already installed"
fi

# ── Git submodules (zsh plugins, ghostty shaders) ────────────────────────────
if [[ -d "$DOTFILES/.git" ]]; then
  info "Initializing git submodules..."
  git -C "$DOTFILES" submodule update --init --recursive
  success "Submodules initialized"
else
  warn "$DOTFILES is not a git repo — skipping submodule init"
fi

# ── .zshenv symlink ───────────────────────────────────────────────────────────
ZSHENV_SRC="$DOTFILES/.zshenv"
ZSHENV_DST="$HOME/.zshenv"

if [[ -L "$ZSHENV_DST" ]]; then
  success "~/.zshenv symlink already in place"
elif [[ -f "$ZSHENV_DST" ]]; then
  warn "~/.zshenv already exists as a regular file — backing up to ~/.zshenv.bak"
  mv "$ZSHENV_DST" "$ZSHENV_DST.bak"
  ln -s "$ZSHENV_SRC" "$ZSHENV_DST"
  success "Symlinked ~/.zshenv → $ZSHENV_SRC"
else
  ln -s "$ZSHENV_SRC" "$ZSHENV_DST"
  success "Symlinked ~/.zshenv → $ZSHENV_SRC"
fi

# ── Default shell ─────────────────────────────────────────────────────────────
ZSH_PATH="$(command -v zsh)"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
  info "Setting zsh as default shell..."
  if ! grep -q "$ZSH_PATH" /etc/shells; then
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi
  chsh -s "$ZSH_PATH"
  success "Default shell set to zsh ($ZSH_PATH)"
else
  success "zsh is already the default shell"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "  ${GREEN}All done!${NC} Restart your terminal to apply everything."
echo ""
