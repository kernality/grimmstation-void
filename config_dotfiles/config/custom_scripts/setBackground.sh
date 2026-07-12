#!/usr/bin/env bash
set -u
cache="${XDG_CACHE_HOME:-$HOME/.cache}/grimoire"
mkdir -p "$cache"
wall="$HOME/.config/walls/wall.png"
if [[ -s "$cache/wall.txt" ]]; then
  candidate="$HOME/Pictures/backgrounds/$(cat "$cache/wall.txt")"
  [[ -r "$candidate" ]] && wall="$candidate"
fi
pkill -x swaybg 2>/dev/null || true
[[ -r "$wall" ]] && exec swaybg -i "$wall" -m fill
exec swaybg -c '#222222'
