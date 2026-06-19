# Procedure — Detailed Orchestration & Analytical Reference

This file holds the detail behind the Pipeline in `SKILL.md`. The orchestrator (main session) reads it while running the analysis. The subagent prompt templates are in `subagent-prompts.md`; the orchestrator pastes/adapts those when spawning — subagents do **not** read these files.

Stay within the per-phase budget in `SKILL.md` (hard total ≤ 12 agents, nesting = 0).

> **Note on examples.** The lists below skew toward fast-moving technology and investment questions because that is where this skill is most used. They are *domain illustrations*, not a required checklist. For organizational, scientific, policy, or other questions, substitute the relevant variables — do not force the analysis into AI-adoption framing.

---

# Orchestration

## The leaf rule (the single most important constraint)

Exactly one orchestrator: the main session. Subagents are leaves. A subagent **must not** invoke `reflective-analysis` (or `deep-research`, or any analysis skill) and **must not** spawn its own subagents.

**This is enforced mechanically, not by prompt.** Spawn every leaf as the `reflective-leaf` agent type (see `subagent-prompts.md` for the exact `subagent_type` string, which differs between plugin and loose installs), which has no `Agent` and no `Skill` tool — so nesting and skill re-entry are impossible regardless of what any prompt says. Do not rely on the instruction alone: a prompt-only version of this rule is exactly the advisory constraint that failed before (the old "3–5 subagents" budget was also just a prompt, and a run blew through it to 259 agents, 5 levels deep). Fallback if `reflective-leaf` is unavailable: the built-in `Explore` type (also lacks `Agent`; weaker, since it keeps `Skill`). Never use `general-purpose` for a leaf.

Why — nested spawning never improves quality, and usually lowers it:

* **Duplication.** A leaf has no global view, so it re-investigates ground its siblings already cover. (Observed failure: one run produced a dozen near-identical "trajectory" agents, each re-researching the same question.)
* **Lossy telephone game.** Each level summarizes the level below. A finding five levels deep is summarized five times before the orchestrator sees it — more layers means *more* signal lost, not more insight.
* **Fake convergence.** Many agents spun off the same frame agree with each other; that looks like triangulation but is an echo. It mechanizes exactly the correlated-framing failure this skill is built to fight.

What a leaf does instead when it senses deeper work is needed: **it returns a recommendation** ("the orchestrator should investigate X, Y, Z as separate lenses"). The orchestrator decides whether to spawn — at the top level, where it can decompose without overlap and synthesize once without a lossy middle layer.

The one nested pattern that *would* add quality — adversarial **per-finding verification** (one independent skeptic per specific claim) — is still run by the orchestrator as a stage, not by a leaf, because only the orchestrator can dedupe findings and synthesize verdicts. See "Per-finding verification" below.

## Stages, barriers, and parallelism

The decomposition into lenses comes from the question and this framework, not from data, so the orchestrator can write every Stage-1 prompt up front. Within a stage, agents share no dependencies and run in **parallel** (one message, multiple spawns). Between stages there is a **barrier**: the orchestrator waits for the stage to return, synthesizes, and only then writes the next stage's prompts.

* **Stage 1 (parallel):** gatherers + adversarial/baseline-attack. The gatherers research the question's evidence base; the adversarial/baseline-attack agent is seeded from the **initial prior** (not from a shared brief — there is none yet) and runs its **own disconfirming search**, so it can surface evidence the mainstream-framed gatherers never looked for.
* **Barrier:** the orchestrator compiles a single evidence brief and records the adversarial/baseline findings, *explicitly noting whether the baseline or frame was challenged*.
* **Stage 2 (parallel):** trajectory + first-principles models, each seeded with the evidence brief **and** the adversarial findings — so their first pass is already informed, and they don't need to re-gather. (The trajectory agent knows *what trajectory to study* because the orchestrator specifies it in the prompt, derived from the question — e.g. "rate of change of capability and adoption in domains A, B, C." It does not need another agent's output.)
* **Barrier:** the orchestrator synthesizes a provisional judgment, evaluating trend quality and the feedback environment.

## Conditional re-pass (triggered, bounded, orchestrator-owned)

Do **not** re-run a lens by default — that is the recursion failure mode. Re-run only when a lens's **inputs have materially changed**, cap it at one extra pass, and let the orchestrator own the decision. Two triggers:

1. **Frame overturned.** If the adversarial/baseline pass invalidated an assumption the Stage-2 models were built on (e.g. the baseline turned out to be bimodal, not "far ahead"), the models now stand on a stale frame. Re-derive the affected lens **once** on the corrected frame before synthesizing. (If the adversarial pass only added caveats, fold them into synthesis directly — no new agent.)
2. **Final adversarial vs. the judgment.** The first adversarial pass attacks the prior; the synthesized judgment is what you will actually commit to, so it deserves the attack more. Run one adversarial agent against the synthesized judgment before finalizing.

The distinction from runaway recursion: new-input requirement + one pass + explicit trigger + no leaf-spawning. Count these against the budget.

## Don't contaminate the agents with one frame

If you seed every prompt with the same framing vocabulary and the same baseline, the agents' agreement is an **echo of your frame, not triangulation** — and you will misread manufactured convergence as strong evidence. Guard against it:

* Do not inject the orchestrator's preferred terms or its characterization of the baseline into every prompt. Give the raw question and let agents frame it.
* The adversarial/baseline-attack agent gets an explicitly **inverted or orthogonal** brief, and is told to attack the baseline/reference class and the framing itself — not to gather confirming evidence.
* When a stage converges, before trusting it ask: *did they triangulate from independent angles, or did they all inherit a frame I supplied?* If the latter, re-run one agent with a clean or opposing frame.

## Per-finding verification (the only sanctioned fan-out)

When the synthesis rests on specific, falsifiable findings, the orchestrator may spawn one skeptic per finding to try to **refute** it (cap: ≤ 1/finding, ≤ 5 total, cheap model). Kill or downgrade findings a majority of skeptics refute. This is quality-additive because each verifier needs a specific claim as input and findings fan out naturally — but it is an orchestrated stage, never something a leaf does.

---

# Analytical Reference

The orchestrator draws on these when writing prompts and when synthesizing. The matching subagent prompts in `subagent-prompts.md` already embed the relevant parts.

## Freshness — before using evidence

For any fast-moving subject, classify evidence by both date and relevance. Ask: what system/technology/market regime was studied? Has it materially changed since? Is this about current capability, historical capability, adoption, economics, or risk? Does the conclusion still apply, or only the underlying mechanism? Are newer observations available that test the same claim?

Old evidence is not automatically invalid, but it must not be treated as current evidence merely because it is rigorous. When recent first-hand observations conflict with older formal evidence: preserve the formal evidence as a prior, treat the new observation as a possible update, investigate whether the underlying system changed, and avoid automatically privileging either source.

## Trajectory — not just freshness

For very fast-moving subjects, don't ask only "what is currently true?" Also ask "how fast is it changing, and what follows if the rate continues, slows, or accelerates?" Classify claims into three layers:

* **Layer 1 — Current facts:** capabilities, deployment data, costs, benchmarks, reliability, failure modes, constraints, business model. State as fact only when evidence supports it.
* **Layer 2 — Observed trajectory:** rate of improvement, release cadence, cost/latency decline, adoption growth, workflow change, capital, bottleneck migration. Prefer comparing multiple points in time over one snapshot. Ask: what improved between version N and N+1, and did it come from capability, tooling, data, workflow, infrastructure, regulation, or user adaptation? Is the change linear, exponential, stepwise, cyclical, or slowing? Are failures being eliminated, displaced, or hidden? Which bottlenecks fall fastest; which don't move?
* **Layer 3 — Reasonable extrapolation:** explicit projections from the observed trajectory. Separate conservative, base-case, aggressive, and discontinuity scenarios. For each, state what trend is extended, over what horizon, what must hold, what would slow/accelerate it, and what would invalidate it. Use "current evidence supports…", "the observed trajectory suggests…", "a reasonable extrapolation is…", "this requires assuming…", "this would fail if…". Do not present extrapolation as fact.

## Trend quality — before relying on a trend

* **Measurement consistency.** Are data points measuring the same thing over time? Beware comparing different benchmarks, curated demos vs. real use, lab vs. production, gross capability vs. net workflow productivity, claimed vs. realized savings.
* **Saturation risk.** Is the trend approaching a hard or soft limit — physics, cost, data quality, latency, regulation, trust, distribution, organizational adoption, liability, energy, adversarial pressure, diminishing marginal utility?
* **Bottleneck migration.** When one bottleneck improves, another may dominate (capability improves but evaluation becomes limiting; generation cost falls but review cost rises). A good extrapolation tracks where the bottleneck moves.
* **Feedback environment.** Trends continue more reliably when feedback is fast, frequent, low-noise, attributable, economically rewarded, and adversarially tested; less reliably when errors are silent, delayed, subjective, or hard to attribute.
* **Incentive intensity.** Who has strong incentive to push the trend — capital, competition, open-source, user pull, tooling, regulatory permission, strategic necessity, existential pressure? Strong economic pressure + fast feedback deserves more extrapolation weight than demos.
* **Historical analogy.** For each analogy specify whether it matches the technical learning curve, cost curve, adoption curve, regulatory environment, market structure, feedback loop, or value-capture mechanism. Don't use analogy as evidence unless the mechanism matches.

## Extrapolate with discipline

Produce at least two versions. **Mechanical:** what happens if the measured trend simply continues (maps the possibility space; not a forecast by itself). **Constraint-aware:** what happens after accounting for bottlenecks, incentives, second-order effects, adoption friction, regulation, competition, capital intensity, supply constraints, customer behavior, feedback quality, regime changes (usually more decision-relevant). If the two diverge sharply, the key question is the constraint that causes the divergence.

## Build competing causal models

Construct 2–4 genuinely different explanations that differ in *mechanism*, not merely degree. For each: central mechanism, assumptions, evidence it explains well, evidence it fails to explain, expected leading indicators, conditions under which it would fail. Stop adding models once new ones no longer change the decision. Example archetypes (choose what fits; don't force every issue into these):

* **Constraint model** — progress is real but bounded by a bottleneck.
* **Capability-transfer model** — progress in one domain reflects more general underlying capability.
* **Workflow-reconstruction model** — the main change comes from redesigning the process, not substituting into the old one.
* **Commoditization model** — value is created but competition passes most of it to customers.
* **Bottleneck-shift model** — the old scarce factor becomes abundant; a new scarce factor captures value.
* **Regime-change model** — historical evidence is less predictive because the system changed.
* **Bubble / over-extrapolation model** — progress is real but already overcapitalized or overinterpreted.
* **Obstacle-to-opportunity model** — a serious barrier today may become the basis for a new control layer, product category, institution, or advantage.

## Feedback environment

Determine how errors and successes are discovered: **speed** (how long until the outcome is observable?), **clarity** (can success/failure be attributed to the decision?), **selection pressure** (do weak approaches get rejected?), **reversibility** (can mistakes be caught before major damage?), **correlation** (could one mistaken method produce the same error across many cases?), **silent-error risk** (can an approach look successful while producing hidden/delayed damage?). A system can improve rapidly without formal verification when feedback is fast, competitive, and attributable; it may stay unreliable even with expert review when errors are delayed, ambiguous, or shared.

## Search adversarially, and treat every source as positioned

Searching the *topic* returns the consensus; the web aggregate **is** the consensus. To get past it:

* **Search the disconfirming query.** For each load-bearing claim — *especially the baseline/reference class* — run the search that would *refute* it, not the one that describes it. "Is X far ahead" returns boosterism; "where does X still fail / X overstated / independent RCT on X" returns the caveats the dominant narrative drops. Run both and weigh them.
* **Verify the baseline directly.** If the analysis rests on "compared to X," spend a search characterizing X skeptically before reasoning from it. A baseline absorbed from public opinion silently sets the answer.
* **Tag each source by incentive and method.** Who produced it, what they gain if believed, what caveat they'd omit, how narrow the sample/method. A vendor/lab/CEO headline and a small-n academic RCT are *both* positioned — in opposite directions. Weight by independence, not by how official a source looks.
* **Beware two-sided bias.** Dominant narratives cut the qualifier; interested parties inflate the headline. Truth often sits between a deflating independent study and an inflating interested claim — report the spread, don't average it away.

## Research only discriminating evidence

Don't search broadly for everything relevant. Search for evidence that distinguishes the competing models. Prioritize: direct observations and primary sources; recent changes in behavior/outcomes; evidence from environments resembling the real use case; failure cases and hidden costs; data that contradicts the leading model; evidence about bottlenecks, not just progress; evidence about value capture, not just value creation; evidence about whether obstacles are being reduced in practice. For each branch ask: "what conclusion would change depending on what I find?" If "none," stop the branch.

---

# Obstacle-to-Opportunity — orchestration

O2O is Stage 3. Launch it only **after** Stage 2 has returned and the orchestrator has extracted the concrete, named obstacles to the leading thesis. Those obstacles are the agent's input. Do not launch O2O with the Stage-1/Stage-2 agents — if the obstacles don't exist yet, the agent fabricates generic ones, which is the most common failure of this step. The O2O subagent prompt (mission, opportunity-theory template, required output format, capable-player categories) is in `subagent-prompts.md`.

## One agent or several?

Decide by how *coupled* the obstacles are, not how many there are.

* **Coupled obstacles within one domain** — they share players and evidence and trade off against each other (e.g. verification cost vs. review cost). Use a **single** O2O agent; reasoning about them together is an advantage.
* **Heterogeneous obstacles spanning domains** — different evidence sources, players, time horizons, little mechanistic interaction (e.g. model-capability trajectory vs. regulatory environment vs. public opinion vs. supply chain). **Fan out, one agent per obstacle** (within the Stage-3 cap). A single agent would dilute depth and let one obstacle's framing bleed into the others.

Cross-obstacle synthesis — ranking obstacles against each other and deciding which most changes the thesis — is always the orchestrator's job; this is harder, not easier, when the obstacles are non-commensurable, which is exactly why it stays with the orchestrator.

**Tripwire:** if an obstacle is large enough to be its own reflective-analysis question (e.g. "foundational model capability trajectory"), treat it as a separate analysis rather than a row in a shared table.

## Context the orchestrator must provide the O2O agent

1. the original question; 2. relevant user observations/hypotheses; 3. the initial consensus model / default prior; 4. the current leading causal models; 5. the strongest objections/obstacles identified so far; 6. known facts and trajectories that matter; 7. constraints on scope/horizon/decision relevance; 8. the output format needed. Provide enough to reason; not so much intermediate discussion that the agent merely imitates the orchestrator.

## After the O2O agent returns

Do not paste the report. Integrate it: update which obstacles are hard limits, which are temporary bottlenecks, which may become new business opportunities or control layers; how the leading models change; what probability/timing assumptions change; what evidence to watch. **Explicitly state whether the O2O pass changed the conclusion.**

---

# Framing review

Before final synthesis, ask:

* Am I answering the original question or a nearby easier one?
* Did the initial framing determine the conclusion?
* Did I verify the baseline, or inherit it from consensus?
* Am I comparing reality with an idealized alternative?
* Did I confuse implementation difficulty with fundamental impossibility?
* Did I confuse an impressive case with broad applicability?
* Did I assume current workflows remain unchanged?
* Did I confuse value creation with value capture?
* Did I overweight evidence because it is formal but stale? Because it is recent but anecdotal? Because it is official but positioned?
* Did I treat a trend as fact? A consensus as fact?
* Did I extrapolate without checking constraints?
* Did I assume a current bottleneck will remain the bottleneck? That a past bottleneck has disappeared everywhere?
* Did I treat an obstacle as permanent without asking who might solve it? A plausible solution as inevitable without checking incentives?
* Is the answer merely a refined version of the original consensus — and if it diverges nowhere, did any independent analysis actually happen?
* Am I being contrarian only because novelty is rewarded?

---

# Stop when marginal value falls

Stop research when: the major causal models are clear; additional sources repeat known mechanisms; remaining uncertainty is caused by future events rather than missing research; further agent work changes wording but not judgment; the key decision or observation plan is determined; and the O2O pass has separated likely-solvable from likely-persistent barriers. Stay within the budget in `SKILL.md`; exceed it only when decision stakes or evidentiary complexity justify it, and say so.
