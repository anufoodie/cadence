# TODO tracker — unordered parking lot

> **Living planning doc — read and UPDATE every working turn.** Half of the compaction-survival layer (paired with `design-build-roadmap.md`). Per `AGENTS.md` §"Also every session — two living planning docs."

## How to use this doc

This file holds the **unordered** backlog — anything not to lose that isn't already on the sequenced critical path. Sequenced work lives in `design-build-roadmap.md`, not here.

Park here when you defer a decision, identify an external dependency, notice polish you can't address now, or surface an open question whose answer doesn't gate current work. Anything that would otherwise die in a chat thread.

- Append freely; this file grows.
- Once an item gets sequenced (work has been queued for it), move it to the roadmap and delete the line here.
- Don't curate aggressively. Stale items are still better than lost ones.

## Categories (suggested — adapt per project)

### Open decisions

- [ ] PR `anu-singh` → `main` for the layered wave — waiting on Anu / when ready to integrate.

  _(Resolved 2026-06-23: the 2 HOST-COMMIT-RECIPE files were retired/deleted per Anu's authorization once their commits landed+pushed.)_

### External dependencies

(Things that block work but live outside the repo. Format: `[ ] <dependency> — affects <work>`.)

### Deferred work

- [ ] Contract worker implementations (cr-lint, reconciled-truth, runtime-route, autonomy loop) — deferred because they live in downstream projects per the layered discipline; revisit per-project.
- [ ] Full obfuscated overture corpus (more anchor patterns, components, Operator Brain) — deferred because wave-2 shipped representative samples; revisit in an overture-refresh wave.
- [ ] `cadence.sh check-overture-leaks` CI gate (OBFUSCATION_POLICY Rule 9) — deferred; revisit when overture corpus grows.
- [ ] Sync-engine SKILL.md update to track new top-level artifacts (`LAYERED.md`, `examples/`) — deferred; revisit next sync cycle.

### Polish / cleanup

(Cowork chronicle `cw-2026-06-22-...` committed 2026-06-23 during worktree-hygiene pass.)

### Questions to bring up

(Surfacing-list for the next user check-in.)

### Drift to surface

(Suspicions of drift that haven't crystallized into a formal drift report.)

---

## Notes

- This file is project-scope, not session-scope. All active sessions read and update it.
- If an item turns into a CR or chronicle, link it from the line here before removing.
- Don't use this as a chronicle replacement. Per-session timeline goes in `memory/sessions/<session>.md`.
