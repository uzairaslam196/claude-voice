#!/usr/bin/env bash
# Strategy (STUB — not yet implemented): history-aware narration via a running summary.
#
# Contract (same as every leaf): response on stdin -> one spoken line on stdout.
# Intended O(1)-tokens/turn design (does NOT re-send the transcript):
#   1. read prior running summary from a state file
#      (e.g. ${XDG_STATE_HOME:-$HOME/.local/state}/claude-voice/<session>.summary)
#   2. feed `claude -p` BOTH (running summary + this response); ask for
#      (a) the spoken line and (b) an updated running summary
#   3. write the updated summary back to the state file
#   4. print only the spoken line
# The trigger has the session id + $CLAUDE_VOICE_TRANSCRIPT available to pass in.
#
# Until built, delegate to summarize so selecting `rolling` never goes silent.
HERE="$(cd "$(dirname "$0")/.." && pwd)"
exec bash "$HERE/strategies/summarize.sh"
