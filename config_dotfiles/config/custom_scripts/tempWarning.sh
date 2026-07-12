#!/usr/bin/env bash
set -u
warned=0
read_cpu() {
  local h i label value
  for h in /sys/class/hwmon/hwmon*; do
    [[ -r "$h/name" && "$(cat "$h/name")" == coretemp ]] || continue
    for i in "$h"/temp*_input; do
      label="$(cat "${i%_input}_label" 2>/dev/null || true)"
      [[ "$label" == 'Package id 0' ]] || continue
      read -r value < "$i"
      [[ "$value" =~ ^[0-9]+$ ]] && { printf '%d\n' "$((value/1000))"; return; }
    done
  done
  return 1
}
while sleep 30; do
  temp="$(read_cpu)" || continue
  if (( temp >= 85 && warned == 0 )); then notify-send -u critical "High CPU temperature" "${temp}°C"; warned=1
  elif (( temp <= 78 )); then warned=0; fi
done
