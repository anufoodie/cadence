# Autonomy Gap Framework

**Status:** CANONICAL (process). Distilled from empirical learning during multi-agent operation.

**Purpose:** Give agents an explicit escalation model so coordination questions self-resolve at the cheapest tier instead of defaulting to `blocked` events that wake the orchestrator or the user.

**Pairs with:**
- `drift-classes.md` — the taxonomy of drift classes this framework escalates against.
- `operational-patterns.md` — RUNBOOK; Tier 0 reads this first.
- `../../memory/HEARTBEAT_SPEC.md` — heartbeat ledger; Tiers 1-3 use heartbeat events.
- `agent-roles.md` — role contracts; defines who handles each tier when escalation does happen.

---

## §0. The autonomy gap, named

When a multi-agent system runs in production, there's an irreducible gap between:

1. **What an agent can self-resolve** given the standing context it has (AGENTS.md, RUNBOOK, brief, chronicle).
2. **What requires the orchestrator's judgment** (real architectural questions, scope changes, novel cases).

The gap is where coordination friction lives. Every escalation that's actually Tier 0 (answerable from standing context) burns orchestrator cycles and slows the system. Every Tier 3 question that an agent self-resolved by guessing produces silent drift.

The framework's job is to push as many questions as possible toward the cheapest correct tier. The autonomy gap doesn't shrink because agents become smarter — it shrinks because **the standing-context surface that agents are required to consult before acting expands.**

---

## §1. The tiers

```
Tier 0 — Self-resolve from AGENTS.md + operational-patterns.md (RUNBOOK)
         Operational ambiguity. Read the standing reference. Proceed.

Tier 1 — Self-resolve via heartbeat-tail discipline
         Coordination questions about THIS session's work.
         Tail last 100 events; if signal is clear, act on it.

Tier 2 — Heartbeat-`note` to peer sessions (not block)
         Coordination questions with a sensible default + peer ack.
         Emit `note` with the question + default action + brief delay;
         if no contradicting event arrives in N minutes, proceed.

Tier 3 — Heartbeat-`blocked` to orchestrator / architect / user
         Real architectural questions, D-* decisions, scope expansions,
         or anything that affects canonical content.
```

The friction in `blocked` events is intentional. They should be expensive enough that sessions try harder to self-resolve first.

---

## §2. Tier 0 — Self-resolve from standing references

**Contract:** Read `AGENTS.md` (the binding contract) and `operational-patterns.md` (the RUNBOOK). If the answer is there, proceed.

**Examples of Tier 0 questions:**
- Which port range should validation servers use? → RUNBOOK Entry 13.
- What's the recovery procedure for stale cwd? → RUNBOOK Entry 2.
- How do I append a heartbeat event? → RUNBOOK Entry 5.
- What's the validation gate order? → RUNBOOK Entry 9.
- Can I push directly to main? → AGENTS.md Forbidden Actions §1 (no).

**Anti-pattern:** Skipping the RUNBOOK read and asking the orchestrator. The orchestrator's answer will be "consult the RUNBOOK." Faster to read it first.

**When Tier 0 fails:** The RUNBOOK doesn't have an entry for your situation. Escalate to Tier 1.

---

## §3. Tier 1 — Heartbeat-tail discipline

**Contract:** Tail the last 100 heartbeat events. Scan for `note`, `started`, `closed`, and `blocked` events relevant to your worktree, anchor, or session-family. If the signal is clear, act on it.

```bash
tail -n 100 $WB_REPO/memory/heartbeat.md | grep -E "(<worktree-name>|<anchor-id>|<session-id>|<session-family>)"
```

**Examples of Tier 1 questions:**
- Has anyone else started working on the same anchor? → Conflict-detection (Class 1 drift).
- Is there a recent operational note that affects how I should set up validation? → Context-detection (Class 2 drift).
- Are there active blockers on similar work I should account for?
- Has the port I want to bind already been allocated by another session?

**When Tier 1 fails:** No clear signal in the heartbeat tail; you have a default action but want peer acknowledgment before acting. Escalate to Tier 2.

---

## §4. Tier 2 — Heartbeat-`note` with default action

**Contract:** Emit a `note` event with the question + your default action + a brief delay. If no contradicting event lands in N minutes (typically 5-15), proceed with the default.

**Format:**

```text
TIMESTAMP | <session-id> | note | QUESTION: <one-line>. Default: <action>. Window: <N>min. Cancel by emitting note/blocked targeting <session-id> | chronicle:<chronicle> target:<peer-session-or-all>
```

**Examples of Tier 2 questions:**
- "QUESTION: validation environment for new task family — symlink vs npm-ci? Default: symlink per RUNBOOK §1. Window: 10min."
- "QUESTION: <task-N> merge-back conflict path — integrate the project's default integration branch first or wait for orchestrator routing? Default: integrate first per RUNBOOK §6 merge-back sequence. Window: 5min."

**When Tier 2 fails:** The question is genuinely architectural — affects canonical content, scope, or D-* decisions. Escalate to Tier 3.

---

## §5. Tier 3 — Heartbeat-`blocked` to orchestrator / architect

**Contract:** Emit a `blocked` event addressed to the appropriate role — `target:design-opus` (architect), `target:cowork-<session>` (orchestrator), or `target:<user>` (decision-maker) — with full context.

**Examples of Tier 3 questions:**
- Real D-* decisions (entity model changes, rule additions, persona-naming, etc.).
- Canonical-doc amendments beyond what the original brief authorized.
- Scope expansions beyond the brief.
- Multi-decision ambiguity that no single tier-lower resolution can clear.

**Format:**

```text
TIMESTAMP | <session-id> | blocked | <one-line question>. Context: <one-line>. Need: <decision request> | chronicle:<chronicle> target:<routing>
```

The receiving role responds via `note` event with routing or directly via the user.

---

## §6. Triage rule for "should I emit `blocked`?"

Before emitting a `blocked` event, ask:

1. **Is this answered in AGENTS.md or RUNBOOK?** If yes → Tier 0; consult and proceed.
2. **Is this answered in the last 100 heartbeat events?** If yes → Tier 1; act on the signal.
3. **Do I have a sensible default I'd execute with peer acknowledgment?** If yes → Tier 2; emit `note` with default + window.
4. **Is this genuinely architectural?** If yes → Tier 3; emit `blocked`.

**Empirical incidents mapped to tiers (from the framework's autonomy-gap analysis):**

| Incident | Should have been | Actually was | Why |
|---|---|---|---|
| Dependency-setup ambiguity (Class 2 drift) | Tier 0 (RUNBOOK Entry 1) | Tier 3 escalation | RUNBOOK didn't exist yet — Tier 0 had no answer to find |
| Stale-cwd recovery (Class 3 drift) | Tier 0 (RUNBOOK Entry 2) | Tier 3 escalation (architect noticed and routed) | Recovery procedure wasn't codified |
| Duplicate-worktree (Class 1 drift) | Tier 1 (heartbeat-tail catches it) | Tier 2-ish (sessions yielded after observer flag) | Step 0.5 + `.wb-owner` now makes it Tier 1 reliably |

---

## §7. What raises the floor over time

Three mechanisms, ordered by leverage:

### §7a. `operational-patterns.md` (highest leverage)

The RUNBOOK is the load-bearing Tier 0 reference. Every operational pattern added to it shifts a future incident from Tier 3 to Tier 0. Estimated empirical impact: ~50% reduction in escalation rate based on the operational incidents that didn't have Tier 0 answers to find.

**Discipline:** when a session resolves an operational ambiguity via orchestrator escalation, the closing action should be a RUNBOOK PR. Otherwise the same question will reach Tier 3 next time.

### §7b. Pulse-watch behavior extension

A long-running observer role that emits periodic `recent-operational-events` digest events summarizing the last hour's `note` traffic. Fresh sessions read the most recent digest as part of Step 0 bootstrap. Catches Class 2 (operational-context) drift without requiring every session to grep through 100 heartbeat lines.

(This is a role-level contract — see `agent-roles.md` "Observer / Pulse-Watch".)

### §7c. Heartbeat-tail discipline added to AGENTS.md

Required: every fresh pickup tails last 100 events; not just for conflict-grep but for any `note` or `blocked` event targeting their session-id or the worktree/anchor they're claiming. Pairs with the RUNBOOK — if there's a recent `note` directing operational pattern X, follow it; if there's nothing, fall back to RUNBOOK default.

This is AGENTS.md Step 0.5, extended to scan `note` events not just conflict events.

---

## §8. What this framework does NOT do

- **Does not solve the notification-primitive problem.** Agents don't have a wake-on-event mechanism. Sessions still operate on the synchronous request/response model. The framework extends WHEN-THINKING capability; idle-session-wakeup remains a manual-relay problem.
- **Does not subsume the orchestrator's role.** Real architectural questions still go to Tier 3. The orchestrator's function is judgment for novel cases not in RUNBOOK.
- **Does not create a "rules engine."** Patterns evolve; capturing them as soft conventions in RUNBOOK keeps the surface mutable. Hardcoding decisions invites stale-text drift.
- **Does not eliminate the autonomy gap.** New classes of drift will produce new Tier 3 questions; the framework's job is to make sure each new class has its Tier 0 codification within hours-not-weeks of first surfacing.

---

## §9. Measurement

The framework's effectiveness is measurable via heartbeat ledger metrics:

- **`blocked` event count per active-sprint window** — baseline before RUNBOOK adoption vs after.
- **Time from first `blocked` event to RUNBOOK PR landing** — measures the closure loop.
- **Class 2 drift incident frequency** — measures whether Step 0.5 context scan + pulse-watch digest are catching emergent operational decisions.

Target signal: each new drift class observed should produce a RUNBOOK entry and an associated AGENTS.md / process-doc change within ~24 hours, after which recurrence-of-same-class incidents drop sharply.

---

## §10. Closing observation

The framework is the latest iteration of an ongoing learning surface, not a final destination. The autonomy gap will keep producing new classes as the system runs; the question is whether the closure loop stays tight enough that each new class becomes a Tier 0 codification before the same incident happens twice.

The discipline that keeps the loop tight:

1. Every escalation that should have been Tier 0 closes with a RUNBOOK PR (not just an answer).
2. Every new drift class names itself in `drift-classes.md` with structural mitigation.
3. Every novel coordination pattern gets evaluated for RUNBOOK promotion within the next sprint.

---

## §10.5. Wake checks after dormancy (applies when you run an autonomous loop)

The autonomy stack is a **deterministic control plane with LLM-assisted advisory packets**, not a fully-autonomous resident operator: a single route-writer and deterministic approval/admission gates retain execution authority; advisory tooling only proposes. This shape only applies if your project runs a resident autonomy loop — small projects without that surface can skip this section.

After any dormancy event — sleep, reboot, network/VPN outage, auth disruption, or unexplained idle — the first active session runs a **wake check**:

1. Re-read lane / heartbeat state via the project's lane-digest tool (`<lane-digest-tool>`).
2. Reconcile resolver-truth against the route-writer's loop-state — what does the deterministic surface say is active, blocked, claimable; what does the loop think it's doing?
3. Restore routing / accounting via the project's loop-repair tool (`<loop-repair-tool>`) rather than stale-disposing live routeable work. A common failure mode after dormancy is "the loop thinks nothing's there because it polled while the network was down" — wake checks distinguish that from "actually nothing to do."

Local heartbeat / resolver tooling survives a network outage; reasoning, remote Git, browser, and package work do not — sessions running the wake check must distinguish "can't compute" from "nothing to do" before disposing of work.

The wake check is part of what raises the autonomy floor: without it, the system reflexively treats post-dormancy idle as steady-state, losing the live work that the loop missed during the gap.

---

## §11. See also

- `drift-classes.md` — taxonomy of drift classes this framework escalates against.
- `operational-patterns.md` — RUNBOOK (the Tier 0 reference).
- `../../memory/HEARTBEAT_SPEC.md` — heartbeat ledger format.
- `agent-roles.md` — role contracts; defines who fields Tier 3 questions.
- `../canonical/decisions.md` — append-only decision log; Tier 3 escalations land here as D-* entries.
