# my-skills

Personal Claude Code skills. The repo root is **not** itself a plugin — each plugin lives in its own self-contained subdirectory, so the repo can also hold loose skills or other plugins later.

## Contents

```
reflective-analysis-plugin/              # a self-contained Claude Code plugin (also a 1-plugin marketplace)
  .claude-plugin/
    marketplace.json                     # registers this dir as a local marketplace
    plugin.json                          # the plugin manifest
  skills/
    reflective-analysis/
      SKILL.md                           # entry: discipline, staged-run overview, budget, pipeline, output
      procedure.md                       # orchestration detail + analytical reference (read while running)
      subagent-prompts.md                # one prompt template per agent type (pasted when spawning)
  agents/
    reflective-leaf.md                   # restricted leaf agent type (no Agent/Skill tool) — auto-registered
```

## Install (plugin — recommended)

The marketplace registration is one-time and machine-wide; **enabling** the plugin is per-project, so you can turn it on only where you want it.

1. Register the marketplace once:
   ```
   /plugin marketplace add /home/gary.shi/repos/my-skills/reflective-analysis-plugin
   ```
2. Enable it **per project** — either via `/plugin` (install `reflective-analysis@reflective-analysis-local` at project scope), or add to that project's `.claude/settings.json`:
   ```json
   { "enabledPlugins": { "reflective-analysis@reflective-analysis-local": true } }
   ```
3. Update later with `git pull` in this repo (+ `/plugin update` if needed).

Installing via the plugin registers the skill **and** the `reflective-leaf` agent together — no separate copy step. Note the agent is then namespaced **`reflective-analysis:reflective-leaf`** (the orchestrator picks whichever `reflective-leaf` type is available).

## Install (loose copy — alternative)

Without the plugin, copy both pieces into a project's `.claude/` (the skill spawns leaves as `reflective-leaf`, so both are required):

| Piece | Destination |
|---|---|
| `reflective-analysis-plugin/skills/reflective-analysis/` | `<project>/.claude/skills/reflective-analysis/` |
| `reflective-analysis-plugin/agents/reflective-leaf.md` | `<project>/.claude/agents/reflective-leaf.md` |

Loose-installed, the agent is bare `reflective-leaf`. If no `reflective-leaf` type is available at run time, the skill falls back to the built-in `Explore` type (also lacks `Agent`, but keeps `Skill`, so it is a weaker guard) and must never fall back to `general-purpose`.

## Why `reflective-leaf` exists

`reflective-analysis` runs one orchestrator (the main session) that spawns leaf subagents and synthesizes their findings. Leaves must not spawn their own subagents or re-invoke the skill — nesting caused a 259-agent, 5-level-deep, all-Opus run in an earlier version. `reflective-leaf` has no `Agent` and no `Skill` tool, so that rule is enforced by construction rather than by prompt instruction. See `reflective-analysis-plugin/skills/reflective-analysis/procedure.md` → "The leaf rule".
