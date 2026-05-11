# Workflow

How to incorporate new feature areas, capture decisions, and evolve the canonical foundation. **5-stage workflow** — the shape `cadence` set as the framework default.

**Authority status:** CANONICAL (process). Adapt the stage names to your project's vocabulary if needed, but keep the shape — each stage exists for a reason captured in §8 below.

---

## §0. When to use this workflow

Use this when:

- A new feature area surfaces (e.g., a new screen, a new entity family, a new workflow).
- An existing feature area gets significant scope or shape changes that don't fit a quick edit.
- A decision needs to be captured and rationalized before implementation starts.

**Don't** use this for:

- Routine edits to existing canonical docs (typo fixes, minor clarifications). Just edit and commit.
- Single-decision-log entries. Append directly to `canonical/decisions.md` without running the full workflow.
- Implementation work itself. The workflow ends at "land in canonical/features"; coding agents take it from there per `canonical/implementation-plan.md`.

---

## §1. The 5 stages

```
Stage 1: Spec        → propose the feature area; user stories, JTBDs, sketches
Stage 2: Reconcile   → check against canonical/; identify drifts; lock decisions
Stage 3: Migrate     → land in features/<topic>/; canonical updates if needed
Stage 4: Handoff     → produce coding-agent-ready slice plan
Stage 5: Land        → ship; close loop in decision log
```

---

## §2. Stage 1 — Spec

**Goal:** capture what the feature is, who it's for, what it solves.

**Inputs:** problem statement, persona, sketch or mock if available.

**Outputs:**
- Draft `features/<NN-slug>/build-spec.md` — end-to-end design.
- Draft `features/<NN-slug>/user-stories.md` — JTBDs + acceptance criteria.
- Draft `features/<NN-slug>/README.md` — purpose, scope, owner, target personas, target surfaces.
- Initial `features/<NN-slug>/references.md` — placeholder for canonical citations (filled in Stage 2).

**Tools:**
- Copy `features/_template/` to start.
- Reference `canonical/` to identify which existing concepts this feature touches.

**Done when:** the spec is reviewable by a peer; user stories pass the "could a developer build this?" test.

---

## §3. Stage 2 — Reconcile

**Goal:** check the new feature against the canonical foundation. Identify drifts. Lock decisions.

**Inputs:** Stage 1 outputs + the canonical/ corpus.

**Outputs:**
- `features/<NN-slug>/references.md` filled in with:
  - Canonical citations (which `canonical/*.md` files this feature touches).
  - **Flagged drifts** — places where this feature requires changes to canonical content.
- One or more decision-log entries in `canonical/decisions.md` if drifts are substantive (`D-<TOPIC>-<NN>` with status `PROPOSED` → `LOCKED`).

**Process:**
1. Read the canonical docs this feature touches. Verify the proposed approach honors them.
2. List entities / rules / surfaces / operations the feature uses or extends.
3. Identify drifts: where canonical says X and feature wants Y.
4. For each drift: either change the feature to honor canonical, or flag for canonical update with a decision-log entry.

**Done when:** every drift is either resolved or has a locked decision documenting how it'll resolve.

---

## §4. Stage 3 — Migrate

**Goal:** land Stage 2's resolved drifts into canonical. Land the feature into `features/`.

**Outputs:**
- Canonical updates per Stage 2's locked decisions.
- `features/<NN-slug>/build-spec.md` finalized — references resolve to current canonical state.
- `features/<NN-slug>/references.md` "Flagged drifts" table marked resolved.

**Process:** atomic commits per concern. Don't bundle multiple unrelated canonical updates into one commit — separate commits keep the change log readable.

**Done when:** all Stage 2 drifts are in canonical, `references.md` shows zero unresolved drifts.

---

## §5. Stage 4 — Handoff

**Goal:** produce a coding-agent-ready slice plan.

**Outputs:**
- `features/<NN-slug>/agent-handoff.md` — what to build, in what order, against which canonical references.
- One or more slices added to `canonical/implementation-plan.md` with effort tier + dependencies.

**Per-slice content** (project-specific; the framework uses):
- Scope.
- Entities touched (cite `canonical/entity-model.md` if your project has one).
- Components to build / reuse (cite `canonical/component-library.md` if applicable).
- APIs to implement (cite `canonical/api-contracts.md` if applicable).
- Hard-wired rules to honor (cite `canonical/rules-catalog.md` if applicable).
- Reference renders or visual specs (if applicable).
- Quality gates (acceptance criteria).
- Out-of-scope.

**Done when:** an agent can pick up `agent-handoff.md` cold and start building without needing a sync.

---

## §6. Stage 5 — Land

**Goal:** ship; close the loop in canonical/.

**Outputs:**
- Code merged.
- `canonical/decisions.md` entries updated to status `SHIPPED` (or revised to `LANDED-WITH-DEVIATIONS` if implementation surfaced new constraints).
- `features/<NN-slug>/README.md` status flipped to "Shipped".
- New entries to `canonical/decisions.md` if implementation surfaced lessons that change canonical guidance.

**Done when:** decision-log entries reflect ship state; feature folder is stable.

---

## §7. Cross-cutting principles

These apply throughout all 5 stages:

1. **Single source of truth.** Each concern lives in exactly one canonical doc. Features cite canonical; canonical doesn't cite features.
2. **Append-only decisions.** Never delete or rewrite a decision-log entry. Revisions append.
3. **Visual specs supersede prose** (if your project has visual specs / reference renders). When in conflict, the locked visual wins.
4. **No retroactive rule application.** A new rule applies to surfaces locked after the rule, not before.
5. **Drift is fine; unflagged drift is not.** Drifts caught during Stage 2 are healthy. Drifts that ship without being flagged are the failure mode.
6. **One concern per commit.** Atomic commits keep the change log readable and bisectable.
7. **README in every folder.** No exceptions.

---

## §8. Failure modes to avoid

Lessons's design phase:

1. **Parallel doc spaces drift apart.** Don't create competing top-level doc spaces — extend `canonical/` or `features/` instead.
2. **Phase nomenclature in filenames is a mistake.** `phase-5a-entity-model.md` tells you nothing about what the file contains. Content-named files (`entity-model.md`) age better.
3. **Visual specs are essential** (if visual fidelity matters to your project). Mid-design rendering drift is a recurring failure — agents extrapolate from prose and silently change designs. Lock visual specs with each canonical surface.
4. **Append-only decision logs work.** Revisions add cleanly. Reader sees both the original and revision in chronological order.
5. **Don't promise to do drift reconciliation later if you haven't started.** Initial spec should already cite canonical correctly. Deferred reconciliation accumulates technical debt.
6. **5-stage workflow exists for a reason.** Skipping reconciliation (Stage 2) → ship surprises. Skipping handoff (Stage 4) → agents flail without context. Don't skip stages even when "the feature is small."

---

## §9. Tooling

Workflow can run with just files + git, but these helpers smooth common steps:

- **Find drifts:** `grep -r "<entity-name>" canonical/ features/<NN-slug>/` — surface where a name appears across the corpus.
- **Find broken references:** `grep -rE "(\.md|\.png|\.jpg)\)" features/<NN-slug>/` then verify each path resolves.
- **Find missing READMEs:** `find design/ -type d ! -path '*/.*' -exec test ! -f {}/README.md \; -print`.
- **Run the consistency check** in `consistency-checks.md` before any commit that touches `canonical/` or `features/`.

---

## §10. See also

- `conventions.md` — naming + Markdown style + cross-reference rules.
- `consistency-checks.md` — QA checklist before merging.
- `handoff-checklist.md` — coding-agent handoff prep.
- `operational-patterns.md` — emergent operational conventions (RUNBOOK).
- `drift-classes.md` — taxonomy of drift classes.
- `autonomy-gap-framework.md` — escalation tiers for self-resolve vs escalate.
- `agent-roles.md` — role-vs-session model.
