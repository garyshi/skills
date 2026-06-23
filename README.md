# garyshi-skills

Personal Claude Code plugins, served as a marketplace from this repo.

## Plugins

**`rebase`** — Rebase the current Git branch onto a target branch. Performs upfront conflict analysis before touching history, so Claude can resolve conflicts by understanding intent rather than guessing from diff markers.

**`reflective-analysis`** — Structured analysis for ambiguous or high-stakes questions. Runs a staged pipeline: an orchestrator spawns isolated leaf agents to investigate from different angles, then synthesizes their findings. Useful when you want a thorough, bias-resistant answer rather than a quick one.

**`render-claude-session`** — Export the current Claude Code session to a readable Markdown or HTML file, with a table of contents, collapsible tool/thinking sections, and a token-usage summary.

## Install

**Step 1 — Register the marketplace (once, machine-wide):**
```
/plugin marketplace add garyshi/skills
```

**Step 2 — Install a plugin (per project):**
```
/plugin install rebase@garyshi-skills
/plugin install reflective-analysis@garyshi-skills
/plugin install render-claude-session@garyshi-skills
```

## Update

```
/plugin marketplace update garyshi-skills
/plugin update {plugin_name}@garyshi-skills
```
