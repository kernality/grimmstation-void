#!/usr/bin/env bash
set -u
(($#)) || { notify-send "Terminal launcher" "No command supplied"; exit 1; }
command -v "$1" >/dev/null || { notify-send "Missing command" "$1"; exit 1; }
footclient -e "$@" >/dev/null 2>&1 &
