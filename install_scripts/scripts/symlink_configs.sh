#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
db="$DIR/../db/config_dotfiles.db.json"
backup="$HOME/.config.backup/$(date +%Y%m%d_%H-%M-%S)"
mkdir -p "$backup"
expand_home() {
  local value=$1
  if [[ "$value" == '$HOME' ]]; then printf '%s\n' "$HOME"
  elif [[ "$value" == '$HOME/'* ]]; then printf '%s/%s\n' "$HOME" "${value#\$HOME/}"
  else printf '%s\n' "$value"
  fi
}
while IFS= read -r row; do
  name="$(jq -r '.name' <<<"$row")"
  src="$(expand_home "$(jq -r '.config_src' <<<"$row")")"
  dst="$(expand_home "$(jq -r '.config_des' <<<"$row")")"
  [[ -e "$src" || -L "$src" ]] || die "Missing source for $name: $src"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    target="$backup/$name"; [[ ! -e "$target" ]] || target="$backup/${name}-$(date +%s%N)"
    mv -- "$dst" "$target"
  elif [[ -L "$dst" ]]; then rm -- "$dst"; fi
  ln -sfn -- "$src" "$dst"
  success "Linked $name"
done < <(jq -c '.[]' "$db")
rmdir "$backup" 2>/dev/null || true

# Install repository-owned desktop entries without replacing the user's
# ~/.local/share/applications directory.
desktop_src="$HOME/.local/share/config_dotfiles/local/share/applications"
desktop_dst="$HOME/.local/share/applications"

if [[ -L "$desktop_dst" ]]; then
 expected="$(readlink -f "$desktop_src" 2>/dev/null || true)"
 actual="$(readlink -f "$desktop_dst" 2>/dev/null || true)"

 if [[ -n "$expected" && "$actual" == "$expected" ]]; then
  # Migrate installations made by the older whole-directory symlink.
  rm -- "$desktop_dst"
 else
  mv -- "$desktop_dst" "$backup/desktop-applications-link"
 fi
fi

mkdir -p -- "$desktop_dst"

while IFS= read -r -d '' desktop_file; do
 install -m 0644 -- "$desktop_file" \
  "$desktop_dst/$(basename "$desktop_file")"
done < <(find "$desktop_src" -maxdepth 1 -type f -name '*.desktop' -print0)

success "Installed desktop application entries"
