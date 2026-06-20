# garyshi-skills

Personal Claude Code skills, served as a Claude Code **marketplace** (this repo). The repo root holds only the marketplace manifest — a registry that points at the plugins. The root is **not** itself a plugin; each plugin lives in its own self-contained subdirectory, so the repo can host more of them later.

## Contents

```
.claude-plugin/
  marketplace.json                       # the marketplace registry (lists the plugins below)
reflective-analysis-plugin/              # a self-contained Claude Code plugin
  .claude-plugin/
    plugin.json                          # the plugin manifest
  skills/
    reflective-analysis/
      SKILL.md                           # entry: discipline, staged-run overview, budget, pipeline, output
      procedure.md                       # orchestration detail + analytical reference (read while running)
      subagent-prompts.md                # one prompt template per agent type (pasted when spawning)
  agents/
    reflective-leaf.md                   # restricted leaf agent type (no Agent/Skill tool) — auto-registered
rebase-plugin/                           # a self-contained Claude Code plugin
  .claude-plugin/
    plugin.json                          # the plugin manifest
  skills/
    rebase/
      SKILL.md                           # rebase onto a target branch with upfront conflict analysis
```

## Install (plugin — recommended)

Registering the marketplace is one-time and machine-wide; **enabling** a plugin is per-project, so you turn it on only where you want it.

1. Register the marketplace once — from GitHub:
   ```
   /plugin marketplace add garyshi/skills
   ```
   …or from a local checkout (point at the repo root, not the plugin subdir):
   ```
   /plugin marketplace add <path-to-your-clone-of-this-repo>
   ```
   Either way it registers under the name in `marketplace.json` — **`garyshi-skills`**.
2. Enable a plugin **per project** — via `/plugin` (e.g. install `rebase@garyshi-skills` at project scope), or add to that project's `.claude/settings.json`:
   ```json
   { "enabledPlugins": { "rebase@garyshi-skills": true } }
   ```
   Available plugins: `reflective-analysis`, `rebase`.
3. Update later: `git pull`, then `/plugin marketplace update garyshi-skills` and `/plugin update <plugin>@garyshi-skills`. (Bump the plugin `version` when you publish changes, so the cache refreshes instead of serving a stale copy.)

Installing via the plugin registers the skill **and** the `reflective-leaf` agent together — no separate copy step. The agent is then namespaced **`reflective-analysis:reflective-leaf`** (the orchestrator uses whichever `reflective-leaf` type is available).

## Install (loose copy — alternative)

Without the plugin, copy both pieces into a project's `.claude/` (the skill spawns leaves as `reflective-leaf`, so both are required):

| Piece | Destination |
|---|---|
| `reflective-analysis-plugin/skills/reflective-analysis/` | `<project>/.claude/skills/reflective-analysis/` |
| `reflective-analysis-plugin/agents/reflective-leaf.md` | `<project>/.claude/agents/reflective-leaf.md` |

Loose-installed, the agent is bare `reflective-leaf`. If no `reflective-leaf` type is available at run time, the skill falls back to the built-in `Explore` type (also lacks `Agent`, but keeps `Skill`, so it is a weaker guard) and must never fall back to `general-purpose`.

## Why `reflective-leaf` exists

`reflective-analysis` runs one orchestrator (the main session) that spawns leaf subagents and synthesizes their findings. Leaves must not spawn their own subagents or re-invoke the skill — nesting caused a 259-agent, 5-level-deep, all-Opus run in an earlier version. `reflective-leaf` has no `Agent` and no `Skill` tool, so that rule is enforced by construction rather than by prompt instruction. See `reflective-analysis-plugin/skills/reflective-analysis/procedure.md` → "The leaf rule".
