#!/usr/bin/env bash
set -euo pipefail

remove_link_or_file() {
  local path="$1"
  if [[ -L "$path" ]]; then
    rm -f "$path"
  elif [[ -f "$path" ]]; then
    rm -f "$path"
  fi
}

echo "[uninstall] Removing linked dotfiles"
remove_link_or_file "$HOME/.zshrc"
remove_link_or_file "$HOME/.hyper.js"
remove_link_or_file "$HOME/.vimrc"
remove_link_or_file "$HOME/.chacharc"

echo "[uninstall] Removing zsh theme/plugin state"
rm -rf "$HOME/.zplug"
rm -f "$HOME/.p10k.zsh"
rm -f "$HOME/.config/chacha-shell/theme.zsh"
rm -f "$HOME"/.cache/p10k-instant-prompt-*.zsh

echo "[uninstall] Cleaning broken backup symlinks created by previous installs"
find "$HOME" -maxdepth 1 -type l \
  \( -name ".zshrc.backup.*" -o -name ".hyper.js.backup.*" -o -name ".vimrc.backup.*" -o -name ".chacharc.backup.*" \) \
  -exec rm -f {} +

echo "[uninstall] Done"
