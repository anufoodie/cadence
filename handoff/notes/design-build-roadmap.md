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

**Where we are right now:** (initial state — populate when first work begins)

---

## Sequenced path

(Populate as work queues up. Format below is suggested — adapt per project.)

```
- [ ] <work-id> — <one-line description>           status: pending     owner: <role>
- [ ] <work-id> — <one-line description>           status: armed       owner: <role>
- [ ] <work-id> — <one-line description>           status: in_progress owner: <role>
- [x] <work-id> — <one-line description>           status: landed      sha: <short-sha>
```

---

## Recently landed (last 5)

(Newest first; older landings roll off into chronicles + git log.)

---

## Notes

- This file is project-scope, not session-scope. All active sessions read and update it.
- Don't track sub-tasks here — those live in the relevant CR or chronicle.
- If the sequence changes (rework, scope shift, prioritization), update the order here in the same turn.
