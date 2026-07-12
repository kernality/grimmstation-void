#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
for pkg in pipewire wireplumber alsa-pipewire libspa-bluetooth rtkit; do
  xbps-query "$pkg" >/dev/null 2>&1 || sudo xbps-install -y "$pkg"
done
sudo mkdir -p /etc/pipewire/pipewire.conf.d /etc/alsa/conf.d
link_required() {
  [[ -e "$1" ]] || error "Missing packaged example: $1"
  sudo ln -sfn "$1" "$2"
}
link_required /usr/share/examples/wireplumber/10-wireplumber.conf \
  /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
link_required /usr/share/examples/pipewire/20-pipewire-pulse.conf \
  /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf
link_required /usr/share/alsa/alsa.conf.d/50-pipewire.conf \
  /etc/alsa/conf.d/50-pipewire.conf
link_required /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf \
  /etc/alsa/conf.d/99-pipewire-default.conf
[[ -d /etc/sv/rtkit ]] && sudo ln -sfn /etc/sv/rtkit /var/service/rtkit
success "PipeWire configured; Sway should start only pipewire"
