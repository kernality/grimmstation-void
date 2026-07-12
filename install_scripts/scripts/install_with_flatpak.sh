#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
for pkg in flatpak xdg-desktop-portal xdg-desktop-portal-gtk; do
  xbps-query -p pkgver "$pkg" >/dev/null 2>&1 || sudo xbps-install -y "$pkg"
done
flatpak remotes --user --columns=name | grep -qx flathub || \
  flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
while IFS= read -r app || [[ -n "$app" ]]; do
  app="${app%%#*}"
  app="${app#"${app%%[![:space:]]*}"}"
  app="${app%"${app##*[![:space:]]}"}"
  [[ -n "$app" ]] || continue
  flatpak info --user "$app" >/dev/null 2>&1 || flatpak install --user -y flathub "$app"
done < "$DIR/../package_lists/flatpak_pkg_list.txt"
success "Per-user Flatpak apps installed"
