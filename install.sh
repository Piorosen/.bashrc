#!/usr/bin/env bash
set -euo pipefail

THEME="powerlevel10k"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZPLUG_HOME="${ZPLUG_HOME:-$HOME/.zplug}"

usage() {
  cat <<'EOF'
Usage: ./install.sh [--theme THEME]

Themes:
  powerlevel10k (default)
  spaceship
  pure
  agnoster
EOF
}

log() {
  printf '[install] %s\n' "$1"
}

run_vim_cmd() {
  local timeout_sec="$1"
  shift
  if command -v perl >/dev/null 2>&1; then
    perl -e 'alarm shift @ARGV; exec @ARGV' "$timeout_sec" vim "$@" >/dev/null 2>&1 || true
  else
    vim "$@" >/dev/null 2>&1 || true
  fi
}

safe_link() {
  local src="$1"
  local dst="$2"

  if [[ -L "$dst" ]] && [[ "$(readlink "$dst")" == "$src" ]]; then
    return
  fi

  if [[ -e "$dst" || -L "$dst" ]]; then
    if [[ ! -L "$dst" ]]; then
      mv "$dst" "${dst}.backup.$(date +%Y%m%d%H%M%S)"
    else
      rm -f "$dst"
    fi
  fi
  ln -s "$src" "$dst"
}

theme_config() {
  case "$THEME" in
    powerlevel10k)
      cat <<'EOF'
zplug "romkatv/powerlevel10k", as:theme, depth:1
CHACHA_THEME_APPLY="p10k"
EOF
      ;;
    spaceship)
      cat <<'EOF'
zplug "spaceship-prompt/spaceship-prompt", use:"spaceship.zsh", as:theme
CHACHA_THEME_APPLY="spaceship"
EOF
      ;;
    pure)
      cat <<'EOF'
zplug "sindresorhus/pure", use:"pure.zsh", from:github
CHACHA_THEME_APPLY="pure"
EOF
      ;;
    agnoster)
      cat <<'EOF'
zplug "themes/agnoster", from:oh-my-zsh, as:theme
CHACHA_THEME_APPLY="agnoster"
EOF
      ;;
    *)
      echo "Unknown theme: $THEME" >&2
      usage
      exit 1
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --theme)
      THEME="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

log "Installing python dependencies (numpy, pillow)"
python3 -m pip install --user numpy pillow >/dev/null

if [[ ! -d "$ZPLUG_HOME" ]]; then
  log "Installing zplug"
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
else
  log "zplug already installed at $ZPLUG_HOME"
fi

mkdir -p "$HOME/.config/chacha-shell"
cat > "$HOME/.config/chacha-shell/theme.zsh" <<EOF
$(theme_config)
EOF
log "Theme selected: $THEME"

safe_link "$ROOT_DIR/.zshrc" "$HOME/.zshrc"

if [[ -f "$ROOT_DIR/.hyper.js" ]]; then
  safe_link "$ROOT_DIR/.hyper.js" "$HOME/.hyper.js"
fi

if [[ -f "$ROOT_DIR/.vimrc" ]]; then
  safe_link "$ROOT_DIR/.vimrc" "$HOME/.vimrc"
fi

mkdir -p "$HOME/.vim"

safe_link "$ROOT_DIR/.chacharc" "$HOME/.chacharc"

if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
  log "Installing vim-plug"
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null
fi

log "Installing Vim plugins"
run_vim_cmd 240 "+let g:chacha_noninteractive=1" "+PlugInstall --sync" "+qa"

log "Done. Restart terminal or run: exec zsh"
