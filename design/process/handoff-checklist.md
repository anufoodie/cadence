# Coding-Agent Handoff Checklist

Pre-flight check before handing implementation work to a coding agent (or team of agents). **Run this when a feature is moving from design to build.**

**Authority status:** CANONICAL (process).

---

## §1. Why this exists

Coding agents are most effective when they pick up a self-contained slice with explicit dependencies, acceptance criteria, and reference points. Handoff failures usually trace to one of:

- Missing context (agent has to ask, blocking work).
- Implicit dependencies (agent builds X assuming Y exists, Y doesn't yet).
- Drift between design and canonical (agent honors design that was superseded).
- No locked visual spec (agent extrapolates visual decisions, drifts from intent).

This checklist catches those before the handoff.

---

## §2. Pre-handoff: does this feature have everything?

Run for the feature being handed off (`features/<NN-slug>/`):

### Documentation completeness

- [ ] `README.md` — purpose, scope, owner, target personas, target surfaces, status.
- [ ] `build-spec.md` — end-to-end design with no TBDs in critical paths.
- [ ] `user-stories.md` — JTBDs with acceptance criteria.
- [ ] `agent-handoff.md` — slice plan with explicit dependencies + acceptance criteria.
- [ ] `references.md` — canonical citations resolved; "Flagged drifts" empty or marked resolved.

### Canonical alignment

- [ ] All entities used by this feature exist in `canonical/entity-model.md` (or your equivalent).
- [ ] All rules cited by this feature exist in `canonical/rules-catalog.md` with values (or your equivalent).
- [ ] All APIs needed exist in `canonical/api-contracts.md` (or your equivalent).
- [ ] All UI components either exist in `canonical/component-library.md` or are listed as "build new" in `agent-handoff.md`.
- [ ] All AI / LLM surfaces (if any) are specced in canonical (or your equivalent).
- [ ] Surfaces this feature touches have locked visual specs (if your project uses them).

### Slice plan

- [ ] Each slice in `agent-handoff.md` cites a slice in `canonical/implementation-plan.md`.
- [ ] Each slice has explicit `Depends on:` entries listing prerequisite slices.
- [ ] Each slice has a clear "Acceptance criteria" — testable conditions.
- [ ] Each slice has effort estimate (tier 1 / 2 / 3 or hours/days).
- [ ] Out-of-scope items listed explicitly to prevent scope creep.

---

## §3. Quality gates the agent must satisfy before merge

Encoded in `agent-handoff.md` per slice. Gate categories:

### Entity gates

- [ ] All migrations land cleanly against current schema.
- [ ] No new entities introduced beyond what's in canonical (or canonical updated first).
- [ ] Foreign keys + relationships honor canonical definitions.

### API gates

- [ ] Request shapes match canonical contracts.
- [ ] Response shapes match canonical contracts.
- [ ] Error responses follow canonical error patterns.
- [ ] Mutations that need audit log entries actually write them.

### Hard-wired rule gates

- [ ] All rule values from `rules-catalog.md` match exactly (no rounding, no "approximately").
- [ ] Classifications honored.
- [ ] No new hard-wired values introduced without a rules-catalog entry.

### Visual fidelity gates (if applicable)

- [ ] Locked visual spec for each touched surface matches the build (within accessibility-relevant tolerance).
- [ ] Color / spacing / type tokens align to canonical wrappers and design-system source.
- [ ] No drift on layout primitives.

### Acceptance criteria

- [ ] All user stories pass acceptance tests.
- [ ] No regression in adjacent features (run cross-feature consistency check).

---

## §4. Drift prevention

The most expensive failure mode is silent drift — agents extrapolate from design and ship something subtly different.

**Counter-measures:**

1. **Locked visual specs are supreme fidelity authority.** When prose conflicts with locked visual, locked visual wins.
2. **No retroactive rule application.** A new rule applies to surfaces locked after the rule, not before. The agent should NOT apply newer rules to older surfaces.
3. **Cite, don't paraphrase.** When `agent-handoff.md` describes a surface, it links to the canonical pattern rather than restating the layout. Reduces transcription error.
4. **Pre-merge consistency check.** Run `consistency-checks.md` §5 before merging the feature. Fails are blocking.

---

## §5. Multi-agent coordination

If multiple agents are working in parallel:

- [ ] Each agent has a non-overlapping slice scope (no two agents editing the same canonical doc).
- [ ] Shared component changes are blocked into one slice owned by one agent.
- [ ] Cross-slice dependencies are explicit in the dependency graph in `canonical/implementation-plan.md`.
- [ ] Daily sync surface (status report or commit log) keeps everyone aware of cross-slice changes.
- [ ] Each agent runs §2 + §3 checks against their slice before merging.
- [ ] Each session has its own worktree per `multi-session-workflow.md`.
- [ ] Each session emits heartbeat events per `operational-patterns.md` Entry 5.

---

## §6. After-handoff: what stays open

After the handoff is complete and agents pick up the work, the design corpus has these responsibilities:

1. **Respond to drift questions promptly.** Agents asking "is this what you meant?" should hear back within hours, not days.
2. **Append decisions to `canonical/decisions.md`** when implementation surfaces ambiguity that requires a call.
3. **Update `canonical/*.md` docs when implementation surfaces new constraints** that should bind future work.
4. **Run `consistency-checks.md` §3 monthly** to catch drift between code and canonical.
5. **Don't merge code that requires canonical to change** — canonical changes first, code changes second. Per `workflow.md` §3.

---

## §7. Handoff failure modes (lessons from prior cycles)

| Failure | What went wrong | Counter |
|---|---|---|
| Rendering drift on retrofit | Agent applied newer rule to older surface | Locked visual spec = supreme authority; no retroactive rule application. |
| Two parallel doc spaces | Competing doc spaces evolved without sync | One canonical corpus; features cite canonical, never the reverse. |
| Phase-named files | `phase-5a-entity-model.md` told nothing | Content-named filenames per `conventions.md` §2. |
| Decision rewrites | Locked decision edited in place | Append-only convention; revisions append. |
| Component sprawl | Agents built ad-hoc components instead of using wrappers | `component-library.md` is binding; new components require canonical update first. |
| Implicit dependencies | Slice X assumed slice Y was done | Explicit dependency graph in `implementation-plan.md`. |

---

## §8. See also

- `workflow.md` — the 5-stage workflow producing handoff-ready work.
- `conventions.md` — naming + reference rules.
- `consistency-checks.md` — QA checklist (overlaps with §2 + §3 here, broader scope).
- `operational-patterns.md` — RUNBOOK that an executor consults during the build.
- `agent-roles.md` — role contracts; clarifies who's executing vs reviewing.
