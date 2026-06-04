#!/usr/bin/env bash
# Strategy: speak ONLY what the agent wrapped in <speak>...</speak>. Zero LLM calls.
# Relies on inject-instruction.sh (UserPromptSubmit) asking the agent for the tag.
# Contract: response on stdin -> one spoken line on stdout (empty = silent).
text=$(cat)
spoken=$(printf '%s' "$text" | perl -0777 -ne 'print $1 if /<speak>(.*?)<\/speak>/s')
[ -z "$spoken" ] && spoken="Done. Check the screen."
printf '%s' "$spoken"
