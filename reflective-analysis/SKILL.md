---
name: reflective-analysis
description: Analyze ambiguous, fast-moving, or strategically important questions by examining framing, verifying the baseline, updating stale assumptions, analyzing trajectory and rate of change, constructing competing causal models, testing them against discriminating and disconfirming evidence, and producing a provisional, falsifiable judgment. Use when a conventional answer may be incomplete, outdated, overly static, trapped in consensus, or dependent on hidden assumptions.
---

# Reflective Analysis

## Purpose

This skill is for questions where a standard answer may be too shallow, stale, or trapped inside inherited consensus.

It is especially useful for: fast-moving technology or industry questions; strategic decisions; investment or market-structure analysis; ambiguous business or organizational questions; questions involving weak early signals; cases where the user has first-hand observations that conflict with common narratives; and cases where the answer depends heavily on framing, trajectory, or value capture.

The goal is not to produce a long report. The goal is to produce a better provisional judgment by:

* identifying stale or hidden assumptions;
* verifying the baseline/reference class instead of inheriting it;
* distinguishing current facts from trajectory and extrapolation;
* building competing causal models;
* testing the models against discriminating *and disconfirming* evidence;
* analyzing whether major obstacles are hard limits or solvable bottlenecks;
* stating confidence, uncertainty, and future evidence that would change the conclusion.

Do not optimize for sounding wise, contrarian, balanced, or exhaustive. Optimize for explanatory power, current relevance, trajectory awareness, and updateability.

> **One procedure.** This skill runs a single, deliberately thorough, subagent-driven procedure (below). There is no "light mode" — every invocation runs the full pipeline. (A lighter single-pass variant may be derived later; it is easier to cut down from a clean procedure than to maintain a fork, so for now there is only this.)

---

# Core Discipline

For every important claim, distinguish:

* **Observation**: what appears to have happened, including first-hand reports or weak signals;
* **Fact**: what is supported by reliable evidence — noting that "reliable" sources are still positioned (see below);
* **Consensus**: what the aggregate of commentary, reporting, and even expert sources currently asserts. This is an *input to be analyzed, not evidence*. The web aggregate **is** the consensus, so any process that mainly gathers and synthesizes it will reproduce it — with better citations — unless it deliberately does otherwise;
* **Trajectory**: how the relevant variable has changed over time;
* **Extrapolation**: what may follow if the trajectory continues, slows, or accelerates;
* **Model**: the proposed causal explanation;
* **Assumption**: what the explanation depends on;
* **Forecast**: a testable future claim;
* **Judgment**: the current synthesis and confidence.

Never silently turn one category into another. Especially avoid treating extrapolation as fact, or **consensus as fact**.

**Every source is positioned — including the authoritative ones.** Treat formal academic studies, official statistics, and authoritative press releases as evidence *plus* an incentive *plus* a method limit — not as neutral truth. Public opinion is biased in two directions at once: a dominant narrative drops the caveats its own proponents know (the headline survives; the "but it is not actually X" footnote gets cut), while interested parties inflate the headline (vendors, labs, anyone selling the trend). A single topic-level search inherits **both** biases. So for each load-bearing source ask: who produced it, what do they gain if it is believed, what caveat would they have reason to omit, and how narrow is the sample or method? Holding even a respected source to this is the high bar this skill exists to clear; do not lower it because a source looks official.

---

# How This Runs

One **orchestrator** — the main session — runs the whole analysis. It decomposes the question, spawns subagents to investigate independent lenses, and is the *only* place where synthesis happens.

**Subagents are leaves.** A subagent investigates one lens and returns findings. It **must not** invoke this skill (or any analysis skill) and **must not** spawn its own subagents. If it finds that a sub-question deserves deeper work, it says so in its output as a *recommendation*; the orchestrator decides whether to spawn it. Nested spawning produces duplication, lossy multi-level summarization, and fake convergence — never higher quality. (See `procedure.md`.)

The run is **staged**, and the orchestrator synthesizes at each barrier:

```
Stage 1 (parallel; each agent seeded from the question + prior, does its own search):
   gatherers  +  adversarial / baseline-attack
   ── barrier: orchestrator compiles an evidence brief + records the adversarial/baseline findings ──
Stage 2 (parallel; both seeded from that brief + the adversarial findings):
   trajectory  +  first-principles / causal models
   ── barrier: orchestrator synthesizes a provisional judgment ──
Conditional re-pass (only if triggered; orchestrator-owned):
   frame overturned → re-derive the affected lens on the corrected frame
   + a final adversarial pass against the synthesized judgment
Wave 2:
   Obstacle-to-Opportunity, seeded with the obstacles the orchestrator extracted
   ── orchestrator produces the final judgment ──
```

The decomposition into lenses comes from the **question and this framework, not from data** — so all Stage-1 prompts can be written before any evidence exists. Within a stage, agents are independent and run in parallel. Only Stage 2 and O2O depend on earlier output (which is why they are later stages — not because the lenses differ in kind).

## Budget — single source of truth for scope

Hard caps, per phase, counted by the orchestrator across the whole run. Nesting is zero. Do not exceed without a stated reason (decision stakes or unresolved evidentiary complexity).

| Phase | Cap | Default model |
|---|---|---|
| Stage 1 — gatherers (split by *territory*, not volume) | ≤ 3 | Haiku / Sonnet |
| Stage 1 — adversarial / baseline-attack (independent search) | ≤ 2 | Opus |
| Stage 2 — trajectory | ≤ 1 | Sonnet |
| Stage 2 — first-principles / causal models | ≤ 2 | Opus |
| Conditional re-pass (triggered only) | ≤ 1 | Opus |
| Final adversarial vs. the synthesized judgment | ≤ 1 | Opus |
| Wave 2 — Obstacle-to-Opportunity | ≤ 2 | Opus |
| (optional) per-finding adversarial verification | ≤ 1 / finding, ≤ 5 total | Sonnet |
| **Hard total (all phases, nesting = 0)** | **≤ 12** | — |

Per-phase caps prevent gathering from exhausting the budget and starving the later analysis and O2O phases. A single gathering agent runs many searches/fetches in its own loop — split gatherers only to cover *different territory* (e.g. by sub-domain, or one dedicated to the baseline), never to add source volume. Assign the cheap tier to gathering and verification, and Opus to the reasoning, adversarial, and synthesis lenses where judgment is the product. Pass the tier explicitly when spawning (the Agent `model` option); otherwise a subagent inherits the orchestrator's model — which is how an info-gathering agent ends up needlessly on Opus.

---

# Pipeline

Each step is one stage of the run above. The detailed procedures live in `procedure.md`; the subagent prompt templates live in `subagent-prompts.md`.

1. **Identify the real question — and its baseline.** Restate operationally; separate adjacent questions that need different evidence (feasibility vs. adoption, value creation vs. value capture, current capability vs. trajectory); define ambiguous terms ("works," "reliable," "priced in," "adoption") as observable criteria. If the question is comparative or rests on a reference class ("compared to X," "like Y," "X is far ahead"), make that **baseline an explicit object**: state how the consensus characterizes it, then plan to verify it *directly and skeptically* in Stage 1. A wrong baseline silently determines the whole answer, and baselines are exactly where consensus is absorbed without examination.
2. **Surface the initial prior.** Record the default answer, the narrative behind it, when that narrative formed, and which assumptions may have changed. Treat as a hypothesis, not an anchor. State the consensus's strongest version.
3. **Incorporate user context and first-hand observations.** For each observation, ask what was observed, what belief it challenges, whether it is anecdote or early signal, and what mechanism explains it. Preserve both "early signal" and "selection effect" possibilities.
4. **Plan the run.** Decompose the question into the lenses; set the per-phase budget; assign model tiers; write each subagent's prompt from `subagent-prompts.md`. Do not contaminate every prompt with one shared frame (see `procedure.md`).
5. **Stage 1 — gather + attack (parallel).** Spawn gatherers (own multi-source search) and the adversarial/baseline-attack agent (independent, *disconfirming* search, seeded from the prior). (See `procedure.md`: freshness, adversarial search, source positioning.)
6. **Barrier — compile.** Build the evidence brief; record the adversarial/baseline findings; note explicitly whether the baseline or frame was challenged.
7. **Stage 2 — trajectory + first-principles (parallel).** Seed both with the evidence brief and the adversarial findings. (See `procedure.md`: trajectory layers, trend quality, extrapolation, model archetypes.)
8. **Barrier — synthesize.** Build the provisional judgment; evaluate trend quality and the feedback environment. (See `procedure.md`.)
9. **Conditional re-pass (triggered only).** If the adversarial/baseline pass overturned the frame the models assumed, or the models conflict and the conflict is unresolved, re-derive the affected lens *once* on the corrected frame, and run a final adversarial pass against the synthesized judgment. Otherwise fold the adversarial caveats into synthesis directly — no new agents. (See `procedure.md`.)
10. **Extract obstacles.** From the synthesis, name the concrete, specific obstacles to the leading thesis. These are the O2O agent's input.
11. **Wave 2 — Obstacle-to-Opportunity.** Seeded with the obstacles; single agent or fan-out per the coupling test. (See `procedure.md` for the coupling test and integration; `subagent-prompts.md` for the template.)
12. **Run a framing review.** Am I answering the real question? Did framing predetermine the conclusion? Did I treat a trend as fact, an obstacle as permanent, value creation as value capture, or consensus as truth? Am I contrarian only for novelty? (See `procedure.md` for the full checklist.)
13. **Stop when marginal value falls.** Stop when models are clear, sources repeat, remaining uncertainty is about future events, and the O2O pass has separated solvable from persistent barriers.
14. **Produce the judgment.** Use the output structure below.

---

# Output Structure

Use this structure when appropriate.

* **Current Judgment** — the best provisional conclusion, stated directly.
* **Why** — the central causal mechanism.
* **What Changed From the Initial Prior** — the assumption, evidence, trajectory, baseline correction, or obstacle analysis responsible for the update.
* **Divergence from Consensus** — state plainly where this analysis departs from the general consensus and *why*, and where it does not. Name the specific move that produced the divergence (a verified baseline, a disconfirming search, a decomposed unit of analysis, a discounted source). **If it diverges nowhere, treat that as a warning that no independent analysis has happened — not as confirmation.** Go back and check the framing, the baseline, and whether you only searched the topic.
* **Fact / Trajectory / Extrapolation** — kept separate, plus key constraints.
* **Causal Models Considered** — compare the strongest models; explain why the chosen one deserves more weight.
* **Obstacle-to-Opportunity Findings** — which obstacles are hard constraints, which are solvable bottlenecks, who may solve them, what changes if solved, and what evidence to watch. State whether this pass changed the conclusion.
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

When the user's first-hand observation changes the analysis, say precisely which assumption it changed. When the Obstacle-to-Opportunity pass changes the analysis, say precisely which obstacle was reclassified and why. When evidence remains incomplete, provide the best provisional model rather than retreating to "it is too early to know."

---

# Final Instruction

Do not try to sound independently minded. Demonstrate independence by:

* noticing when an assumption no longer fits;
* updating in response to current evidence;
* analyzing trajectory rather than static snapshots;
* distinguishing fact from extrapolation;
* searching for what would *disconfirm* the leading claim, not for the claim itself;
* treating every source — including formal studies and authoritative releases — as positioned, with an incentive and a method limit;
* verifying the reference class or baseline the consensus uses unexamined, rather than inheriting it;
* decomposing the unit of analysis the consensus treats as monolithic (the occupation, the "industry," the "technology") down to the level where the mechanism actually varies;
* pushing the leading claim to its limiting case to find where it breaks;
* asking whether obstacles are hard limits or solvable bottlenecks;
* considering which capable players may attack those bottlenecks;
* considering genuinely different causal mechanisms;
* explaining why one model currently deserves more weight;
* preserving uncertainty where reality has not yet resolved it;
* being able to say exactly where your conclusion departs from consensus — and being suspicious of yourself when it departs nowhere.
