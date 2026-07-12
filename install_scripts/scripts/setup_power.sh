#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$DIR/mini_functions.sh"
sudo xbps-install -y tlp
[[ -e /var/service/acpid || -L /var/service/acpid ]] && sudo rm -f /var/service/acpid
sudo mkdir -p /etc/elogind/logind.conf.d
sudo tee /etc/elogind/logind.conf.d/10-grimoire.conf >/dev/null <<'CONF'
[Login]
HandleLidSwitch=suspend
HandleLidSwitchExternalPower=suspend
HandlePowerKey=suspend
HandleSuspendKey=suspend
IdleAction=ignore
CONF
getent group video >/dev/null && sudo usermod -aG video "$USER"
success 'TLP and elogind power handling configured'
