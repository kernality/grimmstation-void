#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

failures=0

report_failure() {
  printf '[FAIL] %s\n' "$*" >&2
  failures=$((failures + 1))
}

while IFS= read -r -d '' script; do
  bash -n "$script" || report_failure "Syntax: $script"
done < <(find install_scripts config_dotfiles -type f -name '*.sh' -print0)

if command -v shellcheck >/dev/null 2>&1; then
  while IFS= read -r -d '' script; do
    shellcheck -x -S warning "$script" ||
      report_failure "ShellCheck: $script"
  done < <(find install_scripts config_dotfiles -type f -name '*.sh' -print0)
else
  printf '[WARN] shellcheck unavailable; static lint skipped\n'
fi

jq empty install_scripts/db/config_dotfiles.db.json ||
  report_failure "Invalid symlink database JSON"

grep -Rnw install_scripts --include='*.sh' --exclude='validate_repo.sh' -e 'error ' &&
  report_failure "Stale error() calls remain"

grep -Rnw install_scripts --include='*.sh' -e 'run_function' |
  grep -v mini_functions.sh >/dev/null &&
  printf '[INFO] run_function compatibility calls remain\n' || true

grep -qx 'npm' install_scripts/package_lists/dev_pkg_list.txt &&
  report_failure "Invalid standalone npm package remains"

duplicates="$(
  sed 's/#.*//; /^[[:space:]]*$/d' \
    install_scripts/package_lists/*_pkg_list.txt |
    sort | uniq -d
)"
[[ -z "$duplicates" ]] ||
  report_failure "Duplicate packages: $duplicates"

python3 <<'PY' || failures=$((failures + 1))
import json
import os
from pathlib import Path

data = json.loads(
    Path("install_scripts/db/config_dotfiles.db.json").read_text()
)

missing = []
for row in data:
    source = row["config_src"].replace(
        "$HOME/.local/share/config_dotfiles",
        "config_dotfiles",
    )
    if not Path(source).exists() and not Path(source).is_symlink():
        missing.append(f"{row['name']}: {source}")

if missing:
    print("[FAIL] Missing symlink sources:")
    for item in missing:
        print("  " + item)
    raise SystemExit(1)
PY

for include in $(awk '$1 == "include" {print $2}' \
  config_dotfiles/config/sway/config); do
  relative="${include#\~/.config/sway/}"
  [[ -e "config_dotfiles/config/sway/$relative" ]] ||
    report_failure "Missing Sway include: $relative"
done

if command -v sway >/dev/null 2>&1; then
  temp="$(mktemp -d)"
  trap 'rm -rf "$temp"' EXIT

  mkdir -p "$temp/.config"
  ln -s "$ROOT/config_dotfiles/config/sway" "$temp/.config/sway"

  HOME="$temp" sway --validate \
    --config "$ROOT/config_dotfiles/config/sway/config" ||
    report_failure "Sway configuration validation"
fi

if (( failures > 0 )); then
  printf '\n%d validation failure(s)\n' "$failures" >&2
  exit 1
fi

printf '[OK] Repository validation passed\n'
