#!/usr/bin/env bash
set -u
battery="$(upower -e 2>/dev/null | grep -m1 '/battery_' || true)"
[[ -n "$battery" ]] || exit 0
level=""
while sleep 60; do
  info="$(upower -i "$battery" 2>/dev/null)" || continue
  state="$(awk '/state:/ {print $2}' <<<"$info")"
  capacity="$(awk '/percentage:/ {gsub(/%/,"",$2); print int($2)}' <<<"$info")"
  [[ "$capacity" =~ ^[0-9]+$ ]] || continue
  [[ "$state" == discharging ]] || { level=""; continue; }
  if (( capacity <= 10 )); then
    [[ "$level" == critical ]] || notify-send -u critical "Battery critical" "${capacity}% remaining"
    level=critical
  elif (( capacity <= 20 )); then
    [[ -n "$level" ]] || notify-send "Battery low" "${capacity}% remaining"
    level=warning
  elif (( capacity >= 25 )); then level=""; fi
done
