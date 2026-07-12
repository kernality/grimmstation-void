#!/usr/bin/env bash
set -Eeuo pipefail
root="$HOME/.local/share/config_dotfiles/config/waybar"
swaymsg mode default >/dev/null 2>&1 || true
labels=("Block 1" "Block 2" "Block 3" "Block 4" "Floating" "Underline")
selected="$(printf '%s\n' "${labels[@]}" | wofi --dmenu -i --prompt 'Waybar theme' --width 360 --lines 6)"
[[ -n "$selected" ]] || exit 0
case "$selected" in
  'Block 1') theme=waybar_block_1 ;; 'Block 2') theme=waybar_block_2 ;;
  'Block 3') theme=waybar_block_3 ;; 'Block 4') theme=waybar_block_4 ;;
  'Floating') theme=waybar_floating ;; 'Underline') theme=waybar_underline ;;
  *) notify-send -u critical 'Waybar' 'Unknown theme'; exit 1 ;;
esac
target="$root/themes/$theme/style.css"
[[ -r "$target" ]] || { notify-send -u critical 'Waybar' 'Theme file is missing'; exit 1; }
tmp="$root/.style.css.$$.new"
ln -s "themes/$theme/style.css" "$tmp"
mv -Tf -- "$tmp" "$root/style.css"
swaymsg reload >/dev/null
notify-send 'Waybar' "Theme: $selected"
