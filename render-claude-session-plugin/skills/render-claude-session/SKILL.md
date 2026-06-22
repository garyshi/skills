---
name: render-claude-session
description: Save a readable transcript of the current Claude Code session to a Markdown or HTML file. Use when asked to export, render, save, or dump the current session/conversation/chat log to a file. Default output is Markdown; pass --html for HTML. Writes under the current project directory unless the given name includes a path.
---

# Render Session Log

## Instructions

When this skill is invoked:

1. If `ARGUMENTS` is provided, use it as the output name.
2. If `ARGUMENTS` is empty or absent, use `session-log` as the output name.
3. Run the script immediately — do not ask the user for a filename.
4. After the script exits, report the written path back to the user.

Renders the **current** Claude Code session transcript into a clean Markdown (default)
or HTML file with a table of contents, collapsible thinking/tool sections, and a
token-usage + estimated-cost summary.

## How it works

Claude Code stores each session as `~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`.
The wrapper identifies the live session from the `CLAUDE_CODE_SESSION_ID` environment
variable (set inside every running session), renders it, and writes the result. If that
variable is unset, it falls back to the most-recently-modified `.jsonl` for the current
working directory.

## Usage

Run the wrapper using the base directory path shown above (not as a shell variable — paste the literal path):

```bash
python <SKILL_BASE_DIR>/scripts/save_session.py [NAME] [--html] [options]
```

### Output path rules

| Argument | Result |
| --- | --- |
| *(none)* | `<cwd>/<session-title>.md` |
| `mylog` | `<cwd>/mylog.md` (bare name → current project dir) |
| `mylog --html` | `<cwd>/mylog.html` |
| `/tmp/foo.md` or `sub/foo.md` | used as-is (name contains a path) |

The extension is appended only when the name lacks one. `--html` switches the format
(and the default extension) to HTML.

### Examples

```bash
# Markdown to ./<session-title>.md
python <SKILL_BASE_DIR>/scripts/save_session.py

# Markdown to ./session-notes.md
python <SKILL_BASE_DIR>/scripts/save_session.py session-notes

# HTML to ./session.html
python <SKILL_BASE_DIR>/scripts/save_session.py session --html

# Explicit path is respected
python <SKILL_BASE_DIR>/scripts/save_session.py /tmp/export.md
```

### Options

- `--html` — write HTML instead of Markdown.
- `--no-thinking` — omit assistant thinking blocks.
- `--no-tools` — omit tool calls and their results.
- `--no-fold` — render thinking/tool sections expanded instead of collapsed.
- `--tool-output N` — truncate each tool result to N chars (default 1500, `0` = no limit).
- `--session PATH` — render a specific `.jsonl` instead of the current session.

After running, report the written path (printed on stdout) back to the user.

## Notes

- Requires the `click`-free wrapper plus `render_claude_session.py` (both bundled in
  `scripts/`); no extra dependencies.
- If multiple sessions are running for the same directory, the most-recently-active one
  is chosen. Use `--session` to target a specific transcript.
