#!/usr/bin/env bash
# ==========================================================
# Fedora Web Developer Setup Script
# Author: krilledxheez
# Version: 2.2
# ==========================================================
# PURPOSE:
#   - Remove stock bloat (LibreOffice, Firefox, etc.)
#   - Update and upgrade system
#   - Install essential developer tools
#   - Install Zed editor, Homebrew, and Bun
#   - Perform full system cleanup afterwards
# ==========================================================

set -euo pipefail

# ---------- Colors ----------
GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; RESET="\e[0m"
say() { echo -e "${CYAN}→${RESET} $1"; }
ok()  { echo -e "${GREEN}✓${RESET} $1"; }

# ---------- Safety ----------
if [[ $EUID -eq 0 ]]; then
  echo -e "${YELLOW}!${RESET} Don't run this as root. The script will use sudo where needed."
  exit 1
fi

# ---------- 1. Remove Unwanted Packages ----------
say "Removing unnecessary preinstalled packages..."
sudo dnf remove -y libreoffice* totem* yelp* \
  ibus-pinyin ibus-libpinyin ibus-m17n ibus-hangul ibus-anthy firefox || true
ok "Bloat removed."

# ---------- 2. System Update ----------
say "Updating system packages..."
sudo dnf -y upgrade --refresh
ok "System updated."

# ---------- 3. Install Core Dev Tools ----------
say "Installing essential development tools..."
sudo dnf install -y git curl wget unzip tar python3 python3-pip neovim
sudo dnf groupinstall -y "Development Tools"
ok "Development tools installed."

# ---------- 4. Zed Editor ----------
say "Installing Zed editor..."
curl -fsSL https://zed.dev/install.sh | sh
ok "Zed installed."

# ---------- 5. Homebrew ----------
if ! command -v brew &>/dev/null; then
  say "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  ok "Homebrew installed."
else
  ok "Homebrew already installed."
fi

# ---------- 6. Bun ----------
say "Installing Bun (modern JS runtime & package manager)..."
brew install oven-sh/bun/bun
ok "Bun installed."

# ---------- 7. Clean System ----------
say "Cleaning up system caches and junk..."

# Remove unneeded dependencies
sudo dnf autoremove -y

# Clean downloaded metadata & packages
sudo dnf clean all

# Clear temporary files (DNF, system, and user)
sudo rm -rf /var/cache/dnf/*
sudo rm -rf /var/tmp/*
rm -rf "$HOME/.cache"/* 2>/dev/null || true

# Remove any leftover lock files
sudo rm -f /var/lib/dnf/*lock* 2>/dev/null || true

# Vacuum old journal logs (keep 100MB)
sudo journalctl --vacuum-size=100M > /dev/null 2>&1 || true

ok "System cleaned."

# ---------- 8. Verify Installs ----------
say "Verifying installations..."
echo -e "${YELLOW}──────────────────────────────${RESET}"
printf "%-10s %s\n" "Zed:"  "$(command -v zed || echo 'not found')"
printf "%-10s %s\n" "Bun:"  "$(bun --version 2>/dev/null || echo 'not found')"
printf "%-10s %s\n" "Brew:" "$(brew --version 2>/dev/null | head -n 1 || echo 'not found')"
echo -e "${YELLOW}──────────────────────────────${RESET}"
ok "Verification complete."

echo -e "\n${GREEN}✅ Setup complete!${RESET}"
echo -e "Restart your terminal or run: ${YELLOW}source ~/.bashrc${RESET}"
