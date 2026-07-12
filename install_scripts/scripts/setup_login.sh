#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
xbps-query gnome-keyring >/dev/null 2>&1 || sudo xbps-install -y gnome-keyring
sudo tee /usr/local/bin/start-sway >/dev/null <<'SCRIPT'
#!/bin/sh
set -eu
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=sway
export XDG_SESSION_DESKTOP=sway
export MOZ_ENABLE_WAYLAND=1
export QT_QPA_PLATFORM='wayland;xcb'
export _JAVA_AWT_WM_NONREPARENTING=1
[ -n "${XDG_RUNTIME_DIR:-}" ] || { echo "elogind did not provide XDG_RUNTIME_DIR" >&2; exit 1; }
exec dbus-run-session sway
SCRIPT
sudo chmod 0755 /usr/local/bin/start-sway
sudo mkdir -p /etc/greetd
sudo tee /etc/greetd/config.toml >/dev/null <<'CONF'
[terminal]
vt = 2

[default_session]
command = "tuigreet --remember --remember-session --asterisks --time --greeting 'grimoire // void' --cmd start-sway"
user = "_greeter"
CONF
success "greetd configured for Void's _greeter account"
