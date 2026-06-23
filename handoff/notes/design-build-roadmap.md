# Design-build roadmap — sequenced critical path

> **Living planning doc — read and UPDATE every working turn.** This is half the compaction-survival layer (paired with `TODO-tracker.md`). A fresh or post-compaction session must be able to recover *what's ahead and where we are* from this file without re-deriving from chat. Per `AGENTS.md` §"Also every session — two living planning docs."

## How to use this doc

This file holds the **sequenced** critical path — what comes next, in order, and where the current marker is. Unordered backlog and parking-lot items go in `TODO-tracker.md`, not here.

- Update a work item's status line the SAME turn its state changes (spawned / bounced / landed / blocked).
- Don't rewrite history — when an item lands, mark it landed; don't delete it.
- Keep entries terse. A line per item is fine; a paragraph per item is too much.
- The current-marker line at the top tells incoming sessions where the live edge is.

## Status keys

- `pending` — queued, not started
- `armed` — commit-request / handoff exists, waiting on claim
- `in_progress` — actively being executed
- `blocked` — paused, waiting on external (note what)
- `landed` — committed locally (NO PUSH default)
- `pushed` — committed and pushed (rare, requires explicit user confirmation)
- `bounced` — work returned with rework needed

---

## Current marker

**Where we are right now:** Layered-extraction wave (2026-06-22) is **landed + pushed** to `anu-singh` as of 2026-06-23. Cadence is at the pluggable-engine + layered-architecture shape. No active build slice in flight. Next integration step is a PR to `main` when the maintainer is ready.

---

## Sequenced path

```
- [ ] pr-to-main        — open PR anu-singh → main for the layered wave     status: pending   owner: Anu Singh
- [ ] retire-recipes    — decide retire/keep for the 2 HOST-COMMIT-RECIPE-* status: pending   owner: Anu Singh
- [ ] skill-md-refresh  — add LAYERED.md + examples/ to sync-engine SKILL.md status: pending   owner: Orchestrator
- [ ] overture-leak-ci  — cadence.sh check-overture-leaks gate (OBFP Rule 9) status: pending   owner: Executor
```

(Contract worker implementations — cr-lint / reconciled-truth / runtime-route / autonomy loop — live in downstream projects, not this repo. See TODO-tracker "Deferred work".)

---

## Recently landed (last 5)

(Newest first; older landings roll off into chronicles + git log.)

- [x] layered-wave — 8 signed commits, layered-extraction wave   status: pushed   sha: 73d2c21..61e2a6c  (2026-06-23)

---

## Notes

- This file is project-scope, not session-scope. All active sessions read and update it.
- Don't track sub-tasks here — those live in the relevant CR or chronicle.
- If the sequence changes (rework, scope shift, prioritization), update the order here in the same turn.
