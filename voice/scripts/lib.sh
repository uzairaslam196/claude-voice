#!/usr/bin/env bash
# Shared config + portable TTS. Sourced by every speak script.
#
# Config precedence: environment variables override the values set in
# ~/.config/claude-voice/config (if present), which override these defaults.

CFG="${XDG_CONFIG_HOME:-$HOME/.config}/claude-voice/config"
[ -f "$CFG" ] && . "$CFG"

: "${VOICE_ENABLED:=1}"            # 1 = speak, 0 = silent (toggle without uninstalling)
: "${VOICE_MODE:=marker}"          # marker (default) | summarize | rolling — selects a strategy leaf in scripts/strategies/
: "${VOICE_NAME:=}"                # macOS `say -v` voice; empty = system default
: "${VOICE_SUMMARIZER:=claude -p}" # command used in summarize mode
: "${VOICE_MAX_CHARS:=4000}"       # cap on text sent to the summarizer

# speak <text> — render text to audio via the best available LOCAL TTS engine.
# macOS: say (built-in). Linux: spd-say (speech-dispatcher) or espeak.
speak() {
  [ "$VOICE_ENABLED" = "1" ] || return 0
  local msg="$1"
  [ -z "$msg" ] && return 0
  if command -v say >/dev/null 2>&1; then
    say ${VOICE_NAME:+-v "$VOICE_NAME"} "$msg"
  elif command -v spd-say >/dev/null 2>&1; then
    spd-say -w "$msg"
  elif command -v espeak >/dev/null 2>&1; then
    espeak "$msg"
  fi
}
