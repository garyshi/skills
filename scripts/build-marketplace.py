#!/usr/bin/env python3
"""Generate .claude-plugin/marketplace.json from the skills in this repo.

Every top-level folder with a SKILL.md becomes one Claude Code plugin whose
root is the skill folder itself. The plugin is described entirely by its
marketplace entry ("strict": false), so the skill folders need no plugin.json,
and Claude Code auto-discovers subagents in the skill's agents/ folder.
Per-skill data comes from the SKILL.md frontmatter:

    name, description              standard skill fields
    metadata.version               plugin version (required)
    metadata.short-description     plugin description (falls back to description)
    metadata.category              marketplace category (default: productivity)

Usage: build-marketplace.py [--check]
  --check   exit 1 if marketplace.json is out of date instead of rewriting it
"""

import json
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
MARKETPLACE = REPO / ".claude-plugin" / "marketplace.json"
HEADER = {
    "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
    "name": "garyshi-skills",
    "description": "Gary Shi's personal agent skills, packaged as Claude Code plugins.",
    "owner": {"name": "Gary Shi"},
}


def unquote(value):
    value = value.strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        return value[1:-1]
    return value


def frontmatter(path):
    """Parse the flat keys and the `metadata:` map of a SKILL.md frontmatter.

    Deliberately minimal (no PyYAML dependency): list values such as
    allowed-tools are skipped, which this script never needs.
    """
    lines = path.read_text().splitlines()
    if not lines or lines[0] != "---":
        sys.exit(f"{path}: missing frontmatter")
    fields, metadata, section = {}, {}, None
    for line in lines[1:]:
        if line == "---":
            return fields, metadata
        if not line.strip():
            continue
        indented = line[0] in " \t"
        key, sep, value = line.strip().partition(":")
        if not sep:
            continue
        if not indented:
            section = key
            if value.strip():
                fields[key] = unquote(value)
        elif section == "metadata":
            metadata[key] = unquote(value)
    sys.exit(f"{path}: unterminated frontmatter")


def plugin_entry(skill_dir):
    fields, metadata = frontmatter(skill_dir / "SKILL.md")
    name = fields.get("name", skill_dir.name)
    if name != skill_dir.name:
        sys.exit(f"{skill_dir}/SKILL.md: name '{name}' must match its folder")
    if "version" not in metadata:
        sys.exit(f"{skill_dir}/SKILL.md: missing metadata.version")
    return {
        "name": name,
        "description": metadata.get("short-description") or fields["description"],
        "version": metadata["version"],
        "author": HEADER["owner"],
        "source": f"./{name}",
        "strict": False,
        "skills": ["./"],
        "category": metadata.get("category", "productivity"),
    }


def build():
    skills = sorted(p.parent for p in REPO.glob("*/SKILL.md"))
    marketplace = dict(HEADER, plugins=[plugin_entry(d) for d in skills])
    return json.dumps(marketplace, indent=2) + "\n"


def main():
    text = build()
    if "--check" in sys.argv[1:]:
        if not MARKETPLACE.exists() or MARKETPLACE.read_text() != text:
            print(f"{MARKETPLACE.relative_to(REPO)} is out of date; run scripts/build-marketplace.py")
            sys.exit(1)
        return
    MARKETPLACE.write_text(text)
    print(f"wrote {MARKETPLACE.relative_to(REPO)}")


if __name__ == "__main__":
    main()
