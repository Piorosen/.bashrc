
# >>> current-user-zsh-pin >>>
if [[ -o interactive ]] && [[ "${USER:-}" == "chacha" ]] && [[ -z "${ZSH_VERSION:-}" ]] && command -v zsh >/dev/null 2>&1; then
  exec zsh -l
fi
# <<< current-user-zsh-pin <<<
