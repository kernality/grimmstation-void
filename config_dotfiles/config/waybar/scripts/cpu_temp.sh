#!/usr/bin/env bash
set -u
temp=""
for h in /sys/class/hwmon/hwmon*; do
  [[ -r "$h/name" && "$(cat "$h/name")" == coretemp ]] || continue
  for input in "$h"/temp*_input; do
    [[ "$(cat "${input%_input}_label" 2>/dev/null || true)" == 'Package id 0' ]] || continue
    value="$(cat "$input")"
    [[ "$value" =~ ^[0-9]+$ ]] && temp=$((value/1000))
    break 2
  done
done
if [[ -z "$temp" ]]; then
  printf '{"text":" N/A","class":"unknown"}\n'
elif (( temp >= 85 )); then
  printf '{"text":" %d°C","class":"critical"}\n' "$temp"
else
  printf '{"text":" %d°C","class":"normal"}\n' "$temp"
fi
