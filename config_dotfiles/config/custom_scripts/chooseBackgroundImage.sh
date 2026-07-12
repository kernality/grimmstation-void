#!/usr/bin/env bash
set -u
dir="$HOME/Pictures/backgrounds"
cache="${XDG_CACHE_HOME:-$HOME/.cache}/grimoire"
mkdir -p "$dir" "$cache"
mapfile -t files < <(find "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -printf '%f\n' | sort)
((${#files[@]})) || { notify-send "Wallpaper" "Add images to $dir"; exit 0; }
selected="$(printf '%s\n' "${files[@]}" | wofi --dmenu -i --prompt Walls --width 500)"
[[ -n "$selected" && -r "$dir/$selected" ]] || exit 0
printf '%s\n' "$selected" > "$cache/wall.txt"
pkill -x swaybg 2>/dev/null || true
swaybg -i "$dir/$selected" -m fill >/dev/null 2>&1 &
