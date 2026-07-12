#!/usr/bin/env bash
set -Eeuo pipefail
src="$HOME/.local/share/config_dotfiles/config/firefox"
find_profile() {
  python3 - "$1" <<'PY'
import configparser, pathlib, sys
ini = pathlib.Path(sys.argv[1]); root = ini.parent
c = configparser.RawConfigParser(); c.read(ini)
choices = []
for section in c.sections():
    if section.startswith('Install') and c.has_option(section, 'Default'):
        choices.append((c.get(section, 'Default'), True))
for section in c.sections():
    if section.startswith('Profile') and c.has_option(section, 'Path') and c.get(section, 'Default', fallback='0') == '1':
        choices.append((c.get(section, 'Path'), c.get(section, 'IsRelative', fallback='1') == '1'))
for section in c.sections():
    if section.startswith('Profile') and c.has_option(section, 'Path'):
        choices.append((c.get(section, 'Path'), c.get(section, 'IsRelative', fallback='1') == '1'))
for value, relative in choices:
    p = root / value if relative and not pathlib.Path(value).is_absolute() else pathlib.Path(value)
    if p.is_dir(): print(p); break
PY
}
for root in "${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox" "$HOME/.mozilla/firefox"; do
  ini="$root/profiles.ini"
  [[ -f "$ini" ]] || continue
  profile="$(find_profile "$ini")"
  [[ -n "$profile" && -d "$profile" ]] || continue
  stamp="$(date +%Y%m%d-%H%M%S)"
  for item in user.js chrome; do
    if [[ -e "$profile/$item" || -L "$profile/$item" ]]; then
      mv -- "$profile/$item" "$profile/$item.backup-$stamp"
    fi
    ln -s -- "$src/$item" "$profile/$item"
  done
  notify-send 'Firefox' 'Profile configuration linked'
  exit 0
done
notify-send 'Firefox' 'Launch Firefox once, then rerun this helper'
exit 1
