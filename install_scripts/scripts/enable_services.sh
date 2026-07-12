#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
enable() {
  [[ -d "/etc/sv/$1" ]] || error "Required service missing: $1"
  sudo ln -sfn "/etc/sv/$1" "/var/service/$1"
}
for service in dhcpcd wpa_supplicant; do
  [[ -e "/var/service/$service" || -L "/var/service/$service" ]] && sudo rm -f "/var/service/$service"
done
[[ -e /var/service/agetty-tty2 || -L /var/service/agetty-tty2 ]] && sudo rm -f /var/service/agetty-tty2
for service in dbus elogind NetworkManager bluetoothd polkitd chronyd socklog-unix nanoklogd greetd; do
  enable "$service"
done
for service in tlp thermald rtkit; do
  [[ -d "/etc/sv/$service" ]] && sudo ln -sfn "/etc/sv/$service" "/var/service/$service"
done
for group in network socklog; do
  getent group "$group" >/dev/null && sudo usermod -aG "$group" "$USER"
done
if [[ -f /etc/bluetooth/main.conf ]]; then
  grep -q '^\[Policy\]' /etc/bluetooth/main.conf || printf '\n[Policy]\n' | sudo tee -a /etc/bluetooth/main.conf >/dev/null
  if grep -q '^AutoEnable=' /etc/bluetooth/main.conf; then
    sudo sed -i 's/^AutoEnable=.*/AutoEnable=true/' /etc/bluetooth/main.conf
  else
    sudo sed -i '/^\[Policy\]/a AutoEnable=true' /etc/bluetooth/main.conf
  fi
fi
success "Core runit services enabled"
