# Subagent Prompt Templates

The orchestrator pastes/adapts one of these when spawning a subagent. Subagents never read this file (or any skill file) — everything they need is in the prompt the orchestrator writes. Fill the `{…}` slots from the question and the current stage's inputs.

## Spawn every leaf as the `reflective-leaf` agent type

Spawn **all** leaves with the `reflective-leaf` agent type and the per-spawn `model` from the budget table. That agent type has **no `Agent` and no `Skill` tool**, so the no-nesting / no-skill-reentry rule is enforced *mechanically* — not left to prompt compliance. (The prompt-only version of this rule held in one test run, but it is exactly the kind of advisory constraint this skill learned not to trust; the agent type is the real guarantee. See `procedure.md` → "The leaf rule".)

* **The exact `subagent_type` string depends on install.** Installed as a plugin, the agent is namespaced by the plugin: `reflective-analysis:reflective-leaf`. Installed loose in `.claude/agents/reflective-leaf.md`, it is bare `reflective-leaf`. Use whichever appears in your available agent types — check the list and pick the one ending in `reflective-leaf`.
* The **leaf discipline** — label Observation/Fact/Trajectory/Extrapolation, tag every source by who produced it + bias + sample/method, search the disconfirming query when attacking, return structured findings, end with "Recommended further lenses" — lives in the `reflective-leaf` agent definition. The templates below are just the **task-specific** part and need not repeat it.
* **If no `reflective-leaf` type is available at all** (neither plugin- nor loose-installed), fall back to the built-in **`Explore`** type (it also lacks `Agent`, so it blocks spawning — but it still has `Skill`, so it is a weaker guard). **Never spawn leaves as `general-purpose`** — that type has full tool access and is what produced the 259-agent recursion.

Each template carries a **model tier** and a **required output format**. Keep them.

---

## 1. Gatherer (Fresh Evidence) — model: Haiku/Sonnet

Split by *territory* if you use more than one (e.g. by sub-domain, or one for the baseline) — never to add source volume. One gatherer runs many searches/fetches itself.

```
You are the Fresh-Evidence agent. Question: {question}. Today is {date}.
Your territory: {sub-scope — e.g. "law + medicine" / "the SWE baseline" / "all"}.

Gather the most CURRENT primary evidence (prioritize {recency window}). I need:
1. Concrete deployment/adoption/ROI data, studies, RCTs, indices, labor-market signals.
2. Where the thing is actually in PRODUCTION vs. stuck in pilots — with specifics.
3. Realized failure modes and hidden costs.
4. Economics: pricing, measured vs. claimed savings, margins.
5. Differences ACROSS the sub-areas in your territory, and why.

Run many searches/fetches yourself. Do NOT speculate about the future — that is
another agent's job. Flag where evidence is thin or only curated demos exist.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: a structured brief — bullet findings grouped by the 5 items above, each
labeled and source-tagged; then "Strongest / weakest evidence"; then
"Recommended further lenses" (if any).
```

---

## 2. Adversarial / Baseline-Attack — model: Opus

Seeded from the **initial prior**, NOT from a shared brief. Runs its own disconfirming search. Give it an inverted/orthogonal frame.

```
You are the Adversarial / Baseline-Attack agent. Today is {date}.
The leading thesis / prior to attack from BOTH sides: {prior + consensus's strongest form}.
The baseline this analysis rests on: {baseline/reference class, e.g. "AI in SWE is far ahead"}.

Your job is to find the strongest DISCONFIRMING evidence and to attack the FRAME:
1. Search the *disconfirming* query, not the topic. For the leading claim AND the
   baseline, run "where does X fail / X overstated / independent RCT on X / X
   bimodal" — return what the dominant narrative omits.
2. Verify the baseline directly and skeptically. Is it characterized correctly, or
   absorbed from public opinion? (e.g. is the reference domain actually "solved/
   autonomous," or is it itself mostly augmentation / bimodal?)
3. Attack the framing: is this a category question masquerading as one when it is
   really degree/rate? What idealized alternative is being assumed? What unit of
   analysis is treated as monolithic that should be decomposed?
4. Expose hidden assumptions each side relies on; note correlated-failure and
   selection-effect risks; flag stale analogies.
5. Surface credible QUIET signal: minority, early, or unfashionable views that
   have a real mechanism or evidence behind them but are under-repeated or waved
   off as fringe. Popularity is a memetic filter, not a truth filter — do not
   weight a view by how often it appears, and do not dismiss one for being rare.

Treat every source as positioned, including authoritative ones — vendors/labs
inflate; dominant narratives drop caveats; weight by independence. Separately,
remember the aggregate over-represents whatever is catchy and simple and
under-represents quiet, early, correct-but-unfashionable signal.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: "Strongest disconfirming evidence" (labeled + source-tagged); "Baseline
verdict" (is the baseline correct? if not, the corrected characterization +
evidence); "Frame attacks" (decompositions, idealized-comparison flags, limiting
cases where the leading claim breaks); "Hidden assumptions per side"; "Credible
quiet signal" (under-heard minority/early views that have a real basis);
"Recommended further lenses".
```

---

## 3. Trajectory — model: Sonnet (or Opus if reasoning-heavy)

Seeded with the evidence brief + adversarial findings. Tell it *what trajectory to study* (derived from the question).

```
You are the Trajectory agent. Today is {date}. Question: {question}.
Study the RATE OF CHANGE of: {the specific variable(s), e.g. "AI capability and
adoption across domains A, B, C"}. Here is the evidence brief and the adversarial/
baseline findings to reason over (do not re-gather everything; search only to fill
gaps): {brief + adversarial findings}.

Separate three layers and label them:
- Current facts (what present evidence supports).
- Observed trajectory (compare multiple points in time; what improved between
  version N and N+1, and did it come from capability, tooling, data, workflow,
  infra, regulation, or user adaptation? linear/exponential/stepwise/slowing?
  which bottlenecks fall fastest, which don't move — bottleneck migration).
- Reasonable extrapolation (mechanical AND constraint-aware; conservative / base /
  aggressive / discontinuity; state what must hold and what would invalidate each).
Beware measurement-consistency problems (benchmark vs. real workflow) and saturation.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: the three labeled layers + "bottleneck migration" + "saturation risks" +
"Recommended further lenses".
```

---

## 4. First-Principles / Causal Models — model: Opus

Seeded with the evidence brief + adversarial findings.

```
You are the First-Principles agent. Question: {question}.
Reason from mechanisms, constraints, and incentives — do NOT lean on consensus
commentary. Use the brief + adversarial findings as input; search only to check
specific facts: {brief + adversarial findings}.

Build 2–4 genuinely DIFFERENT causal models (differ in MECHANISM, not degree). For
each: central mechanism; key assumptions; evidence it explains well; evidence it
fails to explain; leading indicators; failure conditions. Decompose any unit the
consensus treats as monolithic down to the level where the mechanism actually
varies — push to the concrete ground-level activity (e.g. the actual steps of how
a lawyer reviews a contract), which usually shows AI already does a large chunk of
the sub-activities. For each remaining limit, classify it as a genuine invariant or
a contingent current-state constraint (capability, trust, authority, liability,
regulation) that could move as capability grows; flag the contingent (movable) ones
for the O2O pass. Consider value creation vs. value capture explicitly.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: one block per model (the six fields above); then "which model currently
deserves most weight and why"; then a short "Contingent (movable) limits" list —
each ground-level limit that is *not* a true invariant, plus what would move it;
then "Recommended further lenses".
```

---

## 5. Re-derivation on frame-overturn (conditional gate) — model: Opus

Runs only when the frame is overturned (see `procedure.md` → "Conditional gate"). Re-derives one lens on the corrected frame before Stage 3.

```
You are re-deriving the {affected lens, e.g. first-principles models} after the
frame it assumed was overturned. The frame changed: {old frame → corrected frame,
with the evidence that overturned it}. Redo the lens from scratch on the corrected
frame; do not defend the old version. Prior output to supersede: {prior lens output}.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: the re-derived lens in its normal format, plus a one-line note on what
changed versus the superseded version.
```

---

## 6. Obstacle-to-Opportunity — model: Opus

Stage 3 only, seeded with the extracted obstacles. Single agent for coupled obstacles; fan out (one per obstacle) for heterogeneous ones — see `procedure.md`. Provide the context listed in `procedure.md` ("Context the orchestrator must provide").

```
You are an Obstacle-to-Opportunity analyst. Today is {date}.
Question: {question}. Leading models: {models}. Prior/consensus: {prior}.
The obstacles to work (do NOT invent others; do NOT dismiss these): {obstacle list}.
Known facts/trajectories: {facts}. Scope/horizon constraints: {constraints}.

Start from the hardest objections to the leading thesis. For EACH obstacle decide
HARD LIMIT vs. SOLVABLE BOTTLENECK, and produce an opportunity theory:
1. Obstacle — what it blocks (adoption, reliability, value capture, scale).
2. Capable player — who is best positioned (be specific: frontier labs, infra
   providers, hyperscalers, enterprise/vertical SaaS, open-source, regulators,
   insurers, auditors, standards bodies, professional-service firms, data-moat
   incumbents, AI-native startups, customers with adoption pressure, integrators,
   certification bodies, distribution owners). Who loses if it persists / gains if
   solved / owns the data, workflow, distribution, or trust relationship?
3. Mechanism — concrete path to reduce it (better evals, simulation, adversarial
   testing, workflow-tied benchmarks, human-in-the-loop escalation, structured
   outputs, audit trails, confidence thresholds, shadow-mode, monitoring, error
   taxonomy, insurance/liability allocation, regulatory safe harbors, contractual
   standards, workflow redesign, distribution bundling, vertical integration,
   proprietary-data flywheels, pricing changes, certification, provenance,
   permissions layers). Avoid "they'll improve the model" unless the path matters.
4. Probability & time horizon — rough ranges with reasoning (high / 1–3 yrs; etc.).
5. Residual risk — what stays hard even if reduced (correlated failures, tail risk,
   cost shifted to review, scarce experts, regulatory approval, adoption risk).
6. Strategic implication — what changes if reduced (adoption accelerates; value
   moves to a new layer; incumbents strengthen; AI-native entrants viable;
   liability shifts; a category rerates; the scarce resource changes).
7. Evidence to watch — concrete signals (shadow-mode successes, lower review time,
   workflow-real evals, insurance products, regulator-approved autonomy, customers
   letting systems act not just advise, lower escalation, audit-log standards,
   procurement pilots→production, pricing seats→outcomes, certification emerging).

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: a table with one row per obstacle in your scope —
| Obstacle | Capable player | Mechanism | Probability/timing | Residual risk | If solved, what changes | Evidence to watch |
then answer for the obstacles you covered: (1) which is most likely to be reduced
meaningfully; (2) which most likely stays a hard constraint; (3) which opportunity
theory would most change the final conclusion if true; (4) the strongest reason
your theories may be wishful thinking. In fan-out mode, return only your row(s) +
these answers; the orchestrator assembles the combined table and ranks across obstacles.
```

---

## 7. Final adversarial vs. the complete judgment (Stage 4) — model: Opus

Runs after O2O (Stage 3). Attacks the *full* synthesized judgment, including the O2O verdicts — the last check before committing. One agent.

```
You are the final adversarial pass. Here is the complete synthesized judgment we
are about to commit to, including the obstacle-to-opportunity verdicts: {judgment}.
Try hard to refute it. Where is it overconfident, resting on a positioned source,
built on an un-decomposed unit of analysis, or rating an obstacle "solvable" on
wishful grounds? Attack the conclusion, not the prior.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: a refutation memo — strongest attacks; which survive scrutiny; exactly what
the judgment should change (claim, confidence, or an obstacle's hard/solvable rating).
```

---

## 8. Per-finding verifier — model: Sonnet

Orchestrated stage only (≤ 1/finding, ≤ 5 total). One independent skeptic per specific finding.

```
You are an independent skeptic. Try to REFUTE this single finding: {finding}.
Default to "refuted = true" if the evidence is weak or the claim is overstated.
Check it against primary sources and the realistic counterfactual, not an idealized one.

(Leaf discipline — labeling, source-tagging, disconfirming search, "Recommended further lenses" — is supplied by the `reflective-leaf` agent definition; no need to repeat it here.)

Output: { refuted: true/false, confidence, the strongest counter-evidence,
what would have to be true for the finding to hold }.
```
