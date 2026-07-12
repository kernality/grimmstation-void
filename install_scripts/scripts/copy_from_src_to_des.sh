#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
src="$DIR/../../config_dotfiles"
dest="$HOME/.local/share/config_dotfiles"
stage="${dest}.new"
old="${dest}.old"
rollback() {
  rm -rf -- "$stage"
  [[ ! -e "$dest" && -e "$old" ]] && mv -- "$old" "$dest"
}
trap rollback ERR INT TERM
[[ -d "$src" ]] || error "Missing source directory: $src"
mkdir -p "$(dirname "$dest")"
rm -rf -- "$stage" "$old"
cp -a -- "$src" "$stage"
find "$stage/config/custom_scripts" "$stage/config/waybar/scripts" \
  -type f -name '*.sh' -exec chmod 0755 {} +
chmod 0755 "$stage/config/lf/previewer"
[[ -e "$stage/config/waybar/style.css" || -L "$stage/config/waybar/style.css" ]] || \
  ln -s 'themes/waybar_underline/style.css' "$stage/config/waybar/style.css"
[[ -e "$dest" ]] && mv -- "$dest" "$old"
mv -- "$stage" "$dest"
rm -rf -- "$old"
trap - ERR INT TERM
success "Dotfiles deployed atomically"
