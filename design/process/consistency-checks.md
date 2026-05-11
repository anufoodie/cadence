# Consistency Checks

QA checklist for the design corpus. **Run before any commit that touches `canonical/` or `features/`** and as a periodic audit.

**Authority status:** CANONICAL (process).

---

## §1. Why this exists

The design corpus is large and cross-referenced. Without periodic consistency checks:

- Cross-references rot when files move or rename.
- Canonical decisions and feature build specs drift apart.
- New surfaces land without visual specs, creating fidelity gaps (if your project uses visual specs).
- Append-only decision logs accumulate revisions that contradict locked entries.
- Two parallel doc spaces emerge.

A 30-minute consistency check catches most of this before it compounds.

---

## §2. Pre-commit checks (file-level)

Run before any commit that adds, moves, or substantially edits a `canonical/*` or `features/*` file.

### File hygiene

- [ ] Filename follows kebab-case + content-named per `conventions.md` §2.
- [ ] No phase numbers in filename.
- [ ] No date in filename unless under `archive/bridge-docs/`.
- [ ] If new folder, has a `README.md`.
- [ ] File ends with trailing newline.

### Cross-references inside the file

- [ ] All `[link](path)` references resolve (path exists from this file's location).
- [ ] All inline `` `path` `` references resolve.
- [ ] No broken references to old paths unless intentional historical citation.
- [ ] No references to phase-named files — should be content-named.

### Authority hierarchy honored

- [ ] If this file is in `canonical/`, it doesn't cite `features/`.
- [ ] If this file is in `features/`, references into `canonical/` use `../../canonical/...` paths.
- [ ] If this is a new surface (anchor / screen / module), it has a corresponding locked visual spec or an explicit pending status.

---

## §3. Cross-doc consistency (canonical-level)

Run periodically (e.g., after a substantive update to `canonical/`) and before any "feature complete" milestone.

### Decision-log integrity

- [ ] Every locked decision has a "Locked at:" date stamp.
- [ ] Every locked decision has a `D-<TOPIC>-<NN>` identifier.
- [ ] Append-only convention preserved (no entries deleted or rewritten in place).
- [ ] Revisions clearly mark prior entry as superseded.

### Entity / rule / API alignment (project-specific — adapt to your canonical structure)

- [ ] Every entity referenced in feature specs exists in `canonical/entity-model.md` (or your equivalent).
- [ ] Every rule referenced exists in `canonical/rules-catalog.md` with a value (or your equivalent).
- [ ] Every API operation referenced exists in `canonical/api-contracts.md` (or your equivalent).
- [ ] No contradictions between canonical docs.

### Visual fidelity (if your project has locked visual specs)

- [ ] Every locked surface has a visual spec.
- [ ] No "pending — spec not yet provided" rows unless explicitly tracked as a known gap.

---

## §4. Feature drift audit (per-feature)

Run when a feature is approaching "ready to build" or "shipped" status.

For each feature in `features/<NN-slug>/`:

- [ ] `README.md` exists with status, owner, target personas, target surfaces.
- [ ] `references.md` "Canonical citations" section is filled in with real paths (no placeholders).
- [ ] `references.md` "Flagged drifts" section is either empty (no drifts) or every drift has a resolution path.
- [ ] `build-spec.md` references resolve to current canonical state.
- [ ] `agent-handoff.md` cites at least one slice in `canonical/implementation-plan.md`.
- [ ] `user-stories.md` acceptance criteria map to specific canonical surfaces.

---

## §5. Handoff readiness criteria (release-level)

Run before declaring "design complete, agents can build."

### Green-light criteria

- [ ] All canonical surfaces locked with visual specs (if applicable).
- [ ] All decisions in current scope are LOCKED (no PROPOSED items blocking).
- [ ] Entity model formalized for all entities introduced/extended (if your project tracks an entity model).
- [ ] Hard-wired rules audited and classified.
- [ ] API contract surface specced for all surfaces in scope.
- [ ] Component library has the wrappers / primitives required.
- [ ] Vertical slices defined with dependency graph in `canonical/implementation-plan.md`.
- [ ] Drift resolutions captured + spec reconciled.
- [ ] Cross-document consistency verified.

### Yellow-light items (proceed with care, not blockers)

- [ ] Known-but-acceptable artifacts documented (e.g., append-only revision pairs).
- [ ] Open follow-up items tracked but not blocking.

### Red-light blockers

- [ ] Any surface without a locked visual spec (if visual specs are required).
- [ ] Any locked decision contradicting another locked decision.
- [ ] Any feature `references.md` with unresolved drifts marked as blocking.
- [ ] Any canonical pattern with broken cross-references.

---

## §6. What to do when checks fail

| Check failure | Action |
|---|---|
| File hygiene fail | Rename the file before commit; update any references that pointed to it. |
| Broken reference | Either fix the reference or, if intentional historical citation, add a comment explaining why. |
| Missing visual spec | Either lock-defer the surface (mark as "spec only, render pending") or pause the work until visual available. |
| Entity referenced but not in entity-model | Either add the entity or remove the reference. Don't ship with phantom entities. |
| Rule referenced but not in rules-catalog | Either add the rule (with classification) or remove the reference. |
| Decision-log entry rewritten in place | Restore the original entry; append a new revision entry per `conventions.md` §5.1. |
| Visual spec conflicts with prose | Update the prose. Visual wins per `conventions.md` §4. |
| Two locked decisions contradict | Surface as a high-priority decision-log entry; one must supersede the other. Don't ship with contradictions. |

---

## §7. Periodic audit cadence

- **Weekly:** spot-check one surface across all dimensions.
- **Monthly:** full §3 cross-doc consistency pass.
- **Pre-release:** full §5 handoff readiness assessment.
- **After major commit set (3+ stages):** §2 + §3 pass.

---

## §8. See also

- `conventions.md` — what's being checked.
- `workflow.md` — the 5-stage workflow that produces consistency-correct work.
- `handoff-checklist.md` — readiness criteria for coding-agent handoff (overlaps with §5 here).
