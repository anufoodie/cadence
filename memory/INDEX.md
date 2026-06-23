# INDEX — `cadence` Project State

**Status:** Layered-extraction wave landed 2026-06-22. Core engine + reference instance (`examples/overture/`) both populated. New: 8 framework-shaped contracts, 3 new role contracts, 16 new RUNBOOK entries, ~25 sync-report backlog cleared.
**Last updated:** 2026-06-22
**Owner:** Cowork session (`cw-2026-06-22-layered-extraction-kickoff`)

This is the **rolling source of truth** for project state. It complements `design/canonical/` (binding spec content) — `canonical/` is *what we're building*; this file is *where we are right now*.

For the structure rationale see `memory/README.md`. For lookup discipline see AGENTS.md §0.

---

## Current State

- **Phase:** Cadence is at the **pluggable-engine + layered-architecture** shape. Core engine ships 4 CORE + 10 OPTIONAL + 9 EXTENDED features. Reference instance (`examples/overture/`) demonstrates a full instantiation.
- **Focus this week:** layered extraction wave (2026-06-22) — landed 4 sync-report 2026-06-14 HIGH proposals + 16 RUNBOOK entries from backlog + 8 new framework contracts + 3 new role contracts + 9 new feature toggles + scaffolded `examples/overture/`.
- **Major open thread:** the layered extraction is now landed pending host-side commits. See `handoff/notes/HOST-COMMIT-RECIPE-2026-06-22-WAVE-2.md` for the sequenced commit plan.
- **Recent landing:** sync-report 2026-06-14 backlog cleared (4 HIGH-confidence proposals: sandbox-vs-host Git boundary, adversarial-pass discipline, two living planning docs, wake checks).

---

## Ownership Model

Who owns what. Adapt per project; default starter (delete rows that don't apply):

| Layer | Owner | Notes |
|---|---|---|
| Product direction + priorities | `Anu Singh` | Final decision-maker |
| Architecture decisions | `Sync Architect (Cowork/Opus)` | Authors ADRs + decision-log entries |
| Spec / design | Orchestrator (Cowork) | Maintains canonical/ + features/ |
| Implementation | Executor (Codex / Claude Code) | Owns code + tests |
| Memory steward | Scheduled task | Daily reconciliation per `design/process/scheduled-tasks/memory-steward-prompt.md` |
| Observer / pulse-watch | Optional | Polls heartbeat for anomalies |

Roles defined in `design/process/agent-roles.md`.

---

## Build Progress

### How to read

This section tracks **per-slice / per-feature build state** as the project ships work. Status semantics:

- ✅ **Built / Shipped** — code reflects the spec; demo-ready.
- ⚠ **Partial** — code exists but predates current spec; drift reconciliation pending.
- 📄 **Spec only** — locked spec; no build yet.
- 🚧 **In flight** — actively being built.
- ⛔ **Blocked** — capture blocker in Notes.

(For canonical-alignment status against the foundation, see `design/canonical/implementation-status.md`.)

### Slices in flight

| Slice ID | Description | Status | Owner | Last update | Notes |
|---|---|---|---|---|---|
| — | — | — | — | — | — |

### Slices shipped (recent)

| Slice ID | Description | Shipped | Commit | Notes |
|---|---|---|---|---|
| — | — | — | — | — |

### Slices queued

| Slice ID | Description | Tier | Depends on |
|---|---|---|---|
| — | — | — | — |

---

## Decision Log (summary)

Brief summary of locked decisions. **Full entries live in `design/canonical/decisions.md`.** This section carries only the title + one-line decision; agents who need rationale read the canonical entry.

| ID | Title | Locked | One-line decision |
|---|---|---|---|
| — | — | — | — |

---

## Recent commits

Rolling list of the most recent ~10 commits with one-line summary. Memory steward refreshes this section.

| Commit | Date | Author | One-line summary |
|---|---|---|---|
| — | — | — | — |

---

## Architecture facts

Stable architecture facts the team relies on. Update sparingly; treat as near-canonical.

(Populate with stack choices, port allocations, key external integrations, etc. as they solidify.)

---

## Recent handoff briefs

| Brief | Author → target | Date | Status |
|---|---|---|---|
| — | — | — | — |

---

## Open threads

Threads that aren't blocking but need to be picked up later.

- — <one-line description, owner, expected resolution path>

---

## Drift items (open)

Drift items surfaced by the memory steward or working agents, not yet resolved.

| Drift ID | Source | Description | Owner | Status |
|---|---|---|---|---|
| — | — | — | — | — |

(Drift report archive in `memory/drift-reports/`.)

---

## See also

- `quick-reference.md` — hot cache for people / terms / slice IDs.
- `WORKING_DEFAULTS.md` — operating conventions.
- `../design/canonical/decisions.md` — full append-only decision log.
- `../design/canonical/implementation-status.md` — canonical-alignment view (complementary to per-slice build state above).
- `../design/process/operational-patterns.md` — emergent operational conventions (RUNBOOK).
