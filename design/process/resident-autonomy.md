# Resident Autonomy Loop

**Status:** CANONICAL (process). Always-on deterministic control plane for autonomous building.

**Pairs with:**

- `runtime-binding.md` — the role bindings the loop routes to.
- `runtime-route.md` — the route-delivery contract.
- `reconciled-truth.md` — the admission-gate state read.
- `autonomy-goal-runner.md` — the goal-shape state the loop honors.
- `cr-authoring-contract.md` — the slice shape the loop routes.
- `agent-roles.md` — Resident Autonomy Agent role contract.

**When to use this.** When you want autonomous building — work flowing from approved-CR to executor without a human (or chat agent) needing to manually route each item. Smaller projects can run without this.

---

## §1. The frame

The autonomy stack is a **deterministic control plane with LLM-assisted advisory packets** — not a fully-autonomous resident LLM operator. The distinction is load-bearing:

- **Control plane is deterministic.** A single route-writer + deterministic approval/admission gates own execution authority. The loop has rules; it doesn't have judgment.
- **LLM tooling is advisory.** Operator Brain (or equivalent) recommends; the loop honors recommendations only when they meet deterministic gates. No LLM call ever counts as approval.

This frame keeps the system safe to leave running. A deterministic loop with bounded authority can't decide to ship the wrong thing — it can only route what's already been approved.

## §2. The loop

```
every <interval_sec>:
  1. read reconciled-truth snapshot
  2. read autonomy-loop state file (own state from prior ticks)
  3. select one eligible item (or zero — IDLE is fine)
  4. apply admission gate
  5. emit route via runtime-route contract
  6. update state file with outcome
```

Default interval: 60 seconds. Default emission cap: **one route per tick** (intentional governor on throughput so a misconfiguration can't avalanche).

## §3. The admission gate

A slice is eligible to route when **all** of these are true:

```
eligible = approved
         + unblocked
         + dependencies satisfied
         + target role healthy
         + no path overlap with active routes
         + within wave-dependency order (if goal-shaped)
         + path-scope-only changes (no surprise reach)
         + NO PUSH gate intact
```

The gate is binary — any false condition skips the item. The loop never bargains a partial admission.

## §4. Retire / discard rules

When the loop encounters an item that looks routeable but shouldn't be, it retires/discards per these rules:

```
retire = closed/merged/superseded/absorbed with concrete evidence
      OR explicitly parked with reason
otherwise: park for orchestrator (NOT autonomous retire)
```

The loop never silently discards work. If a CR looks stale or contradicted but has no terminal evidence, it surfaces as `owner_needed` for the orchestrator. Silent loss is the worst failure mode for an autonomous system.

## §5. State file

The loop persists state to:

```
~/.cache/<project-slug>/operator-runtime/state/autonomy-loop.json
```

Suggested shape:

```json
{
  "last_tick_at": "<ISO-timestamp>",
  "last_route_emitted_at": "<ISO-timestamp>",
  "last_route_id": "<route-id>",
  "last_outcome": "ROUTED | IDLE | BLOCKED | ROUTE_FAILED",
  "tick_count": <integer>,
  "duplicate_suppression": {
    "<cr-path>": "<ts-of-last-emission>"
  },
  "backoff_until": "<ISO-timestamp>",
  "classifications": {
    "<event-kind>": "<count>"
  }
}
```

The loop reads its own state every tick to honor duplicate suppression, backoff, and pending recovery actions.

## §6. Event classification

The loop classifies events it observes into named categories so observer / orchestrator watchers can react without a resident LLM daemon:

- `route_ack_miss` — route delivered but no CANARY-ACK in window.
- `executor_closed` — a routed item closed; downstream dependencies may now be eligible.
- `blocked_signature_change` — a blocked item's reason changed; orchestrator may need to revisit.
- `clock_drift` — observed timestamps disagree with system clock by > threshold.
- `stale_active` — a `started` event without a `closed` after staleness window.
- `queue_delta` — newly-approved CRs since last tick.
- `goal_acceptance_pending` — goal children all closed, evidence missing.
- `audit_findings_triage` — audit/QA findings need orchestrator triage.

Classifications go in the state file under `classifications:` so watchers can poll for changes.

## §7. What the loop is allowed to wake

The loop has narrow waking authority — it can summon advisory roles when deterministic conditions are met, but it cannot trigger product/build work directly without orchestrator approval:

| Wake | Condition | Effect |
|---|---|---|
| Operator Brain | `audit_findings_triage` + nonzero findings | Reconcile artifact / flow plan / policy |
| UX Patch Author | After authorized triage | Author follow-up CRs (NOT direct build) |
| Observer | Route ACK miss OR clock drift | Synthesis pass on the runtime health |
| Build executors | Always gated on `approved_for_spawn` + CR-lint + clean path scope | Route the slice |

A raw audit finding is **not** approval to route. Operator Brain must reconcile the artifact, flow plan, and orchestrator/user policy first.

## §8. Cold-boot order

When the runtime boots, the autonomy loop:

1. Waits for all persistent coordination roles (see `runtime-binding.md`) to emit startup pulses.
2. Reads its own state file (recovers in-flight context from prior session).
3. Runs a **wake check** per `autonomy-gap-framework.md` §10.5 — reconcile resolver-truth against own state, restore routing rather than dispose live work.
4. Emits a `STARTUP-PULSE` to heartbeat.
5. Starts tick cycle.

Cold-boot wake check is mandatory; without it, the loop will treat dormancy-interrupted state as steady-state and lose live work.

## §9. Authority boundary

The loop:

- **CAN** route already-approved slices that pass the admission gate.
- **CAN** mark roles unhealthy on delivery failure.
- **CAN** classify events for observer/orchestrator review.
- **CAN** wake advisory roles per §7 conditions.
- **CANNOT** approve work, decide priority, change CR status, or close goals.
- **CANNOT** treat any LLM recommendation as approval.
- **CANNOT** push, force-push, rewrite history, delete user work, or bypass GPG/signing.
- **CANNOT** retire work without concrete terminal evidence.

The loop is a deterministic enabler. All judgment lives elsewhere.

## §10. Disabling the loop

The loop must be disable-able at cold boot via an env var (suggested: `<PROJECT>_AUTONOMY_LOOP=0`). When disabled:

- No tick cycle starts.
- The runtime stays bound (roles persist) but no automated routing happens.
- Manual routing still works via the orchestrator / coordinator.

A disabled loop is the right posture during major reconfiguration, debugging, or whenever the orchestrator wants every route to be manually inspected.

## §11. Observability

The loop should expose:

- Tick count + last tick time.
- Routes emitted per hour / day.
- IDLE vs ROUTED vs BLOCKED tick distribution.
- ACK-miss rate by role.
- Pending classifications awaiting orchestrator attention.

Surface these for orchestrator review. A loop trending toward IDLE-most-of-the-time may be healthy (low queue) or unhealthy (admission gate too strict / dependencies stuck) — visibility is what distinguishes.

## §12. Live queue rule (one-liner)

```
routeable = approved + unblocked + dependencies-satisfied + role-healthy + no-path-overlap
```

If a project needs to extend the rule (additional gate condition), the extension goes in the project's reconciled-truth tool, not in the loop. The loop reads truth; it doesn't define it.

## §13. See also

- `runtime-binding.md` — the role bindings the loop addresses.
- `runtime-route.md` — the route-delivery contract used to dispatch.
- `reconciled-truth.md` — the admission-gate state read.
- `autonomy-goal-runner.md` — how goals project through the loop.
- `autonomy-gap-framework.md` §10.5 — wake checks after dormancy.
- `agent-roles.md` — Resident Autonomy Agent role contract.
- `cr-authoring-contract.md` — slice shape the loop routes.
