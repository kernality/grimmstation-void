#!/usr/bin/env bash
set -Eeuo pipefail
choice="$(printf 'Log Out\nLock\nSuspend\nRestart\nPower Off\n' | wofi --dmenu --prompt power --width 260 --lines 5)"
locker="$HOME/.config/custom_scripts/lock.sh"
case "$choice" in
  'Log Out') swaymsg exit ;;
  'Lock') "$locker" ;;
  'Suspend') "$locker" && loginctl suspend ;;
  'Restart') loginctl reboot ;;
  'Power Off') loginctl poweroff ;;
  *) exit 0 ;;
esac
