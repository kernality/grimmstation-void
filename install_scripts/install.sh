#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'
trap 'printf "\n[ERROR] line %s: %s\n" "$LINENO" "$BASH_COMMAND" >&2' ERR
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$DIR/scripts/mini_functions.sh"
(( EUID != 0 )) || error "Run as your regular user, not root."
command -v sudo >/dev/null || error "sudo is required"
sudo -v
info "Synchronising and updating Void"
sudo xbps-install -Suy
source "$DIR/scripts/setup_hardware.sh"
source "$DIR/scripts/setup_power.sh"
source "$DIR/scripts/setup_audio.sh"
source "$DIR/scripts/make_directories.sh"
source "$DIR/scripts/install_with_xbps.sh"
source "$DIR/scripts/copy_from_src_to_des.sh"
source "$DIR/scripts/symlink_configs.sh"
source "$DIR/scripts/setup_shell.sh"
source "$DIR/scripts/setup_login.sh"
source "$DIR/scripts/enable_services.sh"
success "Base setup completed without a hidden stage failure"
info "Flatpak: bash '$DIR/scripts/install_with_flatpak.sh'"
info "KVM: bash '$DIR/scripts/setup_virtualization.sh'"
