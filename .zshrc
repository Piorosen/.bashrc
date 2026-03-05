parent_comm="$(ps -o comm= -p "$PPID" 2>/dev/null || true)"
CHACHA_IN_VIM_TERMINAL=false
if [[ "$parent_comm" == *vim* ]] || [[ "$parent_comm" == *nvim* ]]; then
  CHACHA_IN_VIM_TERMINAL=true
fi

if [[ -o interactive ]] && [[ "$CHACHA_IN_VIM_TERMINAL" == false ]] && [[ -f "$HOME/.chacharc/draw.py" && -f "$HOME/.chacharc/image.png" ]]; then
  python3 "$HOME/.chacharc/draw.py" -i "$HOME/.chacharc/image.png" -m RGB -a 1.5 -c 2 --auto w
fi

ZSH_DISABLE_COMPFIX=true

# Powerlevel10k instant prompt must stay near the top for fast startup.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZPLUG_HOME="${ZPLUG_HOME:-$HOME/.zplug}"
# Bootstrap zplug automatically so theme install can run on fresh machines.
if [[ ! -f "$ZPLUG_HOME/init.zsh" ]] && command -v curl >/dev/null 2>&1; then
  mkdir -p "$ZPLUG_HOME"
  curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh >/dev/null 2>&1
fi

if [[ -f "$ZPLUG_HOME/init.zsh" ]]; then
  source "$ZPLUG_HOME/init.zsh"

  zplug "zsh-users/zsh-autosuggestions"
  zplug "zdharma-continuum/fast-syntax-highlighting"
  zplug "plugins/git", from:oh-my-zsh

  CHACHA_THEME_APPLY=""
  if [[ -f "$HOME/.config/chacha-shell/theme.zsh" ]]; then
    source "$HOME/.config/chacha-shell/theme.zsh"
  else
    zplug "romkatv/powerlevel10k", as:theme, depth:1
    CHACHA_THEME_APPLY="p10k"
  fi

  if ! zplug check --verbose; then
    zplug install
  fi

  zplug load

  case "$CHACHA_THEME_APPLY" in
    p10k)
      if [[ "$CHACHA_IN_VIM_TERMINAL" == false ]]; then
        [[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
      fi
      ;;
    pure)
      autoload -U promptinit; promptinit
      prompt pure
      ;;
    spaceship)
      autoload -U promptinit; promptinit
      prompt spaceship
      ;;
    agnoster)
      autoload -U promptinit; promptinit
      prompt agnoster
      ;;
  esac
fi

export PATH="$HOME/.chacharc/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
