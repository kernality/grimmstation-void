#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() { printf '[FAIL] %s\n' "$*" >&2; exit 1; }
warn() { printf '[WARN] %s\n' "$*" >&2; }

[[ -f "$ROOT/install_scripts/install.sh" ]] || fail 'install.sh is missing'
[[ -f "$ROOT/install_scripts/db/config_dotfiles.db.json" ]] || fail 'deployment database is missing'
[[ -f "$ROOT/config_dotfiles/config/custom_scripts/lock.sh" ]] || fail 'lock helper is missing'
[[ -e "$ROOT/config_dotfiles/config/waybar/style.css" || -L "$ROOT/config_dotfiles/config/waybar/style.css" ]] || fail 'Waybar default style is missing'
[[ -f "$ROOT/config_dotfiles/config/waybar/config.jsonc" ]] || fail 'Waybar shared config is missing'
[[ -f "$ROOT/config_dotfiles/zshrc" ]] || fail 'zsh configuration is missing'
[[ -f "$ROOT/config_dotfiles/config/starship.toml" ]] || fail 'Starship configuration is missing'

while IFS= read -r file; do
  bash -n "$file" || fail "Bash syntax error: $file"
done < <(find "$ROOT/install_scripts" "$ROOT/config_dotfiles/config/custom_scripts" \
  "$ROOT/config_dotfiles/config/waybar/scripts" -type f -name '*.sh' -print)

! grep -Rqs 'config/waybar_configs' "$ROOT/install_scripts/scripts" "$ROOT/install_scripts/install.sh" || fail 'stale waybar_configs reference remains'
grep -Fq 'elif [[ "$value" == '\''$HOME/'\''* ]]' "$ROOT/install_scripts/scripts/symlink_configs.sh" || \
  fail 'literal $HOME expansion guard is missing'
grep -Fq 'zshrc' "$ROOT/install_scripts/db/config_dotfiles.db.json" || fail 'zshrc is absent from deployment database'
grep -Fq 'starship.toml' "$ROOT/install_scripts/db/config_dotfiles.db.json" || fail 'Starship is absent from deployment database'

if command -v python3 >/dev/null 2>&1; then
  python3 -m json.tool "$ROOT/install_scripts/db/config_dotfiles.db.json" >/dev/null || fail 'invalid deployment JSON'
elif command -v jq >/dev/null 2>&1; then
  jq -e . "$ROOT/install_scripts/db/config_dotfiles.db.json" >/dev/null || fail 'invalid deployment JSON'
else
  warn 'python3/jq unavailable on this bare system; JSON is validated later after jq is installed'
fi

if command -v zsh >/dev/null 2>&1; then
  zsh -n "$ROOT/config_dotfiles/zshrc" || fail 'zsh syntax error'
else
  warn 'zsh is not installed yet; zsh syntax validation is deferred to installation'
fi

if command -v luac >/dev/null 2>&1; then
  while IFS= read -r file; do luac -p "$file" || fail "Lua syntax error: $file"; done \
    < <(find "$ROOT/config_dotfiles/config/nvim" -type f -name '*.lua' -print)
else
  warn 'luac unavailable; Lua parsing check skipped'
fi

if command -v sway >/dev/null 2>&1; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  mkdir -p "$tmp/.config"
  cp -a "$ROOT/config_dotfiles/config/sway" "$tmp/.config/sway"
  HOME="$tmp" sway --validate --config "$tmp/.config/sway/config" >/dev/null || fail 'Sway configuration is invalid'
else
  warn 'Sway is not installed yet; Sway runtime validation is deferred until after installation'
fi

printf 'Repository validation passed.\n'
