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

remove_zsh_pin_blocks() {
  local bashrc_path="$HOME/.bashrc"
  local marker_begin="# >>> current-user-zsh-pin >>>"
  local marker_end="# <<< current-user-zsh-pin <<<"
  local legacy_marker_begin="# >>> chacha-zsh-pin >>>"
  local legacy_marker_end="# <<< chacha-zsh-pin <<<"
  local tmp

  remove_one_block() {
    local begin="$1"
    local end="$2"

    if [[ ! -f "$bashrc_path" ]]; then
      return
    fi
    if ! grep -Fq "$begin" "$bashrc_path"; then
      return
    fi

    tmp="$(mktemp)"
    awk -v begin="$begin" -v end="$end" '
      $0 == begin {skip=1; next}
      $0 == end {skip=0; next}
      !skip {print}
    ' "$bashrc_path" > "$tmp"
    mv "$tmp" "$bashrc_path"
  }

  remove_one_block "$marker_begin" "$marker_end"
  remove_one_block "$legacy_marker_begin" "$legacy_marker_end"
}

echo "[uninstall] Removing linked dotfiles"
remove_link_or_file "$HOME/.zshrc"
remove_link_or_file "$HOME/.hyper.js"
remove_link_or_file "$HOME/.vimrc"
remove_link_or_file "$HOME/.chacharc"
remove_zsh_pin_blocks

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
