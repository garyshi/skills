---
name: reflective-analysis
description: Analyze ambiguous, fast-moving, or strategically important questions by examining framing, updating stale assumptions, analyzing trajectory and rate of change, constructing competing causal models, testing them against discriminating evidence, and producing a provisional, falsifiable judgment. Use when a conventional answer may be incomplete, outdated, overly static, or dependent on hidden assumptions.
---

# Reflective Analysis

## Purpose

This skill is for questions where a standard answer may be too shallow, stale, or trapped inside inherited consensus.

It is especially useful for:

* fast-moving technology or industry questions;
* strategic decisions;
* investment or market-structure analysis;
* ambiguous business or organizational questions;
* questions involving weak early signals;
* cases where the user has first-hand observations that conflict with common narratives;
* cases where the answer depends heavily on framing, trajectory, or value capture.

The goal is not to produce a long report. The goal is to produce a better provisional judgment by:

* identifying stale or hidden assumptions;
* distinguishing current facts from trajectory and extrapolation;
* building competing causal models;
* testing the models against discriminating evidence;
* analyzing whether major obstacles are hard limits or solvable bottlenecks;
* stating confidence, uncertainty, and future evidence that would change the conclusion.

Do not optimize for sounding wise, contrarian, balanced, or exhaustive. Optimize for explanatory power, current relevance, trajectory awareness, and updateability.

---

# Core Discipline

For every important claim, distinguish:

* **Observation**: what appears to have happened, including first-hand reports or weak signals;
* **Fact**: what is supported by reliable evidence;
* **Trajectory**: how the relevant variable has changed over time;
* **Extrapolation**: what may follow if the trajectory continues, slows, or accelerates;
* **Model**: the proposed causal explanation;
* **Assumption**: what the explanation depends on;
* **Forecast**: a testable future claim;
* **Judgment**: the current synthesis and confidence.

Never silently turn one category into another. Especially avoid treating extrapolation as fact.

---

# Modes

Default to **Focused Mode**. Use **Deep Mode** only when the user requests depth, or when the stakes, complexity, or framing risk clearly warrant spawning subagents and an adversarial pass. Deep mode is expensive — do not auto-trigger it for routine questions.

## Focused Mode

Use for most substantive discussions. Focused mode should:

1. inspect framing;
2. surface the initial prior;
3. identify potentially stale assumptions;
4. check freshness if needed;
5. analyze trajectory if the subject is fast-moving;
6. build two or three causal models;
7. conduct targeted research only if necessary;
8. provide a provisional judgment, strongest alternative, and next evidence to watch.

Focused mode does not require subagents unless the question is complex enough to benefit from them.

## Deep Mode

Use when the question is high-stakes, structurally complex, fast-moving, or likely to suffer from serious framing errors.

Deep mode requires explicit framing and freshness review, trajectory and extrapolation analysis, 2–4 competing causal models, targeted discriminating research, specialized independent subagents, an adversarial falsification pass, a **mandatory Obstacle-to-Opportunity subagent**, feedback-environment analysis, and a final synthesis.

Deep-mode agents run in **two waves**: a Wave 1 investigation pass (fresh evidence, trajectory, first-principles models, adversarial falsification) runs in parallel; the main session then extracts the concrete obstacles; and the **Obstacle-to-Opportunity subagent runs in Wave 2, seeded with those obstacles**. Do not launch the O2O agent in the same batch as the Wave 1 agents — it needs their output as input. See `deep-mode.md`.

**Read `deep-mode.md` for the full deep-mode procedure and `obstacle-to-opportunity.md` for the mandatory Obstacle-to-Opportunity subagent template before running deep mode.**

### Default deep-mode budget

This is the single source of truth for scope. Do not exceed it unless decision stakes or unresolved evidence complexity justify it.

* 2–4 causal models;
* 3–5 specialized subagents;
* one adversarial pass;
* one mandatory Obstacle-to-Opportunity pass;
* one synthesis pass.

---

# Step Index

The steps below are the analysis pipeline. Focused mode uses Steps 1–8 and 13–15 lightly. Deep mode uses all steps; the detailed procedures for the trajectory, trend-quality, feedback, subagent, and stopping logic live in `deep-mode.md`.

1. **Identify the real question** — restate operationally; separate adjacent questions that need different evidence (feasibility vs. adoption, value creation vs. value capture, current capability vs. trajectory); define ambiguous terms ("works," "reliable," "priced in," "adoption") as observable criteria.
2. **Surface the initial prior** — record the default answer, the narrative behind it, when that narrative formed, and which assumptions may have changed. Treat as a hypothesis, not an anchor. State the consensus's strongest version.
3. **Incorporate user context and first-hand observations** — for each observation, ask what was observed, what belief it challenges, whether it is anecdote or early signal, and what mechanism explains it. Preserve both "early signal" and "selection effect" possibilities.
4. **Check freshness** — classify evidence by date and relevance; ask whether the studied system has materially changed. Old evidence is a prior, not current evidence. (See `deep-mode.md`.)
5. **Analyze trajectory, not just freshness** — separate current facts, observed trajectory, and reasonable extrapolation. (See `deep-mode.md`.)
6. **Evaluate trend quality** — measurement consistency, saturation risk, bottleneck migration, feedback environment, incentive intensity, historical analogy. (See `deep-mode.md`.)
7. **Extrapolate with discipline** — produce mechanical and constraint-aware versions; where they diverge, the constraint is the real question. (See `deep-mode.md`.)
8. **Build competing causal models** — 2–4 explanations differing in *mechanism*, not degree. For each: central mechanism, assumptions, evidence explained/unexplained, leading indicators, failure conditions. (See `deep-mode.md` for model archetypes.)
9. **Analyze the feedback environment** — speed, clarity, selection pressure, reversibility, correlation, silent-error risk. (See `deep-mode.md`.)
10. **Launch the mandatory Obstacle-to-Opportunity subagent** (deep mode only) — Wave 2, *after* Step 11/12's investigation agents return and you have extracted the concrete obstacles. Never in the same batch as them. See `obstacle-to-opportunity.md`.
11. **Research only discriminating evidence** — for each branch ask "what conclusion changes depending on what I find?" If none, stop the branch. (See `deep-mode.md`.)
12. **Use other subagents selectively** — only for substantially independent tasks; no majority vote; preserve independent framing. (See `deep-mode.md` for the default agent set.)
13. **Run a framing review** — am I answering the real question? Did framing predetermine the conclusion? Did I treat a trend as fact, an obstacle as permanent, or value creation as value capture? Am I contrarian only for novelty? (See `deep-mode.md` for the full checklist.)
14. **Stop when marginal value falls** — stop when models are clear, sources repeat, remaining uncertainty is about future events, and the O2O pass has separated solvable from persistent barriers.
15. **Produce the judgment** — use the output structure below.

---

# Step 15: Output Structure

Use this structure when appropriate.

* **Current Judgment** — the best provisional conclusion, stated directly.
* **Why** — the central causal mechanism.
* **What Changed From the Initial Prior** — the assumption, evidence, trajectory, or obstacle analysis responsible for the update.
* **Fact / Trajectory / Extrapolation** — kept separate, plus key constraints.
* **Causal Models Considered** — compare the strongest models; explain why the chosen one deserves more weight.
* **Obstacle-to-Opportunity Findings** (deep mode) — which obstacles are hard constraints, which are solvable bottlenecks, who may solve them, what changes if solved, and what evidence to watch. State whether this pass changed the conclusion.
* **Confidence** — a calibrated qualitative or numerical range.
* **Strongest Alternative** — the best competing explanation, not a token objection.
* **Critical Uncertainty** — the few variables that could materially change the conclusion.
* **Discriminating Observations** — future evidence that would favor one model over another.
* **Practical Implication** — what to do, investigate, measure, or avoid next.

## Optional Belief Record

For questions likely to recur, keep a compact record and update it when evidence changes rather than rewriting the analysis:

```markdown
## Belief: <claim>

- Current confidence:
- Last updated:
- Scope:
- Current facts:
- Observed trajectory:
- Reasonable extrapolation:
- Core mechanism:
- Supporting evidence:
- Strongest counterevidence:
- Key assumptions:
- Bottlenecks / constraints:
- Obstacle-to-opportunity theories:
- Discriminating observations:
- Falsification conditions:
- Next review trigger:
```

---

# Output Style

Prefer a thoughtful analytical conversation over a formal report unless the user asks for a report. Use clear language.

Do not:

* overwhelm the user with generic frameworks;
* repeat obvious caveats;
* hide uncertainty behind vague balance;
* present consensus as fact;
* manufacture false novelty;
* force every issue into a bullish or bearish conclusion;
* produce long transcripts of agent discussion unless requested.

When the user's first-hand observation changes the analysis, say precisely which assumption it changed. When the Obstacle-to-Opportunity subagent changes the analysis, say precisely which obstacle was reclassified and why. When evidence remains incomplete, provide the best provisional model rather than retreating to "it is too early to know."

---

# Final Instruction

Do not try to sound independently minded. Demonstrate independence by:

* noticing when an assumption no longer fits;
* updating in response to current evidence;
* analyzing trajectory rather than static snapshots;
* distinguishing fact from extrapolation;
* asking whether obstacles are hard limits or solvable bottlenecks;
* considering which capable players may attack those bottlenecks;
* considering genuinely different causal mechanisms;
* explaining why one model currently deserves more weight;
* preserving uncertainty where reality has not yet resolved it.
