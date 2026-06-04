#!/usr/bin/env bash
# Strategy: summarize the response into one spoken sentence via $VOICE_SUMMARIZER (claude -p).
# Contract: response on stdin -> one spoken line on stdout (empty = silent).
HERE="$(cd "$(dirname "$0")/.." && pwd)"
. "$HERE/lib.sh"

text=$(cat)
clipped=$(printf '%s' "$text" | head -c "$VOICE_MAX_CHARS")
# CLAUDE_VOICE_CHILD=1 marks the spawned `claude -p` so its OWN Stop/UserPromptSubmit
# hooks bail (see cc-speak.sh / inject-instruction.sh) instead of recursing.
printf '%s' "$clipped" | CLAUDE_VOICE_CHILD=1 $VOICE_SUMMARIZER \
  "In ONE spoken sentence, summarize this agent response for me to hear out loud. If it is asking me something or needs my input, make the sentence that question. No code, no file paths, no markdown. Output ONLY the sentence." 2>/dev/null
