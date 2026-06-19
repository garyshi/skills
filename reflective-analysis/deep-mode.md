# Deep Mode — Detailed Procedure

This file holds the detailed procedures for the analysis steps indexed in `SKILL.md`. Read it when running deep mode (or when a focused-mode question turns out to need the trajectory/trend/feedback machinery). The Obstacle-to-Opportunity subagent has its own file: `obstacle-to-opportunity.md`.

Stay within the default deep-mode budget defined in `SKILL.md` (2–4 models, 3–5 subagents, one adversarial pass, one O2O pass, one synthesis pass).

> **Note on examples.** The lists below skew toward fast-moving technology and investment questions because that is where this skill is most used. They are *domain illustrations*, not a required checklist. For organizational, scientific, policy, or other questions, substitute the relevant variables — do not force the analysis into AI-adoption framing.

---

# Step 4: Check Freshness Before Using Evidence

For any fast-moving subject, classify evidence by both date and relevance. Ask:

* What system, technology, institution, or market regime was studied?
* Has the object of study materially changed since then?
* Is this evidence about current capability, historical capability, adoption, economics, or risk?
* Does the conclusion still apply, or only the underlying mechanism?
* Are newer observations available that directly test the same claim?
* Does this evidence describe a previous generation, a current generation, or a deployment pattern that still persists?

Old evidence is not automatically invalid, but it must not be treated as current evidence merely because it is rigorous.

When recent first-hand observations conflict with older formal evidence:

* preserve the formal evidence as a prior;
* treat the new observation as a possible update;
* investigate whether the underlying system has changed;
* avoid automatically privileging either source.

---

# Step 5: Analyze Trajectory, Not Just Freshness

For very fast-moving subjects, freshness is necessary but insufficient. Do not ask only "what is currently true?" Also ask: "how fast is it changing, and what would follow if the current rate of change continues, slows, or accelerates?"

Classify claims into three layers.

## Layer 1: Current Facts

What is directly supported by present evidence — current capabilities, deployment data, costs, benchmark results, user behavior, reliability, failure modes, regulatory constraints, business model, capital requirements. State these as facts only when evidence supports them.

## Layer 2: Observed Trajectory

What has changed over time — rate of improvement, release cadence, cost/latency decline, reliability and adoption growth, workflow and behavior change, ecosystem growth, capital investment, bottlenecks shifting between layers.

Prefer comparing multiple points in time over one recent snapshot. Ask:

* What improved between version N and version N+1?
* Did the improvement come from capability, tooling, data, workflow, infrastructure, regulation, or user adaptation?
* Is the change linear, exponential, stepwise, cyclical, or slowing?
* Are failures being eliminated, displaced, or hidden?
* Which bottlenecks are falling fastest? Which are not improving?
* Is the observed trend broad, or concentrated in curated cases?

## Layer 3: Reasonable Extrapolation

Make explicit projections from observed trajectory. Separate conservative, base-case, aggressive, and discontinuity/regime-change scenarios. For each, state what trend is being extended, over what horizon, what assumptions must hold, what would slow or accelerate it, and what would invalidate it.

Do not present extrapolation as fact. Use phrases such as "current evidence supports...", "the observed trajectory suggests...", "a reasonable extrapolation is...", "this requires assuming...", "this would fail if...".

---

# Step 6: Evaluate Trend Quality

Before relying on a trend, evaluate its quality.

**Measurement consistency.** Are the data points measuring the same thing over time? Beware comparing different benchmarks, task distributions, curated demos vs. real use, lab vs. production, gross capability vs. net workflow productivity, or claimed vs. realized financial savings.

**Saturation risk.** Is the trend approaching a hard or soft limit — physics, cost, data quality, latency, regulation, human trust, distribution, organizational adoption, liability, energy/infrastructure, adversarial pressure, diminishing marginal utility?

**Bottleneck migration.** When one bottleneck improves, another may dominate: capability improves but evaluation becomes limiting; generation cost falls but review cost rises; automation improves but integration/permissions limit; adoption grows but accountability or physical infrastructure limits. A good extrapolation tracks where the bottleneck moves.

**Feedback environment.** Trends continue more reliably when feedback is fast, frequent, low-noise, attributable, economically rewarded, and adversarially tested. They are less reliable when errors are silent, delayed, subjective, or hard to attribute.

**Incentive intensity.** Who has strong incentives to push the trend — capital, competition, open-source ecosystems, user pull, tooling, regulatory permission, strategic necessity, existential pressure on incumbents? A trend with strong economic pressure and rapid feedback deserves more extrapolation weight than one based mainly on demos.

**Historical analogy.** For each analogy, specify whether it matches the technical learning curve, cost curve, adoption curve, regulatory environment, market structure, feedback loop, or value-capture mechanism. Do not use analogy as evidence unless the mechanism matches.

---

# Step 7: Extrapolate With Discipline

Produce at least two versions.

**Mechanical extrapolation** — what happens if the measured trend simply continues (compute cost falls at the recent rate, capability improves at the recent cadence, adoption doubles on schedule, capital spending continues). Useful for mapping the possibility space; not a forecast by itself.

**Constraint-aware extrapolation** — what happens after accounting for bottlenecks, incentives, second-order effects, adoption friction, regulation, competition, capital intensity, supply constraints, customer behavior, feedback quality, and regime changes. Usually more decision-relevant.

Compare the two. If they diverge sharply, the key question is not the trend itself but the constraint that causes divergence.

---

# Step 8: Build Competing Causal Models

Construct 2–4 genuinely different explanations that differ in *mechanism*, not merely degree. For each, specify the central mechanism, assumptions, evidence it explains well, evidence it fails to explain, expected leading indicators, and conditions under which it would fail. Stop adding models once new ones no longer change the decision.

Example model archetypes (choose what fits; do not force every issue into these):

* **Constraint model** — progress is real but bounded by a bottleneck.
* **Capability-transfer model** — progress in one domain reflects more general underlying capability.
* **Workflow-reconstruction model** — the main change comes from redesigning the process, not substituting into the old one.
* **Commoditization model** — value is created but competition passes most of it to customers.
* **Bottleneck-shift model** — the old scarce factor becomes abundant; a new scarce factor captures value.
* **Regime-change model** — historical evidence is less predictive because the underlying system has changed.
* **Bubble / over-extrapolation model** — progress is real but already overcapitalized or overinterpreted.
* **Obstacle-to-opportunity model** — a serious barrier today may become the basis for a new control layer, product category, institution, or competitive advantage.

---

# Step 9: Analyze the Feedback Environment

Determine how errors and successes are discovered:

* **Feedback speed** — how long until the outcome becomes observable?
* **Feedback clarity** — can success or failure be attributed to the decision?
* **Selection pressure** — do weak approaches get quickly rejected or replaced?
* **Reversibility** — can mistakes be detected and corrected before major damage?
* **Correlation** — could one mistaken method produce the same error across many cases?
* **Silent error risk** — can an approach appear successful while producing hidden or delayed damage?

A system can improve rapidly without formal verification when feedback is fast, competitive, and attributable. A system may remain unreliable even with expert review when errors are delayed, ambiguous, or systematically shared.

---

# Step 11: Research Only Discriminating Evidence

Do not search broadly for everything relevant. Search for evidence that distinguishes the competing models. Prioritize:

1. direct observations and primary sources;
2. recent changes in behavior or outcomes;
3. evidence from environments resembling the real use case;
4. failure cases and hidden costs;
5. data that contradicts the leading model;
6. evidence about bottlenecks, not just progress;
7. evidence about value capture, not just value creation;
8. evidence about whether obstacles are being reduced in practice.

For each research branch ask: "What conclusion would change depending on what I find?" If the answer is "none," stop that branch.

---

# Step 12: Use Other Subagents Selectively

Do not create agents merely to increase perspective count. Use an agent only when it can perform a substantially independent task: collecting recent primary evidence, evaluating evidence freshness and system comparability, analyzing trajectory, constructing an alternative model, analyzing incentives or market structure, reconstructing a real workflow, attempting to falsify a specific thesis, evaluating whether a trend is approaching a constraint, or analyzing value creation vs. capture.

Agents should work independently before seeing one another's conclusions when correlated framing is a major risk. Do not use majority vote. Do not ask every agent to research the full question.

## Two Waves — the O2O Agent Runs Second

The deep-mode agents do **not** all launch at once. They run in two waves with a barrier between them, because the Obstacle-to-Opportunity agent's *input is the obstacles the first wave surfaces*. Launching O2O in the same parallel batch as the evidence agents — even though the harness encourages parallelizing independent calls — defeats its purpose: it gets no real obstacles and invents generic ones.

**Wave 1 — investigation (launch in parallel):**

1. **Fresh Evidence Agent** — current facts, recent changes, primary evidence.
2. **Trajectory Agent** — rate of change, release cadence, cost/capability curves, bottleneck migration, extrapolation quality.
3. **First-Principles Model Agent** — causal models from constraints, incentives, and mechanisms without leaning on consensus commentary.
4. **Adversarial Falsifier** — counterevidence, hidden costs, stale analogies, correlated failures, alternative explanations.

**Barrier — main session synthesizes (no agents):** wait for Wave 1 to return, then update the causal models and extract the concrete, named obstacles to the leading thesis. This obstacle list is the O2O agent's input.

**Wave 2 — Obstacle-to-Opportunity (launch after the barrier):**

5. **Obstacle-to-Opportunity Agent(s)** — mandatory in deep mode; seeded with the obstacles from the barrier. Single agent or fan-out per the coupling test in `obstacle-to-opportunity.md`.

Do not collapse the two waves. If you find yourself about to launch the O2O agent in the same message as the Fresh Evidence / Trajectory / Adversarial agents, stop — the obstacles do not exist yet.

Optional agents (Wave 1 unless they depend on Wave 1 output): **Workflow Analyst** (process-heavy domains), **Market / Value-Capture Analyst** (investment/strategy), **Regulatory / Institutional Analyst** (high-liability/policy), **Customer / User Behavior Analyst** (product adoption).

---

# Step 13: Run a Framing Review

Before synthesis, ask:

* Am I answering the original question or a nearby easier one?
* Did the initial framing determine the conclusion?
* Am I comparing reality with an idealized alternative?
* Did I confuse implementation difficulty with fundamental impossibility?
* Did I confuse an impressive case with broad applicability?
* Did I assume current workflows remain unchanged?
* Did I confuse value creation with value capture?
* Did I overweight evidence because it is formal but stale?
* Did I overweight evidence because it is recent but anecdotal?
* Did I treat a trend as fact?
* Did I extrapolate without checking constraints?
* Did I assume a current bottleneck will remain the bottleneck?
* Did I assume a past bottleneck has disappeared everywhere?
* Did I treat an obstacle as permanent without asking who might solve it?
* Did I treat a plausible solution as inevitable without checking incentives and implementation?
* Is the answer merely a refined version of the original consensus?
* Am I being contrarian only because novelty is rewarded?

---

# Step 14: Stop When Marginal Value Falls

Deep analysis should not expand indefinitely. Stop research when:

* the major causal models are clear;
* additional sources repeat known mechanisms;
* remaining uncertainty is caused by future events rather than missing research;
* further agent debate changes wording but not judgment;
* the key decision or observation plan is already determined;
* the Obstacle-to-Opportunity pass has identified which barriers are likely solvable and which are likely persistent.

Stay within the default deep-mode budget in `SKILL.md`. Exceed it only when decision stakes or evidentiary complexity justify it.
