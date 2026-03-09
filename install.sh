#!/usr/bin/env bash
set -euo pipefail

THEME="powerlevel10k"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZPLUG_HOME="${ZPLUG_HOME:-$HOME/.zplug}"
PLATFORM="unknown"
INSTALL_USER="${USER:-$(id -un)}"
SHELL_PIN_BEGIN="# >>> current-user-zsh-pin >>>"
SHELL_PIN_END="# <<< current-user-zsh-pin <<<"
LEGACY_SHELL_PIN_BEGIN="# >>> chacha-zsh-pin >>>"
LEGACY_SHELL_PIN_END="# <<< chacha-zsh-pin <<<"

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

detect_platform() {
  case "$(uname -s)" in
    Linux)
      PLATFORM="linux"
      ;;
    Darwin)
      PLATFORM="macos"
      ;;
    *)
      PLATFORM="unknown"
      ;;
  esac
}

ensure_zsh_exists() {
  if ! command -v zsh >/dev/null 2>&1; then
    log "ERROR: zsh is required but not found in PATH."
    case "$PLATFORM" in
      linux)
        log "Install zsh first (e.g. apt/dnf/pacman/zypper) and rerun."
        ;;
      macos)
        log "Install zsh first (e.g. brew install zsh) and rerun."
        ;;
      *)
        log "Install zsh first, then rerun install.sh."
        ;;
    esac
    exit 1
  fi
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

ensure_python_deps() {
  if ! command -v python3 >/dev/null 2>&1; then
    log "WARNING: python3 not found. Skipping numpy/pillow install."
    return
  fi

  if python3 -m pip --version >/dev/null 2>&1; then
    log "Installing python dependencies (numpy, pillow)"
    if ! python3 -m pip install --user numpy pillow >/dev/null 2>&1; then
      log "WARNING: pip install failed. You may need manual install of numpy/pillow."
    fi
  else
    log "WARNING: pip is unavailable for python3. Skipping numpy/pillow install."
  fi
}

remove_block_by_markers() {
  local file_path="$1"
  local marker_begin="$2"
  local marker_end="$3"
  local tmp

  if [[ ! -f "$file_path" ]]; then
    return
  fi

  if ! grep -Fq "$marker_begin" "$file_path"; then
    return
  fi

  tmp="$(mktemp)"
  awk -v begin="$marker_begin" -v end="$marker_end" '
    $0 == begin {skip=1; next}
    $0 == end {skip=0; next}
    !skip {print}
  ' "$file_path" > "$tmp"
  mv "$tmp" "$file_path"
}

ensure_user_bash_handoff() {
  local bashrc_path="$HOME/.bashrc"
  touch "$bashrc_path"

  # Clean up legacy marker from previous versions.
  remove_block_by_markers "$bashrc_path" "$LEGACY_SHELL_PIN_BEGIN" "$LEGACY_SHELL_PIN_END"

  if grep -Fq "$SHELL_PIN_BEGIN" "$bashrc_path"; then
    return
  fi

  cat >> "$bashrc_path" <<EOF

$SHELL_PIN_BEGIN
if [[ -o interactive ]] && [[ "\${USER:-}" == "$INSTALL_USER" ]] && [[ -z "\${ZSH_VERSION:-}" ]] && command -v zsh >/dev/null 2>&1; then
  exec zsh -l
fi
$SHELL_PIN_END
EOF
}

pin_current_user_shell_on_linux() {
  if [[ "$PLATFORM" != "linux" ]]; then
    return
  fi

  local zsh_bin
  zsh_bin="$(command -v zsh)"
  ensure_user_bash_handoff

  local login_shell=""
  if command -v getent >/dev/null 2>&1; then
    login_shell="$(getent passwd "$INSTALL_USER" | awk -F: '{print $7}')"
  fi

  if [[ "$login_shell" == "$zsh_bin" ]]; then
    log "Linux branch: $INSTALL_USER login shell already pinned to zsh."
    return
  fi

  if ! command -v chsh >/dev/null 2>&1; then
    log "Linux branch: chsh not found. Added bash->zsh handoff in ~/.bashrc."
    return
  fi

  if chsh -s "$zsh_bin" "$INSTALL_USER" >/dev/null 2>&1; then
    log "Linux branch: $INSTALL_USER login shell pinned to $zsh_bin."
  else
    log "Linux branch: could not change login shell via chsh. bash->zsh handoff was added to ~/.bashrc."
  fi
}

ensure_chacharc_binaries_executable() {
  if [[ -f "$ROOT_DIR/.chacharc/bin/cinamol" && -f "$ROOT_DIR/.chacharc/bin/saver" ]]; then
    chmod +x "$ROOT_DIR/.chacharc/bin/cinamol" "$ROOT_DIR/.chacharc/bin/saver"
  fi
}

check_ffmpeg_caca_support() {
  if command -v ffmpeg >/dev/null 2>&1; then
    if ffmpeg -hide_banner -formats 2>/dev/null | grep -q " caca "; then
      log "ffmpeg+caca support: OK"
    else
      log "WARNING: ffmpeg is installed but caca format is missing."
      log "WARNING: saver may not work until ffmpeg is built with libcaca support."
    fi
  else
    log "WARNING: ffmpeg not found. saver requires ffmpeg."
  fi
}

install_zplug_if_needed() {
  if [[ ! -f "$ZPLUG_HOME/init.zsh" ]]; then
    log "Installing zplug"
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
  else
    log "zplug already installed at $ZPLUG_HOME"
  fi
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

detect_platform
log "Detected platform: $PLATFORM"
ensure_zsh_exists
ensure_python_deps
ensure_chacharc_binaries_executable
check_ffmpeg_caca_support

install_zplug_if_needed

mkdir -p "$HOME/.config/chacha-shell"
cat > "$HOME/.config/chacha-shell/theme.zsh" <<EOF
$(theme_config)
EOF
log "Theme selected: $THEME"

if [[ "$PLATFORM" == "linux" ]]; then
  log "Linux branch: installing zshrc configuration."
else
  log "Installing zshrc configuration."
fi
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

pin_current_user_shell_on_linux

log "Done. Restart terminal or run: exec zsh"
