#!/usr/bin/env bash
# Strategy: speak ONLY the agent's 🔊-prefixed final summary line. Zero LLM calls.
# Relies on inject-instruction.sh (UserPromptSubmit) asking the agent for that line.
# Contract: response on stdin -> one spoken line on stdout (empty = silent).
text=$(cat)
# Grab the LAST line that starts with the speaker emoji; speak the text after it.
spoken=$(printf '%s' "$text" | perl -CSD -ne 'print "$1\n" if /^\s*\x{1F50A}\s*(.+?)\s*$/' | tail -n 1)
[ -z "$spoken" ] && spoken="Done. Check the screen."
printf '%s' "$spoken"
