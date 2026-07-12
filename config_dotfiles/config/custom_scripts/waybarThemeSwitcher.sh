#!/usr/bin/env bash

switch_waybar_themes() {
  local waybar_themes_directory="$HOME/.local/share/config_dotfiles/config/waybar_configs"
  local waybar_config_directory="$HOME/.config/waybar"
  local waybar_themes
  local selected_waybar_theme
  local selected_path

  # Store theme directories
  mapfile -t waybar_themes < <(
    find "$waybar_themes_directory" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"
  )

  # Wofi theme selection prompt
  selected_waybar_theme="$(
    printf "%s\n" "${waybar_themes[@]}" |
    sort |
    wofi --dmenu -i --prompt "Themes" --width 400
  )"

  # Exit if nothing selected
  [[ -n "$selected_waybar_theme" ]] || return 0

  # Selected theme path
  selected_path="$waybar_themes_directory/$selected_waybar_theme"

  # Ensure theme exists
  if [[ ! -d "$selected_path" ]]; then
    notify-send "Waybar" "Config \"$selected_waybar_theme\" not found"
    return 1
  fi

  # Skip if already active
  if [[ -L "$waybar_config_directory" ]] &&
     [[ "$(readlink -f "$waybar_config_directory")" == "$(readlink -f "$selected_path")" ]]; then
    notify-send "Waybar" "Already using: $selected_waybar_theme"
    return 0
  fi

  # Update symlink
  ln -sfn "$selected_path" "$waybar_config_directory"

  # Restart Waybar
  pkill -x waybar 2>/dev/null || true
  sleep 1

  # Reload depending on compositor
  if pgrep -x sway >/dev/null; then
    swaymsg reload
  else
    waybar & disown
  fi
}

switch_waybar_themes
