# grimoire-void

Void Linux glibc + runit + Sway for a Dell Latitude 5490 with Intel UHD 620. Includes eight neutral workspaces, six Waybar themes, zsh + Starship, PipeWire/WirePlumber, NetworkManager, elogind, Firefox, Neovim, and optional Flatpak and KVM/libvirt.

## Fresh install

During `void-installer`, create your regular user in the `wheel` group, choose a UTF-8 locale, and configure networking. Then run:

```sh
# 1. As root once: install sudo and Git, then authorize wheel.
su -
xbps-install -Suy git sudo
mkdir -p /etc/sudoers.d
printf '%s\n' '%wheel ALL=(ALL:ALL) ALL' > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
exit

# Verify as your regular user.
sudo true && echo OK

# 2. Clone, validate, and install as your regular user.
mkdir -p "$HOME/workstationdots"
git clone https://github.com/kernality/grimoire-void "$HOME/workstationdots/grimoire-void"
bash "$HOME/workstationdots/grimoire-void/install_scripts/validate_repo.sh"
bash "$HOME/workstationdots/grimoire-void/install_scripts/install.sh"

# 3. Reboot only after successful completion.
sudo reboot
```

Using `bash` is intentional: GitHub web uploads may not preserve executable mode bits. Deployment repairs the modes required by Sway and LF.

## What gets configured

The installer updates Void, enables nonfree, installs Intel graphics and microcode, regenerates every installed versioned kernel's initramfs, configures TLP and elogind, PipeWire, packages, dotfiles, zsh, greetd, and runit services. Existing configs are backed up under `~/.config.backup`.

Sway starts only `pipewire`; Void's drop-ins start WirePlumber and pipewire-pulse. elogind owns ACPI power events, so acpid is disabled. gnome-keyring's secrets daemon starts with Sway, but automatic PAM unlocking is not claimed.

## Optional stages

```sh
bash "$HOME/workstationdots/grimoire-void/install_scripts/scripts/install_with_flatpak.sh"
bash "$HOME/workstationdots/grimoire-void/install_scripts/scripts/setup_virtualization.sh"
```

Flatpak uses per-user Flathub. Virtualization enables libvirt services and the default NAT network. Log out and back in afterward for `libvirt` and `kvm` group membership.

## Controls

`Super+Return` terminal, `Super+d` launcher, `Super+b` Firefox, `Super+Shift+Return` files, `Super+1..8` workspaces, `Super+Shift+1..8` move window, `Super+Shift+x` lock, `Super+Shift+e` power, `Print` screenshot, `Super+Print` annotate. Use `Super+Shift+s`, then `b` for Waybar themes, `w` for wallpaper, or `t` for night color.

Apps open on the focused workspace. Put personal assignments in `~/.config/sway/workspaces.local.conf` after inspecting IDs with `swaymsg -t get_tree`; put hardware overrides in `~/.config/sway/local.conf`.

## zsh, Firefox, and Neovim

The installer changes the regular user's login shell to zsh and links `.zshrc`, aliases, and Starship config. Firefox hardening is conservative. After launching Firefox once, optional profile linking is:

```sh
bash ~/.config/custom_scripts/executables/symlinkFirefoxConfig.sh
```

Neovim downloads plugins and Mason tools on first launch. Keep the generated `~/.config/nvim/lazy-lock.json` for identical plugin revisions. Update deliberately with `:Lazy update`.

## Verify after reboot

```sh
sway --validate --config ~/.config/sway/config
sv status dbus elogind NetworkManager bluetoothd polkitd chronyd greetd
wpctl status
vainfo
printf '%s\n' "$SHELL"
```

Expected shell: `/bin/zsh`. For KVM also run `virsh -c qemu:///system list` and `virsh -c qemu:///system net-info default`.
