# claude-voice

Hear your AI coding agent. **claude-voice** speaks a one-sentence summary of every
response out loud, so you can work hands-light — listen to what the agent did, then
dictate your reply back.

- **100% local TTS by default** — macOS `say` (or Linux `spd-say`/`espeak`). No API keys, no cost.
- **Summaries, not walls of text** — it never reads code, paths, or backticks aloud.
- **One-step install for Claude Code** as a plugin. Codex CLI supported (with a caveat). Cursor is manual.

---

## How it works

Two halves:

| Half | What it does | Portable? |
|------|--------------|-----------|
| **Trigger** | "the agent just finished — here's its response" | Tool-specific |
| **Speaker** | summarize that text → speak it | Same everywhere |

The speaker (`speak-response.sh` + `lib.sh`) is shared. Each tool only needs its own
trigger to feed it the response text. How the spoken line is produced is a swappable
strategy: `speak-response.sh` picks a leaf in `voice/scripts/strategies/` by `VOICE_MODE`,
so adding a mode is just one new file.

The default summarizer is `claude -p` — a one-shot, non-interactive call that **reuses
your existing Claude Code login** (no separate API key).

---

## Requirements

- **`jq`** — `brew install jq` (macOS) / `apt install jq` (Linux)
- **A TTS engine** — macOS has `say` built in; on Linux install `speech-dispatcher` (`spd-say`) or `espeak`
- **`claude` CLI, logged in** — for the default summarizer (reuses your Claude Code auth)
- **`perl`** — only for `marker` mode (preinstalled on macOS & most Linux)

---

## Install — Claude Code (recommended)

```text
/plugin marketplace add uzairaslam196/claude-voice
/plugin install voice
```

That's it. The plugin registers the hooks and bundles the scripts — nothing to edit by
hand. Every response is now summarized and spoken.

> Local testing before publishing: `/plugin marketplace add /absolute/path/to/claude-voice`

---

## Install — Codex CLI (experimental)

```bash
git clone https://github.com/uzairaslam196/claude-voice
cd claude-voice
bash codex/install-codex.sh
```

This adds a `notify` entry to `~/.codex/config.toml` (it won't overwrite an existing one).

> ⚠️ **Verify the payload first.** Codex's `notify` JSON shape varies by version. Before
> relying on it, capture one event (instructions are in the `VERIFY FIRST` comment block
> in `codex/codex-speak.sh`) to confirm the event type and the field holding the
> assistant's text, then adjust the `jq` paths if needed.

---

## Cursor (manual)

Cursor has no agent-completion hook, so there's nothing to attach to. Use the OS instead:
**System Settings → Accessibility → Spoken Content → enable "Speak selection"** and set a
shortcut. Highlight a reply, press the key, hear it.

---

## Configuration

Copy [`config.example`](config.example) to `~/.config/claude-voice/config` and edit.
Every value is optional; environment variables override the file.

| Variable | Default | Meaning |
|----------|---------|---------|
| `VOICE_ENABLED` | `1` | `0` silences voice without uninstalling |
| `VOICE_MODE` | `marker` | strategy leaf in `voice/scripts/strategies/`: `marker` (default — read the agent's 🔊-prefixed final summary line), `summarize` (one-shot call), or `rolling` (stub) |
| `VOICE_NAME` | _(system)_ | macOS voice, e.g. `Samantha`. List with `say -v '?'` |
| `VOICE_SUMMARIZER` | `claude -p` | command used in summarize mode |
| `VOICE_MAX_CHARS` | `4000` | cap on text sent to the summarizer |

### Modes

Each mode is a strategy leaf in `voice/scripts/strategies/`. Adding one = one new file.

- **`marker`** (default) — speaks only the agent's 🔊-prefixed final summary line. Zero extra
  calls, full context for free. The Claude Code plugin injects an instruction asking for the
  line; if it's ever missing, it falls back to "Done. Check the screen." (Claude Code only —
  Codex won't inject.)
- **`summarize`** — feeds each response to `claude -p`, which returns one spoken sentence.
  Always works (incl. Codex), costs a tiny call per turn (your Claude Code plan). Tune cost
  with `VOICE_SUMMARIZER` (e.g. `claude -p --model haiku`).
- **`rolling`** — (stub) history-aware running-summary narration; currently falls back to
  `summarize`.

---

## Talking back (speech-to-text)

There's no inbound-audio hook, so dictate into the prompt box:

- **macOS Dictation** — System Settings → Keyboard → Dictation → On. Double-tap `Fn`,
  speak, it types. Works in any text field (Claude Code, Codex, Cursor), offline.
- For push-to-talk with higher accuracy, pair with `whisper.cpp` + a typer wrapper.

---

## Interrupting speech

- macOS: `killall say`
- Linux (speech-dispatcher): `spd-say -C`

Alias it to a quick key for "stop talking, I've heard enough."

---

## Uninstall

- Claude Code: `/plugin uninstall voice`
- Codex: remove the `notify = [...]` line (marked `# Added by claude-voice`) from `~/.codex/config.toml`
- Config: delete `~/.config/claude-voice/config`

---

## License

MIT — see [LICENSE](LICENSE).
