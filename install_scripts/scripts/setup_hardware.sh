#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "$DIR/mini_functions.sh"
vendor="$(cat /sys/class/drm/card*/device/vendor 2>/dev/null | grep -m1 '^0x8086$' || true)"
[[ "$vendor" == 0x8086 ]] || error 'Latitude baseline requires an Intel GPU'
sudo xbps-install -Sy void-repo-nonfree
sudo xbps-install -Suy
sudo xbps-install -y mesa-dri mesa-vulkan-intel vulkan-loader intel-video-accel \
  libva-utils intel-ucode linux-firmware-intel thermald
mapfile -t kernels < <(xbps-query -l | awk '$1=="ii" && $2 ~ /^linux[0-9]+\.[0-9]+-[0-9]/ {print $2}' | \
  while IFS= read -r pkgver; do xbps-uhelper getpkgname "$pkgver"; done | sort -u)
((${#kernels[@]})) || error 'No installed versioned kernel package found for initramfs regeneration'
for kernel in "${kernels[@]}"; do
  info "Regenerating initramfs for $kernel"
  sudo xbps-reconfigure -f "$kernel"
done
success "Intel graphics and microcode configured for ${#kernels[@]} installed kernel series"
