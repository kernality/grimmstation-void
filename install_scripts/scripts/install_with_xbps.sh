#!/usr/bin/env bash
set -Eeuo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/mini_functions.sh"
install_list() {
  local list=$1 pkg
  while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    pkg="${pkg%%#*}"
    pkg="${pkg#"${pkg%%[![:space:]]*}"}"
    pkg="${pkg%"${pkg##*[![:space:]]}"}"
    [[ -n "$pkg" ]] || continue
    if xbps-query -p pkgver "$pkg" >/dev/null 2>&1; then
      info "$pkg already installed"
    else
      info "Installing $pkg"
      sudo xbps-install -y "$pkg"
    fi
  done < "$list"
}
for list in common_pkg_list.txt dev_pkg_list.txt wayland_pkg_list.txt gui_pkg_list.txt; do
  install_list "$DIR/../package_lists/$list"
done
