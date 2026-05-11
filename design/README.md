# Design

Single entry point for the `cadence` design corpus.

---

## Layout

Five top-level folders. Every folder carries its own `README.md` indexing contents and pointing to siblings.

| Folder | Purpose |
|---|---|
| `canonical/` | Horizontal foundation — decisions, ADRs, implementation plan + status, and project-specific spec content (entity model, rules catalog, anchor patterns, component library, etc. as your project requires) |
| `features/` | Vertical deep-dives — per-feature build specs, agent handoffs, user stories, references back to canonical |
| `process/` | Operating manual — workflow, conventions, consistency checks, handoff checklist, operational-patterns RUNBOOK, drift-classes, autonomy-gap framework, agent-roles, scripts, scheduled-tasks |
| `archive/` | Historical artifacts (read-only) — superseded specs, bridge docs |
| `references/` | Supporting material — glossary, idea registers, templates |

---

## Reading order for new collaborators

1. `canonical/README.md` — start here. The foundation everything else builds on.
2. `canonical/decisions.md` — append-only decision log with rationale.
3. `process/workflow.md` — how new areas get incorporated.
4. `process/operational-patterns.md` — emergent operational conventions (RUNBOOK).
5. `process/agent-roles.md` — role-vs-session model.
6. `process/drift-classes.md` — taxonomy of drift classes.
7. `process/autonomy-gap-framework.md` — escalation tiers (Tier 0–3).
8. `features/README.md` — vertical deep-dives + how to add a new feature.

## Reading order for coding agents

1. `canonical/implementation-status.md` — to know which slices are built / partial / pending.
2. `canonical/` — your project-specific foundation (entity model, rules, APIs, components, anchor patterns, etc.).
3. `process/handoff-checklist.md` — quality gates before merge.
4. `process/operational-patterns.md` — RUNBOOK conventions an executor must follow.
5. `features/<NN-topic>/agent-handoff.md` — the specific slice you're picking up.

---

## Conventions (full rules in `process/conventions.md`)

- Folders and files: lowercase kebab-case, content-named, stable.
- No phase numbers, no dates in filenames (except `archive/bridge-docs/` where dates serve as anchors).
- Numbered series: `NN-name.md`.
- Cross-references via path: `canonical/anchor-patterns/01-pm-home.md` — never "the PM Home pattern doc".
- Single source of truth: each concern lives in exactly one canonical doc. Features cite canonical; canonical never cites features.
- Locked visual specs supersede prose. When in conflict, the locked visual wins.
- Append-only decisions. Revisions append a new entry rather than rewriting in place.

## Authority hierarchy

(Adapt per project. Default:)

1. Locked visual specs (`canonical/reference-renders/` or equivalent) — supreme fidelity authority.
2. Cross-cutting rules (e.g., `canonical/shell-rules.md`).
3. Surface patterns (`canonical/anchor-patterns/`).
4. Entity model + rules catalog + API contracts + component library + LLM wiring — implementation specs.
5. Decision log (`canonical/decisions.md`) — append-only record with rationale.
6. ADRs (`canonical/adrs/`) — architecture decision records.
7. Feature build specs (`features/<topic>/build-spec.md`).

When two canonical docs conflict, the more specific wins.

---

## Provenance

This design corpus shape is distilled from empirical multi-agent operation. See top-level `README.md` for full provenance and instantiation notes.
