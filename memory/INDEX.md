# INDEX — `cadence` Project State

**Status:** Layered-extraction wave **committed + pushed 2026-06-23** (`anu-singh` @ `73d2c21..61e2a6c`). Core engine + reference instance (`examples/overture/`) both populated. New: 8 framework-shaped contracts, 3 new role contracts, 16 new RUNBOOK entries, ~25 sync-report backlog cleared.
**Last updated:** 2026-06-23
**Owner:** Cowork session (`cw-2026-06-22-layered-extraction-kickoff`) authored the wave; host-side commit + push by `claude-code-2026-06-23-host-commit-layered-extraction`

This is the **rolling source of truth** for project state. It complements `design/canonical/` (binding spec content) — `canonical/` is *what we're building*; this file is *where we are right now*.

For the structure rationale see `memory/README.md`. For lookup discipline see AGENTS.md §0.

---

## Current State

- **Phase:** Cadence is at the **pluggable-engine + layered-architecture** shape. Core engine ships 4 CORE + 10 OPTIONAL + 9 EXTENDED features. Reference instance (`examples/overture/`) demonstrates a full instantiation.
- **Focus this week:** layered extraction wave (2026-06-22) — landed 4 sync-report 2026-06-14 HIGH proposals + 16 RUNBOOK entries from backlog + 8 new framework contracts + 3 new role contracts + 9 new feature toggles + scaffolded `examples/overture/`.
- **Major open thread:** the layered extraction is **landed + pushed** to `anu-singh` (8 GPG-signed commits, 2026-06-23). Both `HOST-COMMIT-RECIPE-2026-06-22*.md` recipes were executed; left untracked on disk pending a retire decision. Next integration step: PR `anu-singh` → `main` when ready. The 12-commit recipe was consolidated to 8 (whole-file staging; no hunk-level split available) — see `memory/sessions/claude-code-2026-06-23-host-commit-layered-extraction.md`.
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
| `61e2a6c` | 2026-06-23 | Anu Singh | docs(layered): refresh README + INDEX for the layered-extraction wave |
| `4d3af9a` | 2026-06-23 | Anu Singh | feat(overture): populate reference instance with obfuscated Atlas example |
| `ed45ece` | 2026-06-23 | Anu Singh | feat(scripts-infra): reference stubs for project-specific tools |
| `5af8427` | 2026-06-23 | Anu Singh | feat(features): wire EXTENDED feature toggles for new contracts |
| `5fd6762` | 2026-06-23 | Anu Singh | feat(extended): 8 new framework-shaped contracts + layered scaffold |
| `0f60f42` | 2026-06-23 | Anu Singh | feat(runbook): §7 sandbox/host boundary rewrite + RUNBOOK entries 15-30 |
| `ff3f7c4` | 2026-06-23 | Anu Singh | feat(roles): Memory Steward writer clause + 3 new role contracts |
| `73d2c21` | 2026-06-23 | Anu Singh | feat(autonomy): land 2026-06-14 sync disciplines |
| `fa2f2a2` | 2026-06-22 | Anu Singh | docs(handoff): brief for async — canonical-catalog visual QA architecture |
| `bf3f6ef` | 2026-06-22 | Anu Singh | feat: make Cadence a pluggable engine with feature toggles |

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
