#!/usr/bin/env bash
# Claude Code `Stop` hook (trigger): take the finished response and hand it to the
# speaker pipeline.
#
# The Stop payload (stdin JSON) includes `.last_assistant_message` — the response
# that JUST finished. Use it directly: race-free and unambiguous. Re-parsing the
# transcript tail is fragile — at Stop time the last line is often a tool_use /
# attachment / tool_result, so `tail -n 1` grabs the wrong block (or nothing).
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0
# Recursion guard: an LLM strategy spawns `claude -p`, itself a Claude Code run whose
# Stop hook would re-enter this script. The strategy marks that child with
# CLAUDE_VOICE_CHILD=1 (see strategies/summarize.sh); bail when we're inside it.
[ -n "${CLAUDE_VOICE_CHILD:-}" ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')

# Normalized input for strategy leaves: transcript path in env so history-aware
# leaves (e.g. rolling) can use it; simple leaves ignore it.
export CLAUDE_VOICE_TRANSCRIPT="$transcript"

# Primary source: the finished message from the Stop payload (string OR message object).
text=$(printf '%s' "$input" | jq -r '
  (.last_assistant_message
   | if type == "string" then .
     elif type == "object" then ([.content[]? | select(.type == "text") | .text] | join("\n"))
     else empty end) // empty' 2>/dev/null)

# Fallback (older Claude Code without last_assistant_message): last assistant text
# block from the transcript.
if [ -z "$text" ] && [ -n "$transcript" ] && [ -f "$transcript" ]; then
  text=$(grep '"role":"assistant"' "$transcript" | tail -n 1 \
    | jq -r '.message.content[]? | select(.type == "text") | .text' 2>/dev/null)
fi

[ -z "$text" ] && exit 0

printf '%s' "$text" | bash "$HERE/speak-response.sh"
exit 0
