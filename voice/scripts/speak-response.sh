#!/usr/bin/env bash
# Generic speaker pipeline: response on stdin -> selected strategy produces a line -> speak it.
# Tool-agnostic: used by the Claude Code Stop trigger (cc-speak.sh) and the Codex trigger.
HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0

text=$(cat)
[ -z "$text" ] && exit 0

# Variation point: VOICE_MODE selects a strategy leaf (strategies/<mode>.sh).
strategy="$HERE/strategies/${VOICE_MODE}.sh"
[ -f "$strategy" ] || strategy="$HERE/strategies/summarize.sh"   # safe default

spoken=$(printf '%s' "$text" | bash "$strategy")
[ -n "${VOICE_DEBUG:-}" ] && printf '[claude-voice] mode=%s -> %q\n' "$VOICE_MODE" "$spoken" >> "${TMPDIR:-/tmp}/claude-voice.log"
[ -z "$spoken" ] && exit 0

speak "$spoken"
exit 0
