#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'printf "\n[ERROR] line %s: %s\n" "$LINENO" "$BASH_COMMAND" >&2' ERR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/scripts/mini_functions.sh"
(( EUID != 0 )) || die "Run as your regular user, not root."
for cmd in sudo xbps-install xbps-query; do command -v "$cmd" >/dev/null || die "Missing: $cmd"; done
sudo -v
stage() { info "$1"; shift; "$@"; }
stage "Updating Void" sudo xbps-install -Suy
stage "Hardware" bash "$DIR/scripts/setup_hardware.sh"
stage "Power" bash "$DIR/scripts/setup_power.sh"
stage "Audio" bash "$DIR/scripts/setup_audio.sh"
stage "Directories" bash "$DIR/scripts/make_directories.sh"
stage "Packages" bash "$DIR/scripts/install_with_xbps.sh"
stage "Deploy dotfiles" bash "$DIR/scripts/copy_from_src_to_des.sh"
stage "Link configs" bash "$DIR/scripts/symlink_configs.sh"
stage "Shell" bash "$DIR/scripts/setup_shell.sh"
stage "Login" bash "$DIR/scripts/setup_login.sh"
stage "Services" bash "$DIR/scripts/enable_services.sh"
success "Base setup completed without a hidden stage failure."
info "Optional Flatpak: bash '$DIR/scripts/install_with_flatpak.sh'"
info "Optional KVM: bash '$DIR/scripts/setup_virtualization.sh'"
info "Reboot, then run the acceptance test in this guide."
