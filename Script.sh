#!/usr/bin/env bash
set -euo pipefail

# Remove unwanted packages
sudo dnf remove -y libreoffice* totem* yelp* \
  ibus-pinyin ibus-libpinyin ibus-m17n ibus-hangul ibus-anthy firefox || true

# Update system & install essentials
sudo dnf -y update
sudo dnf install -y zenity gnome-web
sudo dnf groupinstall -y "Development Tools"

# Install Zed
curl -fsSL https://zed.dev/install.sh | sh

# Install Homebrew if missing
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Install Bun
brew install oven-sh/bun/bun

# Verify installs
brew --version
bun --version
