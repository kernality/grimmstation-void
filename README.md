# grimoire-void
> A complete, laptop-tuned **Void Linux + Sway** desktop, ported from the
> Arch-based [grimmstation](https://codeberg.org/bibjaw99/grimmstation) dotfiles
> and rebuilt for **xbps + runit + elogind**. Launcher **wofi** (tuned to feel
> like rofi), shell **zsh + starship**, login **tuigreet**, audio **PipeWire**,
> a clickable Wi-Fi tray, and full laptop power management. One script turns a
> freshly installed machine into this entire environment.
>
> **Built for:** Dell Latitude 5490 · i5-8250U · Intel UHD 620 · 16 GB · UEFI · ext4
> **Flavour:** Void glibc + runit
> **Theme:** gruvbox material
---
## Gallery
### workflow
![Sway](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/sway.png)
### waybar themes
- to launch the rofi theme selector, press `Super+Shift+s` then `b`
![waybar themes](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/waybarSwitching.gif)
---
## At a glance
Boot → **tuigreet** login → **Sway** (tiling Wayland). `Super` is the modifier:
`Super+d` apps, `Super+Return` terminal, `Super+h/j/k/l` focus, `Super+1..8`
workspaces, `Super+Shift+e` power. Wi-Fi is a tray icon; Bluetooth is
`Super+o` then `b`. Update the system with `up`. That's most of daily use.
## Quick start (after a fresh Void install)
Needs a working network connection already (Ethernet is easiest for this
one-time step — see Section 6 if you only have Wi-Fi).
```sh
# 1. as root once: install sudo, add the sudoers rule for wheel
#    (you're already in the wheel group from void-installer; no relogin needed)
su -
xbps-install -Suy git sudo
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel && chmod 440 /etc/sudoers.d/wheel
exit
#    verify:  sudo true && echo OK
# 2. clone + run
mkdir -p "$HOME/workstationdots"
git clone https://github.com/kernality/grimoire-void "$HOME/workstationdots/grimoire-void"
bash "$HOME/workstationdots/grimoire-void/install_scripts/install.sh"
# 3. reboot
sudo reboot
```
## Table of contents
1. Read this first (Mint → Void)  · 2. Glossary · 3. Requirements ·
4. Make the USB & BIOS · 5. Install Void · 6. First boot & bootstrap ·
7. What the installer does · 8. Log in · 9. Your screen ·
10. The 12 keys · 11. Full keybindings · 12. Workspaces (auto-assign) ·
13. Everyday recipes · 14. The Sway stack (every component) ·
15. wofi (the launcher) · 16. Waybar (the bar) · 17. Notifications ·
18. Lock, idle & screenshots · 19. runit (services) · 20. xbps (packages) ·
21. zsh + starship · 22. Grimm Neovim · 23. Laptop power ·
24. Networking · 25. Bluetooth · 26. Sound · 27. Customising ·
28. Troubleshooting · 29. Cheat sheet · 30. Credits
---
## 1. Read this first (Mint → Void)
Coming from Linux Mint, five things are different; none are hard:
1. **Software installs from one command,** not a store GUI (`xi PKG`). This repo
   does the big first batch for you.
2. **No systemd.** Void uses **runit** (simpler). Section 19.
3. **Rolling release:** no "upgrade to the next version," just `up` regularly.
4. **The window manager tiles:** Sway arranges windows in a grid and is driven
   from the keyboard. Section 10 has the starter keys.
5. **It's Wayland,** the modern display system, already wired for you.
Don't try to make Void behave like Mint. Give it a week; the keyboard-driven
tiling flow becomes fast to use.
## 2. Glossary
- **Compositor / WM:** draws & arranges windows — **Sway**.
- **Wayland:** modern display protocol (replaces X11). **Tiling:** no overlap.
- **runit:** Void's init system. **xbps:** its package manager (like apt).
- **$mod / Super:** the ⊞ key. **greetd/tuigreet:** the login screen.
- **elogind:** power/seat handling (suspend, lid, passwordless reboot).
- **PipeWire:** sound server. **wofi:** app launcher. **Waybar:** top bar.
- **nm-applet:** the Wi-Fi tray icon. **dotfiles:** config files (this repo).
## 3. Requirements
A Dell Latitude 5490 (or similar Intel UEFI laptop), a 4 GB+ USB stick, and an
internet connection for the install. Void **glibc** base image (not musl).
## 4. Make the USB & BIOS
Download the **x86_64 glibc base** ISO from <https://voidlinux.org/download/>.
Write it — on Linux:
`sudo dd if=void-live-*.iso of=/dev/sdX bs=4M status=progress oflag=sync`
(sdX = the USB disk, not a partition); on Windows: Rufus in DD mode.
**Dell 5490 BIOS (tap F2 at the logo):** Secure Boot **Disabled**, SATA
Operation **AHCI** (not RAID, or Linux won't see the SSD), Virtualization
(VT-x) & VT for Direct I/O **Enabled** (for KVM), boot mode **UEFI**. Save, F12
to boot the USB.
## 5. Install Void
Boot the USB, log in `root` / `voidlinux`, run `void-installer`. Choose:
keyboard; connect network; **Source: Network** (current packages); hostname;
locale/timezone; root password; create your user **in the `wheel` group**;
bootloader **GRUB**; guided whole-disk partitioning: ~512 MB EFI (`/boot/efi`,
FAT32) + the rest **ext4** at `/`. Install, `reboot`, remove the USB. You now
have a bare, text-only Void.
## 6. First boot & bootstrap
You're at a text login (no desktop yet, normal). See Quick start above for the
exact commands. In short: become root, install `git sudo`, add the sudoers
rule for `wheel` (you're already a member of that group from void-installer,
so no relogin is needed), then clone and run `install.sh`.
No network yet? Wired usually works (`ping -c2 voidlinux.org`). For Wi-Fi on the
bare system: `wpa_passphrase "SSID" "PASS" > /etc/wpa_supplicant/wpa_supplicant.conf`,
`wpa_supplicant -B -i IFACE -c /etc/wpa_supplicant/wpa_supplicant.conf`,
`dhcpcd IFACE` (find IFACE with `ip link`). Easiest: use Ethernet for the
one-time install.
## 7. What the installer does
`install.sh` runs, in order (safe to re-run; old configs are backed up to
`~/.config.backup/`):
1. **System sync** — brings Void fully current first.
2. **Graphics** — Intel UHD 620 drivers, iHD hardware video decode, CPU
   microcode, thermald.
3. **Power** — TLP battery tuning, elogind lid/power rules, non-root brightness.
4. **Audio** — PipeWire + WirePlumber wiring.
5. **Directories** — screenshots, backgrounds, etc.
6. **Packages** — everything from the four package lists.
7. **Dotfiles** — copied to `~/.local/share/config_dotfiles`, symlinked into
   place.
8. **Shell** — zsh + starship, set as your login shell.
9. **Login** — greetd/tuigreet, elogind session + keyring in PAM.
10. **Services** — networking, bluetooth, power, logging, time, login; plus
    Bluetooth auto-power-on.
Optional: `install_with_flatpak.sh` (Flathub apps), `setup_virtualization.sh`
(KVM/virt-manager). Then `sudo reboot`.
## 8. Log in
**tuigreet** appears (gruvbox yellow), username remembered. Type your password;
the `start-sway` session is preselected (F3 to change). You land in Sway:
wallpaper + top bar, no windows (normal). Then: open a terminal
(`Super+Return`), connect Wi-Fi (tray icon or `nmtui`), verify video decode
(`vainfo` → `iHD`), check battery (`bat`), and test the lid (close/open → resume
locked).
## 9. Your screen
**Top bar (Waybar):** left = launcher icon + workspace numbers + focused window
title; center = clock; right = network, disk, CPU, CPU temp, brightness,
memory, volume, battery, and the **tray** (Wi-Fi icon lives here). Workspaces
1–8 are themed (Section 12).
## 10. The 12 keys
`Super` = ⊞. Everyday actions are single chords.

| Do | Press |
| :--- | :--- |
| Terminal | `Super`+`Return` |
| App launcher | `Super`+`d` |
| Browser | `Super`+`b` |
| Window switcher | `Super`+`` ` `` (backtick) |
| Emoji | `Super`+`e` |
| Power menu | `Super`+`Shift`+`e` |
| Close window | `Super`+`Shift`+`q` |
| Lock | `Super`+`Shift`+`x` |
| Fullscreen | `Super`+`m` |
| Move focus | `Super`+`h/j/k/l` |
| Workspace 1–8 | `Super`+`1..8` |
| Reload Sway | `Super`+`Shift`+`r` |

## 11. Full keybindings
**Apps:** `Super`+`Return` term · `Super`+`b` browser · `Super`+`Shift`+`b`
incognito · `Super`+`Shift`+`Return` files.
**Menus:** `Super`+`d` launcher · `Super`+`Shift`+`d` run · `Super`+`` ` ``
windows · `Super`+`e` emoji · `Super`+`Shift`+`e` power.
**Windows:** `Super`+`h/j/k/l` focus (or arrows) · `+Shift` move · `+Ctrl`
resize · `Super`+`a`/`Super`+`Shift`+`a` split vertical/horizontal ·
`Super`+`Shift`+`o` cycle layout · `Super`+`m` fullscreen · `Super`+`space`
float+center · `Super`+`n` tiling/float focus · `Super`+`u`/`i` focus
parent/child · `Super`+`Shift`+`q` close · `Super`+`Shift`+`r` reload.
**Workspaces:** `Super`+`1..8` go · `Super`+`Shift`+`1..8` send window ·
`Super`+`Tab` / `Alt`+`Tab` next/prev.
**Modes** (press trigger, then a bare letter; `Escape` exits):
- **open app** `Super`+`o` → `p` PDF · `m` music · `b` bluetooth · `a` audio ·
  `w` wallpapers
- **scripts** `Super`+`Shift`+`s` → `b` waybar theme · `t` night light ·
  `w` wallpaper · `x` run a script
- **swap windows** `Super`+`Shift`+`u` → `h/j/k/l`
- **bookmarks** `Super`+`Shift`+`w` → `m` tab · `Shift+m` private · `n` window ·
  `c` category
- **notifications** `Super`+`Shift`+`m` → `m` restore · `Shift+m` dismiss all
**Hardware:** brightness `Super`+`F4/F3`; volume `Super`+`F7/F6/F5`; media
`Super`+`Shift`+arrows; `Print` screenshot; `Super`+`Print` annotate.
Source of truth: `~/.config/sway/keymaps.conf`.
## 12. Workspaces (auto-assign)
Sway has eight numbered workspaces. This build **auto-sorts apps** onto themed
ones via `assign` rules in `~/.config/sway/workspaces.conf`: when an app opens,
Sway moves it to its workspace automatically, so your browser is always "the 2
key," files always "4," and so on.

| WS | Apps | WS | Apps |
| :--- | :--- | :--- | :--- |
| 1 | Terminal | 5 | Chat (Telegram, Vesktop) |
| 2 | Browser | 6 | Design (GIMP, Inkscape) |
| 3 | Dev / database | 7 | Office / PDF |
| 4 | File manager | 8 | System tools / misc |

Rules match on the window's `app_id` with case-insensitive substring regex, so
they work for both native apps (`firefox`) and Flatpaks
(`org.telegram.desktop`). You can always override manually with
`Super+Shift+1..8` to send the focused window anywhere.
## 13. Everyday recipes
- **Open any app:** `Super+d`, type a few letters (fuzzy match), Enter.
- **Two windows side by side:** open one; `Super+Shift+a`; open the second.
- **Jump to a window:** `Super+`` ` ``, type part of its title.
- **Emoji:** `Super+e`, search by name; it types into the focused field and
  copies to the clipboard.
- **Screenshot + annotate:** `Super+Print` (opens swappy). Plain `Print` saves
  full-screen to `~/Pictures/screenshots`.
- **Wallpaper:** drop images into `~/Pictures/backgrounds`, then
  `Super+Shift+s` then `w`.
- **Switch bar theme:** `Super+Shift+s` then `b`.
- **Lock / power:** `Super+Shift+x` / `Super+Shift+e`.
## 14. The Sway stack (every component)
Sway alone only tiles windows; a usable desktop is Sway plus small,
single-purpose Wayland tools. Every piece and why it's here:
**Core & display**
- **sway** — the tiling Wayland compositor (window manager + display server).
- **wayland / wayland-protocols** — the display protocol libraries.
- **xorg-server-xwayland** — runs legacy X11-only apps inside Wayland; also the
  Qt XWayland fallback target.
**Bar, launcher, notifications**
- **Waybar** — the status bar (clock, battery, CPU, volume, tray). Section 16.
- **wofi** — the application launcher and dmenu-style chooser. Section 15.
- **mako** — notification popups. Section 17.
**Wallpaper, lock, idle**
- **swaybg** — sets the wallpaper.
- **swaylock** — the lock screen (always `-f`, so it locks before sleeping).
- **swayidle** — idle actions: lock at 5 min, screen off at 10, lock before
  every suspend.
**Screenshots & clipboard**
- **grim** — captures the screen/region. **slurp** — mouse region select.
- **swappy** — annotate/crop a screenshot. **wl-clipboard** — copy/paste
  (`wl-copy`/`wl-paste`). **wtype** — types characters (used by the emoji
  picker).
**Portals (for Flatpak & screenshare)**
- **xdg-desktop-portal** with **-wlr** (screenshot/screencast) and **-gtk**
  (file dialogs).
**Session, seat & power (the glue)**
- **elogind** — logins, seats, and power events; enables passwordless
  suspend/reboot and lid handling.
- **dbus** — the message bus everything talks over.
- **polkit + mate-polkit** — the "authenticate" prompt; the mate agent runs in
  autostart.
- **gnome-keyring** — stores secrets (Wi-Fi, browser, SSH), auto-unlocked at
  login via PAM.
**Networking**
- **NetworkManager** — connections + saved passwords. **nm-applet** — the tray
  icon to connect graphically.
**Look, input, media**
- **lxappearance** — GTK theme/icon/cursor. **wlsunset** — night light.
- **brightnessctl** — backlight (brightness keys). **playerctl** — media keys.
**Fonts**
- **nerd-fonts-ttf** — icon glyphs for the bar and prompt.
- **noto / dejavu / terminus** — text + emoji coverage.
**Audio**
- **pipewire** — the audio server (playback, capture, Bluetooth, screenshare).
- **wireplumber** — session/routing manager; ships `wpctl` (used by the volume
  keys); its `libspa-bluetooth` module provides Bluetooth audio.
## 15. wofi (the launcher)
wofi is our rofi replacement, tuned to feel the same. Config lives in
`~/.config/wofi/` (`config` + `style.css`).
**Behaviour (rofi-like):** fuzzy, case-insensitive matching (type "ff" → Firefox).
**Navigation:** arrows, or vim `Ctrl+j`/`Ctrl+k`, or emacs `Ctrl+n`/`Ctrl+p`;
`Ctrl+d`/`Ctrl+u` page; `Tab` completes; `Enter` launches; `Escape` cancels.
The same wofi drives two things: the app launcher (`--show drun`) and every
dmenu-style menu (power, emoji, bookmarks, window switcher, theme switcher, all
`--dmenu`). The config sets only global options, so nothing conflicts between
the two. To restyle it, edit `style.css` (gruvbox colours keyed to
`#d8a657`/`#222222`) — no reload needed, wofi reads it fresh each launch.
## 16. Waybar (the bar)
The top bar. Config in `~/.config/waybar/` (symlinked from the active theme in
`waybar_configs/`). Modules: launcher icon, workspaces, window title, clock, and
on the right network/disk/CPU/temp/brightness/memory/volume/battery + a **tray**
(where nm-applet's Wi-Fi icon appears). Switch themes with `Super+Shift+s` then
`b`; every theme's launcher is wired to wofi.
## 17. Notifications
**mako** shows notification popups (top-right). `Super+Shift+m` then `m` restores
the last dismissed; `Shift+m` dismisses all. Style in `~/.config/mako/config`.
## 18. Lock, idle & screenshots
**swayidle** (autostart) locks after 5 min idle, turns the screen off at 10, and
locks before every suspend, all via **swaylock** with `-f` so the lock is up
before sleep. Lock now with `Super+Shift+x`. Screenshots: `Print` (full →
`~/Pictures/screenshots`), `Super+Print` (annotate in **swappy**).
## 19. runit (services)
Void's init system. A service is a directory in `/etc/sv/NAME`; you **enable**
it by symlinking into `/var/service/`, and runit starts it and keeps it alive.

| Task | systemd (Mint) | runit (Void) |
| :--- | :--- | :--- |
| Enable + start | `systemctl enable --now NAME` | `sudo ln -s /etc/sv/NAME /var/service/` |
| Disable | `systemctl disable NAME` | `sudo rm /var/service/NAME` |
| Start / stop | `systemctl start/stop NAME` | `sudo sv up/down NAME` |
| Restart | `systemctl restart NAME` | `sudo sv restart NAME` |
| Status | `systemctl status NAME` | `sudo sv status NAME` |
| View logs | `journalctl -u NAME` | `tail -f /var/log/socklog/*/current` |

Things that differ: **no journalctl** (logs are plain files via `socklog-void`);
**no user services** (that's why PipeWire/swayidle/nm-applet start from Sway
autostart, not `systemctl --user`); **no timers** (use a cron daemon); **logind
is elogind** (gives passwordless suspend/reboot). Note: the bluetooth service is
`bluetoothd`, not `bluetooth`. A service can only be enabled once its package
is installed. The installer already enabled everything this desktop needs.
## 20. xbps (packages)
Void's package manager: fast, one unified repo, rolling.

| Task | apt (Mint) | xbps (Void) | alias |
| :--- | :--- | :--- | :--- |
| Update everything | `apt update && apt upgrade` | `xbps-install -Suy` | `up` |
| Install | `apt install PKG` | `xbps-install PKG` | `xi PKG` |
| Remove | `apt remove PKG` | `xbps-remove PKG` | `xr PKG` |
| Search | `apt search X` | `xbps-query -Rs X` | `search X` |
| Info | `apt show PKG` | `xbps-query -R PKG` |  |
| List installed | `apt list --installed` | `xbps-query -l` | `list` |
| Which pkg owns FILE | `dpkg -S FILE` | `xbps-query -o FILE` |  |
| Clean orphans+cache | `apt autoremove && apt clean` | `xbps-remove -Oo` | `xclean` |

Flags: `-S` sync index · `-u` update · `-y` yes · `-R` remote (query/search) ·
`-o` orphans (query) · `-O` clean cache (remove) · `-f` force. Extra repos:
nonfree is enabled by the installer (Intel microcode); for 32-bit libs add
`void-repo-multilib`. Pick a faster mirror with `sudo xmirror` (alias `mirror`).
Update weekly with `up`; reboot after kernel/driver updates. If an install
"isn't found," the name may have changed — `search` for it.
## 21. zsh + starship
A bash-compatible shell with nicer interactive features, plus a fast prompt.
Everything you know from bash works. You gain: fuzzy tab completion, `Ctrl+r`
history search (fzf), grey autosuggestions from history (`→` accepts), live
command syntax highlighting (green valid / red invalid), and vi keybindings (`Esc`
for command mode). Config: `~/.zshrc`, aliases in `~/.alias`, prompt in
`~/.config/starship.toml`. Want bash back? `chsh -s /bin/bash`.
## 22. Grimm Neovim
##### Start Page
![nvim 1](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/neovim/1.png)
##### File Tree : mini.files
![nvim 2](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/neovim/2.png)
##### LSP Support and Autocompletion support
![nvim 3](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/neovim/3.png)
##### Gitsigns plugin for visual git status
![nvim 4](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/neovim/4.png)
##### Plugin Manager : Lazy and LSP manager : Mason
![nvim 5](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/neovim/5.png)
##### Fuzzy Finder: Snacks.nvim
![nvim 6](https://codeberg.org/bibjaw99/grimmstation-misc/raw/branch/main/screenshots/neovim/6.png)
A full Neovim config. It's modal: Normal mode by default, `i` to insert, `Esc`
to return. **First launch downloads its plugins** (needs internet, ~1 min); let
it finish, then reopen. Included: lazy.nvim (plugins, `:Lazy`), Mason (language
servers, `:Mason`), mini.files (file tree), Snacks.nvim (fuzzy finder), LSP +
completion, Gitsigns, Treesitter. Survival keys: `i`/`Esc`, `:w` save, `:q`
quit, `:wq`, `:q!`, `h/j/k/l` move, `/text` search, `u`/`Ctrl+r` undo/redo,
`dd`/`yy`/`p` cut/copy/paste. Press `Space` (leader) for a shortcut popup. Run
`vimtutor` once to learn the basics.
## 23. Laptop power
Close lid → suspend; open → resume **locked**. Idle 5 min → lock, 10 → screen
off. Power button → suspend (not shutdown, to avoid data loss). Battery
longevity via **TLP** (`power` = `sudo tlp-stat -s`; tune `/etc/tlp.conf`).
Overheat protection via **thermald**. Low-battery warnings at 30% / 20%.
Brightness keys work without root (you're in the `video` group). Clock re-syncs
after resume via **chrony**. Change lid/power behaviour in
`/etc/elogind/logind.conf.d/10-grimoire.conf`.
> No `acpid` here: elogind handles ACPI power events; running both causes
> double-suspend.
## 24. Networking
NetworkManager saves connections system-wide (auto-reconnect, no sudo needed,
your active elogind session authorizes it via polkit). Connect either way:
- **Tray:** click the network icon top-right of Waybar (nm-applet). Pick a
  network, type the password. Right-click → enable/disable, "Edit Connections".
- **Terminal:** `nmtui`, or `nmcli device wifi connect "SSID" password "PASS"`.
## 25. Bluetooth
The adapter powers on at boot (AutoEnable). Open **blueman** (`Super+o` then
`b`): scan, pair (a PIN dialog appears via polkit), connect. Pairings persist
and auto-reconnect. Bluetooth **audio** works through PipeWire (A2DP + headset
profiles via libspa-bluetooth); paired headphones appear as an output in
`wpctl`/pavucontrol automatically.
## 26. Sound
PipeWire starts with your session. Volume keys use **wpctl** (from wireplumber).
Mixer: `wiremix` (TUI) or `pavucontrol` (GUI, `Super+o` then `a`). Silent? Check
you're in the `audio` group (`groups`) and PipeWire is running
(`pgrep -a pipewire`); log out/in after first install.
## 27. Customising
- **Packages installed:** edit `install_scripts/package_lists/*.txt` (`#` =
  comment, blank lines ignored).
- **Display & touchpad:** `~/.config/sway/devices.conf` (preset for the 5490's
  1080p panel + tap-to-click). External monitor: add
  `output HDMI-A-1 { mode 1920x1080@60Hz pos 1920 0 }` (names from
  `swaymsg -t get_outputs`).
- **Launcher look:** `~/.config/wofi/style.css`. **Prompt:**
  `~/.config/starship.toml`. **Shell:** `~/.zshrc`, `~/.alias`.
- **Keybindings:** `~/.config/sway/keymaps.conf`, then `Super+Shift+r`.
- **Battery tuning:** `/etc/tlp.conf`.
Configs are symlinks back into the repo (`~/.local/share/config_dotfiles`), so
editing the live file edits the repo too. After changing a repo dotfile, re-run
`bash install_scripts/scripts/symlink_configs.sh` to relink.
## 28. Troubleshooting
- **sudo: not in the sudoers file** — you skipped the re-login after the
  bootstrap. Log out/in (or `newgrp wheel`); `groups` should list `wheel`.
- **Reboot → black screen, no tuigreet** — `sudo sv status greetd`; if down,
  `sudo ln -s /etc/sv/greetd /var/service/` and check `/etc/greetd/config.toml`.
- **Power menu asks for a password / no seat** — confirm `pam_elogind` in
  `/etc/pam.d/greetd` and `dbus` enabled; you must log in via tuigreet.
- **Resume shows desktop before lock** — `pgrep -a swayidle`; every swaylock
  uses `-f` (this build does).
- **Wi-Fi tray icon missing** — `pgrep -a nm-applet`; it autostarts after a 1s
  delay so Waybar's tray is ready.
- **Brightness keys dead** — `groups | grep video`; log out/in after install.
- **No sound** — `pgrep -a pipewire`; `groups` includes `audio`.
- **Volume keys do nothing** — `command -v wpctl` (ships with wireplumber).
- **No hardware video accel** — `vainfo` should show `iHD`.
- **Keyring keeps prompting** — confirm `pam_gnome_keyring` in
  `/etc/pam.d/greetd`.
- **A wofi menu shows the wrong list** — ensure `~/.config/wofi/config` has no
  `show=`/`mode=` line (the mode must come from the command line).
- **Emoji picker empty first run** — it fetches the list once (needs network) or
  falls back to a seed; refresh with `rm ~/.cache/emoji-list.txt`.
- **Bluetooth off at boot** — `grep -A1 Policy /etc/bluetooth/main.conf` should
  show `AutoEnable=true`.
- **Temp warning silent** — `lm_sensors` is installed; `sudo sensors-detect
  --auto` once if needed.
- **Battery drains fast** — `sudo tlp-stat -s`; tune `/etc/tlp.conf`.
- **A Qt app won't start** — the session exports `QT_QPA_PLATFORM="wayland;xcb"`,
  so it falls back to XWayland; ensure `xorg-server-xwayland` is installed.
- **Keep it healthy** — run `up` weekly.
## 29. Cheat sheet
```
LAUNCH   Super+Return terminal   Super+d launcher   Super+b browser
         Super+`  window switch  Super+e emoji      Super+Shift+e power
WINDOWS  Super+h/j/k/l focus   +Shift move   +Ctrl resize
         Super+m fullscreen    Super+space float   Super+Shift+q close
WORKSPC  Super+1..8 switch     Super+Shift+1..8 send
MODES    Super+o open        Super+Shift+s scripts (b=waybar theme)
         Super+Shift+u swap  Super+Shift+w bookmarks  Super+Shift+m notify
AUDIO    Super+F7/F6/F5 volume (wpctl)   Super+F4/F3 brightness
NET/BT   Wi-Fi tray icon (click)   Super+o b = blueman
SYSTEM   Super+Shift+x lock   Print/Super+Print screenshot
         Super+Shift+r reload sway
SHELL    up update  xi PKG install  search X  bat  power
SERVICE  sudo sv status NAME   sudo ln -s /etc/sv/NAME /var/service/
```
## 30. Credits
Dotfiles and Sway design by **bibjaw99** (grimmstation). Void port
(grimoire-void) and install tooling adapted for the Dell Latitude 5490: xbps +
runit + elogind, wofi tuned to rofi's feel, zsh + starship, PipeWire, tuigreet
+ keyring, NetworkManager tray, full laptop power management, Flatpak + KVM.
