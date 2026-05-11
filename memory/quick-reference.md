# Quick Reference — Hot Cache

**Always-loaded decoder for project shorthand.** First lookup target for any unknown term, name, or slice ID. All agents reach it via the same path (`AGENTS.md` §0).

If something isn't here, fall through to `INDEX.md` → `design/canonical/` → `design/features/` → ask the user.

**Update rule:** add entries when a term first surfaces; promote frequent items; demote stale ones (move to a future `memory/glossary.md` when this file gets too long).

---

## People

### Team

| Who | Role |
|---|---|
| `Anu Singh` | Product owner / final decision-maker |
| _(add team members as they join)_ | |

### Agents

| Who | Role | Bootstrap path |
|---|---|---|
| **Cowork** | Claude chat session — planning, design, orchestration | reads `CLAUDE.md` → `AGENTS.md` |
| **Codex** | OpenAI coding agent CLI | auto-reads `AGENTS.md` |
| **Claude Code** | Anthropic coding agent CLI | reads `CLAUDE.md` → `AGENTS.md` |
| **Memory Steward** | Scheduled task | auto-reads `AGENTS.md` + steward prompt |

---

## Terms

### Roles + concepts (project-specific — populate as the project takes shape)

| Term | Meaning |
|---|---|
| _(add your team's acronyms, role tags, domain shorthand)_ | |

### Workflow vocabulary (framework-provided defaults — keep or adapt)

| Term | Meaning |
|---|---|
| **slice** | Coherent unit of implementation work; one ID, one dependency entry, one acceptance gate |
| **drift** | Spec-vs-code or canonical-vs-actual misalignment; tracked with stable IDs (see Drift IDs below) |
| **chronicle** | Per-session live log in `memory/sessions/` |
| **heartbeat** | Append-only cross-session event ledger in `memory/heartbeat.md` |
| **RUNBOOK** | `design/process/operational-patterns.md` — emergent operational conventions |
| **commit-request** | Handoff artifact in `handoff/notes/commit-requests/` directing an executor to land specific files with a specific message |

---

## Slice IDs

This project's slice ID prefixes — populate as the project's taxonomy solidifies. Example prefixes:

| Prefix (example) | Meaning |
|---|---|
| **F-*** | Foundation slice (Tier 0, blocking) |
| **A-*** | Anchor / surface slice (one per locked screen / module) |
| **X-*** | Cross-cutting slice (real-time, auth, telemetry) |
| **M-*** | Migration slice |

Adapt or replace per your project's taxonomy. The slice tracker in `design/canonical/implementation-plan.md` is the source of truth for the actual prefix scheme this project uses.

---

## Drift IDs

This project's drift ID prefixes — populate as drifts surface. Example prefixes:

| Prefix (example) | Meaning |
|---|---|
| **EN-*** | Entity model drift |
| **API-*** | API contract drift |
| **CO-*** | Component drift |
| **AN-*** | Anchor / screen drift |
| **RU-*** | Hard-wired rule drift |
| **SM-*** | State machine drift |

Adapt per project. Drift inventory lives at `design/canonical/code-audit.md` (or equivalent); rename to match your project's shape if different.

---

## Decisions

| Prefix | Meaning |
|---|---|
| **D-*** | Decision-of-record entries (append-only) — see `design/canonical/decisions.md` |
| **ADR-*** | Architecture Decision Record — see `design/canonical/adrs/` |

Recent locked decisions (populate as decisions land):

- _(none yet)_

---

## Project state pointers

| What | Where |
|---|---|
| Live project state | `memory/INDEX.md` |
| Per-slice build status | `memory/INDEX.md` §"Build Progress" |
| Canonical-alignment status | `design/canonical/implementation-status.md` |
| Decision log | `design/canonical/decisions.md` |
| ADRs | `design/canonical/adrs/` |
| Per-feature handoffs | `design/features/<NN-topic>/agent-handoff.md` |
| Operational RUNBOOK | `design/process/operational-patterns.md` |
| Drift class taxonomy | `design/process/drift-classes.md` |
| Escalation framework | `design/process/autonomy-gap-framework.md` |
| Agent role contracts | `design/process/agent-roles.md` |

---

## Stack

| Layer | Tech |
|---|---|
| Frontend | _(fill in)_ |
| Backend | _(fill in)_ |
| Test | _(fill in)_ |
| DB | _(fill in)_ |
| Hosting | _(fill in)_ |

---

## Repos

| Term | Meaning |
|---|---|
| **`cadence`** | This repo (the current monorepo) |

_Add predecessor / sibling repos as they become relevant._

---

*Add entries when shorthand surfaces. Promote frequent ones to top of section. When this file exceeds ~150 lines, demote rare entries to a future `memory/glossary.md`.*
