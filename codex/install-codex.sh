#!/usr/bin/env bash
# Wire Codex's `notify` setting to the voice speaker, without clobbering existing config.
set -u

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SPEAKER="$REPO/codex/codex-speak.sh"
CONFIG="$HOME/.codex/config.toml"

mkdir -p "$HOME/.codex"
touch "$CONFIG"
chmod +x "$SPEAKER" "$REPO"/voice/scripts/*.sh 2>/dev/null

LINE="notify = [\"bash\", \"$SPEAKER\"]"

if grep -qE '^[[:space:]]*notify[[:space:]]*=' "$CONFIG"; then
  echo "⚠️  $CONFIG already defines 'notify' — not overwriting it."
  echo "    To enable voice, set it to:"
  echo
  echo "    $LINE"
  echo
  exit 0
fi

printf '\n# Added by claude-voice\n%s\n' "$LINE" >> "$CONFIG"
echo "✅ Codex voice wired up in $CONFIG"
echo
echo "   IMPORTANT: verify the notify payload before relying on it."
echo "   See the 'VERIFY FIRST' block in:"
echo "   $SPEAKER"
