#!/usr/bin/env bash
# Codex CLI `notify` program.
# Codex passes the event as a JSON STRING in ARGV[1] (not stdin).

HERE="$(cd "$(dirname "$0")" && pwd)"
LIB="$HERE/../voice/scripts"
. "$LIB/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

payload="${1:-}"
[ -z "$payload" ] && exit 0

# ---------------------------------------------------------------------------
# ⚠️  VERIFY FIRST — Codex's notify payload shape varies by version.
# Capture it once to confirm the event type and the field holding the text:
#
#   printf '%s\n' "$payload" >> /tmp/codex-notify.log; exit 0
#
# Inspect /tmp/codex-notify.log, then adjust the jq paths below to match.
# ---------------------------------------------------------------------------

type=$(printf '%s' "$payload" | jq -r '.type // empty')
[ "$type" != "agent-turn-complete" ] && exit 0

text=$(printf '%s' "$payload" | jq -r \
  '."last-assistant-message" // .last_assistant_message // .message // empty')
[ -z "$text" ] && exit 0

printf '%s' "$text" | bash "$LIB/speak-response.sh"
exit 0
