# garyshi-skills

Personal agent skills for Claude Code, Codex, Cursor, Grok and Antigravity. Each top-level folder is one skill in the standard `SKILL.md` format. For Claude Code the skills are installed as plugins, from a marketplace this repo generates from the skills themselves.

## Skills

**`rebase`** — Rebase the current Git branch onto a target branch. Performs upfront conflict analysis before touching history, so the agent can resolve conflicts by understanding intent rather than guessing from diff markers.

**`reflective-analysis`** — Structured analysis for ambiguous or high-stakes questions. Runs a staged pipeline: an orchestrator spawns isolated leaf agents to investigate from different angles, then synthesizes their findings. Useful when you want a thorough, bias-resistant answer rather than a quick one.

**`render-claude-session`** *(Claude Code only)* — Export the current Claude Code session to a readable Markdown or HTML file, with a table of contents, collapsible tool/thinking sections, and a token-usage summary.

## Install

Clone the repo somewhere permanent, then run `install.sh`. Every agent reads the skills straight from this checkout, so a `git pull` updates them all. Moving or deleting the checkout breaks the install.

```
git clone https://github.com/garyshi/skills.git ~/skills && cd ~/skills
./install.sh --all-agents                            # every skill, every agent, user-wide
./install.sh --agent claude,codex                    # some agents
./install.sh --agent cursor rebase                   # one skill
./install.sh --project ~/code/myrepo --agent cursor  # one project only
./install.sh --list                                  # what's installed where
./uninstall.sh --agent cursor                        # remove
```

Use `--dry-run` to preview. Running `install.sh` again is safe; for Claude Code it refreshes the marketplace and updates the plugins.

| Agent | What `install.sh` does | User-wide (default) | `--project DIR` |
|---|---|---|---|
| `claude` | Registers this checkout as the `garyshi-skills` marketplace and installs each skill as a plugin, via the `claude` CLI | user settings | `DIR/.claude/settings.json` |
| `codex` | Symlinks each skill folder | `~/.agents/skills/` | `DIR/.agents/skills/` |
| `cursor` | Symlinks each skill folder | `~/.cursor/skills/` | `DIR/.cursor/skills/` |
| `grok` | Symlinks each skill folder | `~/.grok/skills/` | `DIR/.grok/skills/` |
| `antigravity` | Symlinks each skill folder | `~/.gemini/config/skills/` (desktop app, IDE) and `~/.gemini/antigravity-cli/skills/` (`agy`) | `DIR/.agents/skills/` |

The scripts only ever create, replace or remove symlinks that point into this repo. A real file or folder already in the way is left alone with a warning.

### Claude Code without cloning

You can also install the plugins straight from GitHub inside Claude Code:

```
/plugin marketplace add garyshi/skills
/plugin install rebase@garyshi-skills
```

Update with `/plugin marketplace update garyshi-skills` and `/plugin update rebase@garyshi-skills`. Use either this or `install.sh --agent claude`: both register a marketplace named `garyshi-skills`, and `install.sh` reuses one that already exists. If that one points at GitHub, your local edits only reach Claude Code after you push.

### Notes

- **Overlap between agents:** Cursor also reads `~/.agents/skills` (Codex's folder), and Grok reads `~/.agents/skills` and `~/.cursor/skills`. If you install for Codex, Cursor and Grok may already see the skills. Grok dedupes by name.
- **Project scope:** Codex and Antigravity share `DIR/.agents/skills`, so uninstalling for one removes the skill for both. Grok only loads project skills in folders you've trusted. For Claude Code, the plugin is enabled in the project but the marketplace is registered in your user settings.
- **`render-claude-session`** reads Claude Code's session logs, so it's skipped for every other agent.
- **`reflective-analysis`** relies on Claude Code's `reflective-leaf` agent type (`reflective-analysis/agents/`) to stop leaf agents from spawning more agents. Other agents have no equivalent, so there the skill falls back to a prompt-level leaf rule plus a hard spawn count, and its answer says so.

## Adding or changing a skill

A skill is a top-level folder with a `SKILL.md`. Besides the standard `name` and `description`, its frontmatter carries what the Claude Code plugin needs:

```yaml
metadata:
  version: "0.1.0"                  # plugin version (required)
  short-description: "One line."    # plugin description; falls back to description
  claude-only: "true"               # optional: skip for every other agent
```

Subagent definitions go in the skill's `agents/` folder; Claude Code picks them up as part of the plugin.

`.claude-plugin/marketplace.json` is generated from this metadata. After adding a skill or bumping a version, regenerate it and commit the result:

```
scripts/build-marketplace.py           # rewrite marketplace.json
scripts/build-marketplace.py --check   # fail if it's out of date
```
