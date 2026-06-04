#!/usr/bin/env bash
# Claude Code `UserPromptSubmit` hook.
#
# In MARKER mode, ask the agent to append a short 🔊-prefixed final summary line
# so cc-speak.sh can read just that aloud (zero extra summarizer calls).
#
# A UserPromptSubmit hook's stdout is appended to the model's context, so we emit
# the instruction only when it's actually needed. In summarize mode we print
# nothing (the summarizer handles everything downstream).

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0
[ -n "${CLAUDE_VOICE_CHILD:-}" ] && exit 0
[ "$VOICE_MODE" = "marker" ] || exit 0

cat <<'EOF'
[voice mode] At the VERY END of your response, on its own line, append a spoken
summary prefixed with the speaker emoji 🔊 — one or two plain spoken sentences:
what you did or found, and any decision I must make (if you're asking me something,
put that question here). No code, no file paths, no markdown, no asterisks or
backticks. Always include this line, even for short replies. Example:

🔊 I fixed the calendar token bug and opened a pull request — want me to deploy it?
EOF
exit 0
