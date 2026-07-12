#!/usr/bin/env bash
set -Eeuo pipefail
pgrep -x swaylock >/dev/null && exit 0
image="$HOME/.config/walls/lock.png"
if [[ -r "$image" ]]; then
  exec swaylock --daemonize --image "$image"
fi
exec swaylock --daemonize --color 222222
