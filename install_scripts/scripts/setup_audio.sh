#!/usr/bin/env bash
SETUP_AUDIO_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SETUP_AUDIO_PATH/mini_functions.sh"

info "Installing the PipeWire audio stack ..."
for pkg in pipewire wireplumber alsa-pipewire libspa-bluetooth rtkit; do
 xbps-query "$pkg" &>/dev/null || sudo xbps-install -y "$pkg" || warning "Skipping $pkg"
done

sudo mkdir -p /etc/pipewire/pipewire.conf.d /etc/alsa/conf.d
link_if_missing() { [[ -e "$2" ]] || sudo ln -s "$1" "$2"; }
link_if_missing /usr/share/examples/wireplumber/10-wireplumber.conf   /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
link_if_missing /usr/share/examples/pipewire/20-pipewire-pulse.conf   /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf
link_if_missing /usr/share/alsa/alsa.conf.d/50-pipewire.conf          /etc/alsa/conf.d/50-pipewire.conf
link_if_missing /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf  /etc/alsa/conf.d/99-pipewire-default.conf

[[ -d /etc/sv/rtkit && ! -e /var/service/rtkit ]] && sudo ln -s /etc/sv/rtkit /var/service/
getent group audio >/dev/null 2>&1 && sudo usermod -aG audio "$USER"

success "PipeWire configured (incl. Bluetooth audio via libspa-bluetooth)."
