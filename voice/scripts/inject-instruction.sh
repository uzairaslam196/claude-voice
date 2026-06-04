#!/usr/bin/env bash
# Claude Code `UserPromptSubmit` hook.
#
# In MARKER mode, ask the agent to wrap a short spoken summary in <speak>...</speak>
# so cc-speak.sh can read just that aloud (zero extra summarizer calls).
#
# A UserPromptSubmit hook's stdout is appended to the model's context, so we emit
# the instruction only when it's actually needed. In summarize mode we print
# nothing (the summarizer handles everything downstream).

HERE="$(cd "$(dirname "$0")" && pwd)"
. "$HERE/lib.sh"

[ "$VOICE_ENABLED" = "1" ] || exit 0
[ "$VOICE_MODE" = "marker" ] || exit 0

cat <<'EOF'
[voice mode] At the very end of your response, append a line wrapped in tags:
<speak> one or two plain spoken sentences: what you did or found, and any
decision I must make. If you are asking me something, that question goes here.
No code, no file paths, no markdown. Always include it, even for short replies. </speak>
EOF
exit 0
