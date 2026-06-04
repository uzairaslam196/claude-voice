#!/usr/bin/env bash
# Claude Code `Stop` hook (trigger): read the finished response from the transcript
# and hand it to the generic speaker pipeline.
# Stop hooks receive JSON on stdin including `.transcript_path` (a JSONL file).
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
{ [ -z "$transcript" ] || [ ! -f "$transcript" ]; } && exit 0

# Normalized input for strategy leaves: response text (piped) + transcript path (env),
# so history-aware leaves (e.g. rolling) can use it; simple leaves ignore it.
export CLAUDE_VOICE_TRANSCRIPT="$transcript"

# Last assistant text block from the JSONL transcript.
text=$(grep '"role":"assistant"' "$transcript" | tail -n 1 \
  | jq -r '.message.content[]? | select(.type=="text") | .text' 2>/dev/null)
[ -z "$text" ] && exit 0

printf '%s' "$text" | bash "$HERE/speak-response.sh"
exit 0
