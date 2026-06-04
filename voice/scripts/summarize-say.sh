#!/usr/bin/env bash
# Reads an agent response on stdin, produces a short spoken line, speaks it.
# Tool-agnostic: used by both the Claude Code and Codex triggers.

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0

text=$(cat)
[ -z "$text" ] && exit 0

case "$VOICE_MODE" in
  marker)
    # Speak ONLY what the agent wrapped in <speak>...</speak>.
    # Relies on the injected instruction (see inject-instruction.sh).
    spoken=$(printf '%s' "$text" | perl -0777 -ne 'print $1 if /<speak>(.*?)<\/speak>/s')
    [ -z "$spoken" ] && spoken="Done. Check the screen."
    ;;
  *)
    # Default: summarize the whole response with one short call.
    # CLAUDE_VOICE_CHILD=1 marks the spawned `claude -p` so its OWN Stop hook
    # bails out (see cc-speak.sh) — otherwise the hook would recurse.
    clipped=$(printf '%s' "$text" | head -c "$VOICE_MAX_CHARS")
    spoken=$(printf '%s' "$clipped" | CLAUDE_VOICE_CHILD=1 $VOICE_SUMMARIZER \
      "In ONE spoken sentence, summarize this agent response for me to hear out loud. If it is asking me something or needs my input, make the sentence that question. No code, no file paths, no markdown. Output ONLY the sentence." 2>/dev/null)
    [ -n "${VOICE_DEBUG:-}" ] && printf '[claude-voice] summarizer returned: %q\n' "$spoken" >> "${TMPDIR:-/tmp}/claude-voice.log"
    [ -z "$spoken" ] && exit 0
    ;;
esac

speak "$spoken"
exit 0
