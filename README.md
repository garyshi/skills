# my-skills

Personal Claude Code skills.

## Contents

```
reflective-analysis/        # the skill
  SKILL.md                  # entry point: discipline, staged-run overview, budget, pipeline, output
  procedure.md              # orchestration detail + analytical reference (read while running)
  subagent-prompts.md       # one prompt template per agent type (pasted when spawning)
agents/
  reflective-leaf.md        # restricted leaf agent type used by reflective-analysis
```

## Install

The skill spawns its subagents as the `reflective-leaf` agent type, so **both** pieces must be installed where the run can see them:

| Piece | Destination |
|---|---|
| `reflective-analysis/` | `<project>/.claude/skills/reflective-analysis/` (or `~/.claude/skills/`) |
| `agents/reflective-leaf.md` | `<project>/.claude/agents/reflective-leaf.md` (or `~/.claude/agents/`) |

If `reflective-leaf` is missing when the skill runs, leaf spawns fail. The skill falls back to the built-in `Explore` type (also lacks the `Agent` tool, but keeps `Skill`, so it is a weaker guard) and must never fall back to `general-purpose`.

A cleaner future option is to package this repo as a Claude Code **plugin** (add `plugin.json` + keep `agents/`), which registers the skill and the agent together on install — removing the two-step copy.

## Why `reflective-leaf` exists

`reflective-analysis` runs one orchestrator (the main session) that spawns leaf subagents and synthesizes their findings. Leaves must not spawn their own subagents or re-invoke the skill — nesting caused a 259-agent, 5-level-deep, all-Opus run in an earlier version. `reflective-leaf` has no `Agent` and no `Skill` tool, so that rule is enforced by construction rather than by prompt instruction. See `reflective-analysis/procedure.md` → "The leaf rule".
