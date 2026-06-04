#!/usr/bin/env bash
# Claude Code `Stop` hook: read the finished response from the transcript and speak it.
# Stop hooks receive JSON on stdin including `.transcript_path` (a JSONL file).

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // empty')
{ [ -z "$transcript" ] || [ ! -f "$transcript" ]; } && exit 0

# Last assistant text block from the JSONL transcript.
text=$(grep '"role":"assistant"' "$transcript" | tail -n 1 \
  | jq -r '.message.content[]? | select(.type=="text") | .text' 2>/dev/null)
[ -z "$text" ] && exit 0

printf '%s' "$text" | "$HERE/summarize-say.sh"
exit 0
