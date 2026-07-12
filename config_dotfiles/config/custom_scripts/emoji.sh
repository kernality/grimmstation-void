#!/usr/bin/env bash
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/emoji-list.txt"

generate() {
 command -v curl >/dev/null 2>&1 || return 1
 curl -fsSL https://unicode.org/Public/emoji/latest/emoji-test.txt 2>/dev/null \
 | grep 'fully-qualified' \
 | sed 's/.*# //' \
 | awk '{ emoji=$1; $1=""; $2=""; sub(/^ +/,""); print emoji"  "$0 }' \
 > "$CACHE.tmp" 2>/dev/null \
 && [ -s "$CACHE.tmp" ] && mv "$CACHE.tmp" "$CACHE"
}

if [ ! -s "$CACHE" ]; then
 generate || cat > "$CACHE" <<'SEED'
😀  grinning face
😂  face with tears of joy
🙂  slightly smiling face
😊  smiling face with smiling eyes
😍  smiling face with heart-eyes
😎  smiling face with sunglasses
🤔  thinking face
😴  sleeping face
😭  loudly crying face
😡  enraged face
👍  thumbs up
👎  thumbs down
🙏  folded hands
👏  clapping hands
🔥  fire
✨  sparkles
🎉  party popper
💯  hundred points
❤️  red heart
🚀  rocket
💡  light bulb
✅  check mark button
❌  cross mark
⚠️  warning
👀  eyes
🤝  handshake
💀  skull
🤖  robot
🐧  penguin
☕  hot beverage
SEED
fi

choice="$(wofi --dmenu -i --prompt "emoji" --width 480 --lines 12 < "$CACHE" | awk '{print $1}')"
[ -z "$choice" ] && exit 0
printf '%s' "$choice" | wl-copy
if command -v wtype >/dev/null 2>&1; then
 sleep 0.06
 wtype "$choice"
fi
notify-send -u low "Emoji" "Copied $choice" 2>/dev/null
