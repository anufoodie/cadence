# memory/

Project-state memory shared across human + agents (Codex, Claude Code, Cowork, other CLI shells). The `memory/` directory is the **rolling source of truth** for project context — what's shipped, what's queued, who decided what, what shorthand means.

Distinct from `design/canonical/` (binding spec content) — `design/canonical/` is *what we're building*; `memory/` is *where we are right now*.

---

## Architecture

```
memory/
├── INDEX.md                       ← master checkpoint: project state, build progress queue,
│                                    decisions log summary, architecture facts, personas
├── quick-reference.md             ← hot-cache decoder: people, terms, slice IDs, shorthand
├── WORKING_DEFAULTS.md            ← stable operating conventions for the team
├── HEARTBEAT_SPEC.md              ← cross-session awareness ledger format spec
├── heartbeat.md                   ← live event ledger (pipe-delimited; append-only)
├── MEMORY_STEWARD_LAST_RUN.md     ← checkpoint file written by the daily memory steward
├── sessions/                      ← per-session live logs (one file per chat thread / CLI task)
│   ├── cowork-YYYY-MM-DD-<topic>.md
│   ├── codex-YYYY-MM-DD-<topic>.md
│   ├── claude-code-YYYY-MM-DD-<topic>.md
│   ├── steward-YYYY-MM-DD.md
│   └── archive/<year>/            ← weekly-archived chronicles
└── drift-reports/                 ← daily drift reports from the memory steward
    └── YYYY-MM-DD-drift.md
```

## What goes in which file

| File | Contents | Update cadence | Owner |
|---|---|---|---|
| `INDEX.md` | Current state · slice/build progress · decision log summary · architecture facts · ownership model | After major events (slice ships, decision lands, restructure) | Orchestrator (e.g., Cowork) primary; executor (Codex) appends checkpoints |
| `WORKING_DEFAULTS.md` | Operating conventions: how agents resume work, memory model, agent collaboration norms | Rarely — when collaboration norms change | `Anu Singh` approves; agents propose |
| `quick-reference.md` | Hot-cache decoder — top ~30 people / acronyms / slice IDs / shorthand. Always-loaded read for shorthand decoding | Promote when something becomes frequent; demote when stale | Orchestrator primary; agents append on first encounter |
| `HEARTBEAT_SPEC.md` | Format spec for the heartbeat ledger | Rarely — convention changes only | Architect proposes; team confirms |
| `heartbeat.md` | Live append-only event ledger across all sessions | Continuously, by any session | All agents append per AGENTS.md §0 |
| `MEMORY_STEWARD_LAST_RUN.md` | Last-known-state checkpoint for the memory steward | Each steward run | Memory steward (scheduled task) |
| `sessions/<id>.md` | Per-session live log — topic timeline + dated active log + outcomes + state | Autonomously by the session itself | Owning agent (one file per session) |
| `drift-reports/YYYY-MM-DD-drift.md` | Drift report from a steward run | Per steward run | Memory steward |

## Lookup flow

When an agent needs to decode shorthand or look up project context:

```
1. quick-reference.md   ← hot cache (~30 entries each: people, terms, slices)
2. INDEX.md             ← deeper state (build progress, decisions, persona detail)
3. design/canonical/    ← binding spec content (what's being built)
4. design/features/     ← per-feature build context
5. ask the user         ← if still unknown after the above
```

The hot cache is committed to git so every agent reaches it via the same path.

## Update conventions

**When to write to which file:**

- **Slice ships** → update `INDEX.md` build progress (status flip), append checkpoint
- **Decision locks** → entry goes in `design/canonical/decisions.md` (canonical), summary in `INDEX.md` decision log
- **New person introduced** → entry in `quick-reference.md` Key People
- **New shorthand surfaces** → entry in `quick-reference.md` Terms; promote if frequent
- **Cross-session signal** → append a line to `heartbeat.md` per `HEARTBEAT_SPEC.md`

**Append-only files:** `heartbeat.md`, `INDEX.md` decision-log section. Never edit prior entries; revisions append a new entry that supersedes.

**Live-state files:** `INDEX.md` current-state + build-progress sections evolve in place.

## Per-session chronicle convention

Multiple agent sessions run in parallel against this repo. Each session maintains its **own live log** in `memory/sessions/` so the team can reconstruct project timeline across sessions if coherence breaks. **Filename is stable; topic drift is captured inside the file.**

### Filename format

```
memory/sessions/<agent-prefix>-YYYY-MM-DD-<topic-slug>.md
```

- **Agent prefix** = `cowork` (Cowork chat sessions), `codex` (Codex CLI), `claude-code` (Claude Code CLI), `steward` (scheduled memory steward), or another short stable identifier
- **Date** = when the session first became active (best estimate from conversation history)
- **Topic slug** = the *starting* topic (3-5 words, kebab-case) — even if the session drifts later, the slug stays. It's the session's identity, not its current topic.
- **Discriminator** for parallel sessions on same day with similar topics: append `-anu`, `-2`, etc.

### File structure

```markdown
# Session: <agent-prefix>-YYYY-MM-DD-<topic-slug>
**Started:** YYYY-MM-DD
**Status:** active | paused | closed
**Current topic:** <current focus, even if drifted>
**Owner agent:** <agent label>

## Topic timeline (newest first)
| Date(s) | Topic | Status |
|---|---|---|
| <date> | <current topic> | active |
| <prior dates> | <prior topic> | resolved |

## Active log
### YYYY-MM-DD (<topic>)
- HH:MM — <event / decision / file change / commit>

## Outcomes (rolling)
- Commits: <hashes>
- Decisions: <D-* entries>
- Files: <created / modified>

## State at last update
- Pending: <next steps>
- Open questions: <if any>
- Blocked on: <if any>
```

### Autonomous behavior (agents do this without explicit prompt)

- **At session start (first time):** create the chronicle file with header. Reconstruct topic timeline + active log retrospectively from conversation history.
- **At session start (continuation):** read other sessions' chronicle files (`memory/sessions/*.md`) to understand parallel context.
- **During session:** append timestamped entries to active log under the current topic's date section. Each meaningful turn = an entry.
- **On topic shift:** detect the shift (new domain entity / decision / file outside current topic) → append new row to topic timeline + new dated section to active log + update **Current topic** header.
- **At session close (or pause):** mark Status, finalize Outcomes + State at last update.

### Status field semantics

The `Status:` field reflects intent, not recency:

- **`active`** — open thread; the user / authoring agent may resume at any time. **This is the default and stays active even across long pauses (days or weeks).** Long quiet stretches are normal — sessions persist for as long as the work might continue.
- **`paused`** — explicitly paused by user or agent for a defined reason. Distinct from quiet — paused means *waiting on something specific*.
- **`closed`** — explicitly ended; either the work is done, the topic was subsumed by another session, or the session was abandoned. Only a human or the originating agent should mark a chronicle closed.

**The memory steward does NOT flag `active` chronicles as stale based on log-entry recency alone.** Multi-day or multi-week gaps in the log are expected for persistent design sessions. The steward only flags issues if a chronicle has structural problems (malformed) or if its Status contradicts observable activity (e.g., `closed` but new commits keep adding entries).

### Cross-session timeline reconstruction

```bash
ls memory/sessions/cowork-*.md memory/sessions/codex-*.md memory/sessions/claude-code-*.md 2>/dev/null | sort
# Each file is a session log; read in date order = full timeline across all sessions
```

For a single date across all sessions:
```bash
grep -A 5 "### 2026-05-03" memory/sessions/*.md
```

### Chronicle archival

The memory steward runs a weekly archival sweep (Sundays) per `design/process/scheduled-tasks/memory-steward-prompt.md` §11:

- **Per-task chronicles** (`claude-code-*.md`, `codex-*.md`): archived when mtime > 30 days AND `Status: closed` AND rolled up into any project rollup file.
- **Steward chronicles** (`steward-*.md`): archived when mtime > 7 days AND rolled up.
- **Cowork chronicles** (`cowork-*.md`): **never auto-archived.** Cowork sessions can resume anytime per `Status: active` durability — manual archival only when a Cowork session is genuinely closed.
- **Destination:** `memory/sessions/archive/<year>/<filename>.md` via `git mv` (preserves history at 100% similarity rename detection).
- **Commit:** separate signed commit (NOT bundled with other steward output), message format `chore(memory): archive N chronicles older than threshold (Status: closed)`.

---

## Staleness detection

`INDEX.md` "Last updated" header should be within ~7 days of `git log -1 --format=%cd`. If the gap is bigger, the doc is stale and an agent should:

1. Flag the staleness in their response.
2. Cross-check against `git log --oneline --since="last-updated-date"` to identify what's missing.
3. Update INDEX.md before relying on it for current-state decisions.

`quick-reference.md` doesn't go stale per se — it grows. Demote rarely-used entries to a future `memory/glossary.md` when promoting new ones.

## See also

- `../AGENTS.md` §0 — bootstrap reading order; required reading every session.
- `../design/canonical/decisions.md` — append-only decision log (binding).
- `../design/process/workflow.md` — workflow shape for incorporating new feature areas.
- `../design/process/operational-patterns.md` — emergent operational conventions (RUNBOOK).
- `../design/process/scheduled-tasks/memory-steward-prompt.md` — daily memory-steward routine.
