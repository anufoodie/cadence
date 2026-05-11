# Drift Classes — Taxonomy of Agentic-State Drift

**Status:** CANONICAL (process). Reference framework distilled from empirical multi-agent operation — the drift incidents that produced the source taxonomy.

**Purpose:** Name the failure modes that surface when multiple agent sessions operate in parallel against the same repository. A named class is something the team can detect, structurally fix, and post-mortem against. An un-named class lives as a recurring "weird thing that happened" until someone gets bitten by it again.

**Pairs with:**
- `autonomy-gap-framework.md` — the Tier 0–3 escalation model that uses these classes to decide when to self-resolve vs escalate.
- `operational-patterns.md` (RUNBOOK) — pattern entries that mitigate specific classes.
- `multi-session-workflow.md` — the worktree-ownership layer that closes Class 1 structurally.
- `agent-roles.md` — role-vs-session model that makes class detection durable across session turnover.

---

## §0. How to read

Each class section follows the same shape:

- **One-line definition.**
- **Symptoms** — what an agent observing this class would see.
- **Root cause** — why it happens.
- **Worked example** — anonymized empirical incident illustrating the class.
- **Detection signal** — what to grep for in heartbeat / chronicles / git state.
- **Structural mitigation** — what closes the class permanently (versus what works around an instance).
- **Class status** — `OPEN` (mitigation pending), `MITIGATED` (mitigation in place; recurrence reduced but not zero), `CLOSED-STRUCTURALLY` (mitigation makes recurrence vanishingly unlikely).

---

## §1. Class 1 — Worktree-claim drift

**One-line:** Two sessions both believe they own the same worktree or anchor; concurrent edits collide.

**Symptoms:**
- Two sessions emit `started` events for the same worktree/anchor within minutes of each other.
- One session runs Storybook on port 6014, another on 6015 in the same worktree.
- An observer notices port collision or duplicate processes and surfaces an `interrupt`.

**Root cause:** Worktree-spawn helpers (e.g., `wb-spawn`) are idempotent-by-design — running them twice with the same name silently re-enters the existing directory rather than failing. No claim-mutex on the anchor name.

**Worked example:** Two Codex sessions both ran `wb-task feature-X-walkthrough` against the same anchor; both landed in the same worktree; both ran Storybook on different ports. The Observer session noticed the port collision and emitted an interrupt.

**Detection signal:**
- `tail -n 100 memory/heartbeat.md | grep <worktree-name>` shows two `started` events from different session-ids without an intervening `closed`.
- Filesystem: two `.wb-owner` write attempts hitting the same path, with one having a different `session_id`.

**Structural mitigation:**
- `.wb-owner` canary file written by `wb-spawn` on first claim; subsequent spawns by a different `session_id` fail loudly rather than silently re-entering.
- AGENTS.md Step 0.5 pre-action heartbeat conflict check (`tail -n 100 | grep` for the worktree name) catches the case where two sessions race to spawn within seconds of each other.

**Class status:** `CLOSED-STRUCTURALLY` — `.wb-owner` + Step 0.5 close the class. Recurrence requires an agent to bypass both layers.

---

## §2. Class 2 — Operational-context drift

**One-line:** A fresh session executes the textbook approach for a task without knowing about a mid-stream operational convention established by other sessions earlier in the day.

**Symptoms:**
- Step 0.5 conflict check is clean (no `started`/`closed` collision on the worktree).
- Session proceeds with the obvious-from-AGENTS-and-brief approach.
- Later, the session re-reads earlier observer guidance and realizes its working environment doesn't match what other sessions are using.
- Often surfaces as a mismatched dependency state, port allocation, or validation approach.

**Root cause:** Step 0.5 looks for explicit conflict events (`started`/`closed` for the same anchor). Operational decisions arrive as `note` or imperative events from `target:<session-family>` routing — a different event class, not surfaced by a narrow conflict grep. AGENTS.md doesn't carry the operational convention because that's not a canonical decision; it's an emergent pattern from today's mid-stream learning.

**Worked example:** A fresh Codex pickup spawned a feature-walkthrough worktree and ran `npm ci` (the textbook approach for dependency setup). Earlier in the same session window, an Observer had standardized on a `node_modules` symlink convention for that session family. The fresh session, after a clean Step 0.5 check, didn't know about the symlink convention and ended up in mismatched dependency state.

**Detection signal:**
- `tail -n 100 memory/heartbeat.md` (not just `grep`) surfaces `note` and `milestone` events that direct operational patterns. Class 2 detection requires reading the broader tail, not just conflict-grepping.
- Heartbeat events targeting `all`, `<session-family>`, or `observer-<role>` are operational-context signals.

**Structural mitigation:**
- AGENTS.md Step 0.5 extension: scan for `note` events targeting your session-id, worktree, or scope — not just conflict events.
- `operational-patterns.md` (the RUNBOOK) — codify emergent operational patterns as a Tier 0 self-resolve reference. New sessions read the RUNBOOK before AGENTS.md is consulted for ambiguity.
- Pulse-watch behavior extension — emit periodic `recent-operational-events` digest events that summarize the last hour's `note` traffic; fresh pickups read the digest as part of bootstrap.

**Class status:** `MITIGATED` — Step 0.5 context scan + RUNBOOK reduce recurrence substantially but don't eliminate it. New operational conventions that haven't yet been codified can still surprise fresh sessions.

---

## §3. Class 3 — State-validity drift

**One-line:** An agent's mental model and shell state diverge from filesystem reality after an external state change.

**Symptoms:**
- Shell `pwd` reports a path that doesn't exist anymore (e.g., a worktree that was removed by another session).
- Commands without explicit cwd fail with `No such file or directory`.
- Session was operating from a phantom directory for hours without noticing.
- Frequently surfaces after the session has been paused and resumed across an external state-change event.

**Root cause:** A Unix shell holds cwd as an inode reference. When a worktree is removed, the inode is freed but the shell can still report the old path. There's no notification from worktree-removal to sessions that previously `cd`'d into that worktree.

**Worked example:** A Codex Build session was operating from a feature-walkthrough worktree that had been removed several hours earlier by another session. The shell held the stale inode reference; `pwd` reported the path but any filesystem op would fail. The session was running from a phantom directory for hours before someone noticed.

**Detection signal:**
- Any filesystem op (`ls`, `git status`, etc.) failing with "No such file or directory" while `pwd` reports a valid-looking path.
- `ls -ld <worktree-path>` from `/` reports the path is gone.
- Heartbeat shows a `closed` or worktree-removal event for the path your session is operating in.

**Structural mitigation:**
- `operational-patterns.md` §2 — codified stale-cwd recovery procedure (cd to main → pwd → branch → status → tail heartbeat → emit `resumed` event).
- Session bootstrap should verify `pwd` matches expected worktree path before doing any work (per `multi-session-workflow.md` §"Per-session bootstrap").

**Class status:** `MITIGATED` — recovery is documented and known. Prevention (auto-notifying sessions when their worktree disappears) requires session-wrapper-level changes beyond the current stack.

---

## §4. Class 4 — Runtime-resource drift

**One-line:** Multiple sessions race for shared runtime resources (ports, file locks, network sockets) on the same machine.

**Symptoms:**
- Multiple processes attempting to bind the same port (Storybook on 6006, UI on 3000, API on 8005).
- One session's long-lived reviewer surface conflicts with another session's short-lived validation server.
- An observer detects two listeners on the same port and emits an `interrupt`.

**Root cause:** Default ports are well-known and identical across worktrees. There's no allocation discipline at worktree-spawn time. Active sessions binding default ports during validation gates collide with the reviewer's long-lived surface or another session's validation cycle.

**Worked example:** An Observer session detected that the main Storybook surface was running on port 6006 while another task-worktree listener was also bound to 6006. The collision propagated through validation cycles for multiple anchors before being resolved.

**Detection signal:**
- `lsof -i :<port>` shows multiple PIDs bound.
- Heartbeat `interrupt` events referencing port collisions.
- Validation gates timing out or returning unexpected URLs.

**Structural mitigation:**
- `operational-patterns.md` Entry 13 — port-allocation convention: main worktree owns canonical ports (6006, 3000, 8005); task worktrees use distinct ranges (6010-6099, 3010-3099, 8010-8099) with `lsof` pre-check; heartbeat-note port assignments for peer awareness; never stop a process you didn't start unless heartbeat authorizes.
- Future: allocate ports at worktree spawn time via `wb-spawn`; record assignments in `.wb-owner` canary.

**Class status:** `MITIGATED` — convention in place; allocation-at-spawn-time follow-up deferred.

---

## §5. Class 5 — RUNBOOK-vs-canonical-contradiction drift

**One-line:** An emergent operational pattern in RUNBOOK contradicts a canonical decision or AGENTS.md rule, and an agent following the RUNBOOK ships work that violates the canonical rule.

**Symptoms:**
- A `D-*` decision says "use approach X for entity-naming"; the RUNBOOK says "approach Y is the operational default."
- An executor follows RUNBOOK and lands a commit that violates the `D-*` entry.
- Memory steward flags a `MISSING_DECISION` or `STATUS_MISMATCH` drift item but the underlying cause is the RUNBOOK/canonical contradiction, not a missing entry.

**Root cause:** RUNBOOK is "how the team currently works" (append-mostly, soft conventions). Canonical decisions are "binding spec content." Both evolve, and the team can append a RUNBOOK entry that subtly contradicts an older `D-*` entry without flagging the conflict.

**Worked example:** Theoretical, not yet observed empirically — but the structure is plausible: as RUNBOOK accumulates entries over months, an old `D-*` entry's directive may quietly disagree with a new RUNBOOK pattern. Without explicit cross-reference checks, the contradiction can ship.

**Detection signal:**
- Consistency-check (`consistency-checks.md` §3) should grep canonical decisions and RUNBOOK for keyword overlap on the same concern.
- Memory steward could be extended to scan for cross-doc contradictions, but this requires semantic parsing beyond what the current steward does.

**Structural mitigation:**
- `conventions.md` §10 — "Disagreement between process and canonical: process loses. Canonical is binding." Make this rule explicit so agents resolve contradictions in canonical's favor.
- RUNBOOK entry promotion path: when a RUNBOOK pattern proves universally binding, migrate it to AGENTS.md as a decision; if it contradicts an existing decision, supersede the decision via the append-only convention.
- Pre-merge consistency check should explicitly include cross-doc contradiction scanning before any commit touching `canonical/` or `process/`.

**Class status:** `OPEN` — no automated detection yet. Mitigation is convention + reviewer discipline.

---

## §6. Detection grep cheatsheet

For each class, the first-pass detection grep you can run against `memory/heartbeat.md`:

```bash
# Class 1 — Worktree-claim drift
tail -n 100 memory/heartbeat.md | grep <worktree-or-anchor-name> | grep started

# Class 2 — Operational-context drift
tail -n 100 memory/heartbeat.md | grep -E "(\| note \||target:<session-family>)"

# Class 3 — State-validity drift
ls -ld <worktree-path> 2>&1 | grep "No such"

# Class 4 — Runtime-resource drift
lsof -i :6006 -i :3000 -i :8005

# Class 5 — RUNBOOK-vs-canonical-contradiction
# No automated detection; manual cross-doc review during consistency checks.
```

---

## §7. Why a taxonomy

Naming makes detection enforceable. Once a class has a name:

1. **Agents can be trained to grep for it.** "Check for Class 2 drift before starting" is a concrete instruction; "make sure operational context is current" is hand-wavy.
2. **Post-mortems can attribute incidents.** "This incident was Class 4 drift, mitigated by RUNBOOK Entry 13" is a closed loop; "this incident was something about ports" stays open.
3. **Structural mitigations get scoped.** A mitigation that closes Class 1 doesn't automatically close Class 2 — the taxonomy forces explicit reasoning about which classes a fix actually addresses.
4. **New classes get a slot.** When a novel drift class surfaces (as Class 5 did, theoretically, after Classes 1-4 were named), it gets a §, a worked example, and a structural-mitigation track instead of being absorbed back into "we'll figure it out next time."

The team should expect new classes to surface over time as the system runs. The class status field (`OPEN` / `MITIGATED` / `CLOSED-STRUCTURALLY`) tracks where each class sits in the closure loop.

---

## §8. See also

- `autonomy-gap-framework.md` — Tier 0–3 escalation model that uses these classes.
- `operational-patterns.md` — RUNBOOK pattern entries (each entry typically mitigates one or more classes).
- `multi-session-workflow.md` — worktree-ownership canary (Class 1 mitigation).
- `agent-roles.md` — role-vs-session distinction (durability of detection across session turnover).
- `../canonical/decisions.md` — append-only decision log; some `D-*` entries codify class-mitigation rules.
