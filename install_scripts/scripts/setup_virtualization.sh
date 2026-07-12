#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
grep -Eq '(vmx|svm)' /proc/cpuinfo || error "Enable Intel VT-x in firmware first"
mapfile -t packages < <(grep -Ev '^[[:space:]]*(#|$)' "$DIR/../package_lists/virt_pkg_list.txt")
sudo xbps-install -y "${packages[@]}"
for service in dbus virtlockd virtlogd libvirtd; do
  [[ -d "/etc/sv/$service" ]] || error "Missing service: $service"
  sudo ln -sfn "/etc/sv/$service" "/var/service/$service"
  sudo sv up "$service"
done
for group in libvirt kvm; do
  getent group "$group" >/dev/null && sudo usermod -aG "$group" "$USER"
done
mkdir -p "$HOME/.config/libvirt"
printf 'uri_default = "qemu:///system"\n' > "$HOME/.config/libvirt/libvirt.conf"
for _ in {1..30}; do
  sudo virsh -c qemu:///system list >/dev/null 2>&1 && break
  sleep 1
done
sudo virsh -c qemu:///system list >/dev/null || error "libvirt did not become ready"
if ! sudo virsh -c qemu:///system net-info default >/dev/null 2>&1; then
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  cat >"$tmp" <<'XML'
<network>
  <name>default</name>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp><range start='192.168.122.2' end='192.168.122.254'/></dhcp>
  </ip>
</network>
XML
  sudo virsh -c qemu:///system net-define "$tmp" >/dev/null
fi
sudo virsh -c qemu:///system net-autostart default >/dev/null
if ! sudo virsh -c qemu:///system net-start default >/dev/null 2>&1; then
  sudo virsh -c qemu:///system net-info default | grep -Eq 'Active:[[:space:]]+yes' || error "Default NAT network failed"
fi
success "Virtualization ready; log out and back in for group membership"
