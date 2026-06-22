#!/usr/bin/env python3
"""Render the *current* Claude Code session log to a Markdown or HTML file.

Thin wrapper around ``render_claude_session.py``. It locates the session
transcript for the current working directory and decides where to write the
output, so a skill can save "this session" without the caller hunting for the
``.jsonl`` under ``~/.claude/projects/``.

Session resolution:
    Claude Code stores each session as
    ``~/.claude/projects/<encoded-cwd>/<session-id>.jsonl`` where the encoded
    cwd is the absolute path with every non-alphanumeric char replaced by ``-``.
    The current session id is exposed in the environment as
    ``CLAUDE_CODE_SESSION_ID``; we use it directly. If it is unset (e.g. running
    outside a live session) we fall back to the most-recently-modified ``.jsonl``
    in that directory. Pass ``--session`` to override either way.

Output path rules (matching the skill contract):
    * No name given      -> ``<cwd>/<session-title-or-id>.<ext>``
    * Bare name (no '/')  -> ``<cwd>/<name>.<ext>``  (current project dir)
    * Name with a path    -> used as-is (relative to cwd or absolute)
    * Extension is appended only when the name lacks one.

Usage:
    python save_session.py [NAME] [--html] [--session PATH] [-- ...passthrough]

Examples:
    python save_session.py                  # -> ./<title>.md
    python save_session.py mylog            # -> ./mylog.md
    python save_session.py mylog --html     # -> ./mylog.html
    python save_session.py /tmp/foo.md      # -> /tmp/foo.md
    python save_session.py notes -- --no-tools --tool-output 0
"""
from __future__ import annotations

import argparse
import os
import re
import sys
from pathlib import Path

# Reuse the renderer that lives next to this wrapper.
sys.path.insert(0, str(Path(__file__).resolve().parent))
import render_claude_session as rcs  # noqa: E402


def _project_dir(cwd: Path) -> Path:
    """~/.claude/projects/<encoded-cwd> for the given working directory.

    Claude Code encodes the cwd by replacing every non-alphanumeric character
    (``/``, ``.``, ``_`` …) with ``-`` — e.g. ``/home/gary.shi/chat`` becomes
    ``-home-gary-shi-chat``.
    """
    encoded = re.sub(r"[^a-zA-Z0-9]", "-", str(cwd.resolve()))
    return Path.home() / ".claude" / "projects" / encoded


def _current_session(cwd: Path) -> Path:
    """Resolve the live session transcript for this project.

    Prefer the ``CLAUDE_CODE_SESSION_ID`` env var (authoritative inside a running
    session); fall back to the most-recently-modified ``.jsonl`` otherwise.
    """
    proj = _project_dir(cwd)
    if not proj.is_dir():
        sys.exit(f"No session directory for this project: {proj}")
    sid = os.environ.get("CLAUDE_CODE_SESSION_ID")
    if sid:
        by_id = proj / f"{sid}.jsonl"
        if by_id.is_file():
            return by_id
    sessions = sorted(proj.glob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
    if not sessions:
        sys.exit(f"No .jsonl session logs found under {proj}")
    return sessions[0]


def _slugify(text: str) -> str:
    slug = re.sub(r"[^\w.-]+", "-", text.strip()).strip("-")
    return slug or "claude-session"


def _resolve_output(name: str | None, ext: str, cwd: Path, meta: dict) -> Path:
    if not name:
        base = _slugify(meta.get("title") or meta.get("session_id") or "claude-session")
        return cwd / f"{base}.{ext}"
    p = Path(name)
    # A bare name (no directory component) goes under the current project dir.
    if p.parent == Path("."):
        p = cwd / p.name
    if not p.suffix:
        p = p.with_suffix(f".{ext}")
    return p


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("name", nargs="?", help="Output file name or path (default: session title).")
    parser.add_argument("--html", action="store_true", help="Write HTML instead of Markdown.")
    parser.add_argument("--session", metavar="PATH", help="Explicit session .jsonl (default: current session).")
    parser.add_argument("--no-thinking", action="store_true", help="Omit assistant thinking blocks.")
    parser.add_argument("--no-tools", action="store_true", help="Omit tool calls and results.")
    parser.add_argument("--no-fold", action="store_true", help="Render thinking/tool sections expanded.")
    parser.add_argument("--tool-output", type=int, default=1500, metavar="N",
                        help="Truncate each tool result to N chars (0 = no limit). Default 1500.")
    args = parser.parse_args()

    cwd = Path.cwd()
    session = Path(args.session) if args.session else _current_session(cwd)
    if not session.is_file():
        sys.exit(f"Session log not found: {session}")

    fmt = "html" if args.html else "md"
    meta, turns = rcs.parse_session(
        session,
        show_thinking=not args.no_thinking,
        show_tools=not args.no_tools,
        tool_limit=args.tool_output,
    )
    fold = not args.no_fold
    doc = rcs.render_html(meta, turns, fold=fold) if args.html else rcs.render_markdown(meta, turns, fold=fold)

    out = _resolve_output(args.name, fmt, cwd, meta)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(doc, encoding="utf-8")
    print(f"Wrote {out} ({len(doc):,} chars, {len(turns)} turns) from session {session.name}")


if __name__ == "__main__":
    main()
