# Step 10: Obstacle-to-Opportunity Subagent (Mandatory in Deep Mode)

In deep mode this step is mandatory. It is the **second wave** of agents, not part of the first (see "Two Waves" in `deep-mode.md`). Launch the **Obstacle-to-Opportunity subagent only after** the Wave 1 investigation agents (Fresh Evidence, Trajectory, First-Principles Model, Adversarial Falsifier) have returned and the main session has extracted the concrete, named obstacles to the leading thesis. Those obstacles are the agent's input.

Do **not** launch this agent in the same parallel batch as the Wave 1 agents. If the obstacles have not been surfaced yet, the agent has nothing real to work on and will fabricate generic ones — which is the most common failure mode of this step.

Do not ask the subagent a generic question like "find opportunities." Provide context, but not so much intermediate discussion that it merely imitates the main session — give it enough to reason while preserving independence.

## One Agent or Several?

Decide by how *coupled* the obstacles are, not how many there are.

* **Coupled obstacles within one domain** — they share players and evidence and trade off against each other (e.g. verification cost vs. review cost, where solving one shifts the bottleneck to the other). Use a **single** O2O agent. The obstacles only make sense relative to each other, so reasoning about them together is an advantage.
* **Heterogeneous obstacles spanning domains** — different evidence sources, different players, different time horizons, little mechanistic interaction (e.g. for an AI-investment thesis: model-capability trajectory vs. regulatory environment vs. public opinion vs. supply chain). **Fan out, one agent per obstacle.** A single agent would dilute depth across domains, regress to generalist reasoning, and let one obstacle's framing bleed into the others.

Each agent still summarizes, compares, and ranks *within its own scope*. Cross-obstacle synthesis — ranking obstacles against each other and deciding which most changes the thesis — is the main session's job, as always; this is harder, not easier, when the obstacles are non-commensurable, which is exactly why it stays with the main session rather than any single agent.

**Tripwire:** if an obstacle is large enough to be its own reflective-analysis question (e.g. "foundational model capability trajectory"), give it its own agent — or treat it as a separate analysis — rather than a row in a shared table. Count all these agents against the deep-mode budget.

> The example lists below skew toward technology and investment questions. Treat them as domain illustrations and substitute the relevant players, mechanisms, and signals for other domains.

## Context the Main Session Must Provide

1. the original user question;
2. relevant user observations or hypotheses;
3. the initial consensus model or default prior;
4. the current leading causal models;
5. the strongest objections or obstacles identified so far;
6. known facts and trajectories that matter;
7. any constraints on scope, time horizon, or decision relevance;
8. what kind of output is needed.

## Subagent Mission

Start from the hardest objections to the leading thesis. For each objection, ask:

* Is this a hard limit or a solvable bottleneck?
* Which capable player has both incentive and ability to solve it?
* What concrete mechanism could reduce the obstacle?
* How long would that mechanism likely take?
* What probability should be assigned?
* If solved, how much would the original conclusion change?
* What evidence would show the obstacle is being reduced in practice?

The subagent must not dismiss obstacles. Its job is to find whether serious obstacles can become technological, institutional, strategic, or investable opportunities.

## Capable Player Categories

Consider players such as: frontier labs; infrastructure providers; hyperscalers; enterprise software platforms; vertical SaaS providers; open-source ecosystems; regulators; insurers; auditors; standards bodies; professional service firms; incumbents with proprietary data; AI-native startups; customers with strong internal adoption pressure; attackers/adversaries who expose weaknesses; system integrators; certification bodies; platform owners with distribution. Identify specific types of players, not vague categories, when possible.

## Opportunity-Theory Template

For each major obstacle, produce an opportunity theory with these parts.

### 1. Obstacle
What blocks adoption, reliability, value capture, or scale? (e.g. verification difficulty, silent errors, liability, lack of integration, human trust, data access, workflow ambiguity, review cost, adversarial misuse, switching cost, regulatory uncertainty, capital intensity, distribution bottleneck.)

### 2. Capable Player
Who is best positioned to address it? Ask: who loses money if it remains? who gains disproportionately if it is solved? who owns the relevant data, workflow, distribution, or trust relationship? who can run enough experiments to learn quickly? who can impose standards or change behavior? who can absorb early failure costs?

### 3. Mechanism
How could the player reduce the obstacle? Be specific. Possible mechanisms: better evals; simulation; adversarial testing; benchmark suites tied to real workflows; human-in-the-loop escalation; role-specific skills/playbooks; structured intermediate outputs; audit trails; confidence thresholds; shadow-mode deployment; automated monitoring; error taxonomy; insurance and liability allocation; regulatory safe harbors; contractual standards; workflow redesign; distribution bundling; vertical integration; proprietary data flywheels; pricing-model changes; certification; marketplace reputation systems; cryptographic provenance; permissions/access-control layers; real-time anomaly detection; post-deployment monitoring. Avoid vague statements like "they will improve the model" unless the concrete path matters.

### 4. Probability and Time Horizon
Estimate implementation probability and timing in rough ranges, not false precision (e.g. high / 1–3 yrs; medium / 3–5 yrs; low / 5–10 yrs; plausible but not actionable yet; technically possible but institutionally unlikely). Explain why.

### 5. Residual Risk
Even if reduced, what remains hard? Does the solution only work in structured cases? Create correlated failures? Shift cost from execution to review? Rely on scarce experts? Require regulatory approval? Improve average performance while leaving tail risk? Reduce technical risk but not adoption risk? Create a new bottleneck?

### 6. Strategic Implication
If the obstacle is reduced, what changes? (e.g. adoption accelerates; value moves to a new layer; incumbents strengthen; AI-native entrants become viable; infrastructure demand rises; review labor becomes the bottleneck; liability shifts to vendors/insurers; a category rerates; a weak thesis becomes strong; a new control layer becomes valuable; the primary scarce resource changes.)

### 7. Evidence to Watch
Concrete signals: successful shadow-mode deployments; reduced human review time; public evals on real workflows; insurance products covering automated decisions; regulator-approved automated workflows; customers letting systems act, not just advise; lower escalation rates; standardized audit logs; procurement shifting from pilots to production; pricing moving from seats to outcomes; incident rates stable at higher automation; certification standards emerging; integration into systems of record; measurable drops in false positives/negatives; adversarial robustness improving under real attack.

## Required Subagent Output Format

Each agent returns a compact table — one row per obstacle in its scope — plus a short synthesis:

```markdown
| Obstacle | Capable player | Solution mechanism | Probability / timing | Residual risk | If solved, what changes? | Evidence to watch |
|---|---|---|---|---|---|---|
| ... | ... | ... | ... | ... | ... | ... |
```

In single-agent mode this is the full table. In fan-out mode each agent returns its own row(s) and the in-scope synthesis below, and the main session assembles the combined table and does the cross-obstacle ranking.

After its rows, each agent answers, *for the obstacles it covered*:

1. Which obstacle is most likely to be reduced meaningfully?
2. Which obstacle is most likely to remain a hard constraint?
3. Which opportunity theory would most change the final conclusion if true?
4. What is the strongest reason the opportunity theory may be wishful thinking?

## Main Session Responsibility After the Subagent Returns

Do not paste the subagent report. Integrate its findings. Update which obstacles are hard limits, which are temporary bottlenecks, which may become new business opportunities or control layers, how the leading causal models change, what probability/timing assumptions change, and what evidence to watch next. **Explicitly state whether the Obstacle-to-Opportunity pass changed the conclusion.**
