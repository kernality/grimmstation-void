#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$DIR/mini_functions.sh"
command -v zsh >/dev/null || error 'zsh was not installed'
zsh_path="$(command -v zsh)"
grep -qxF "$zsh_path" /etc/shells || printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
current="$(getent passwd "$USER" | cut -d: -f7)"
[[ "$current" == "$zsh_path" ]] || sudo chsh -s "$zsh_path" "$USER"
success 'zsh configured as the login shell; it takes effect next login'
