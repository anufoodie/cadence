# Runtime Route Contract

**Status:** CANONICAL (process). Route-delivery contract with canary ACK.

**Pairs with:**

- `runtime-binding.md` — how role sessions become physically addressable.
- `resident-autonomy.md` — the loop that emits routes.
- `cr-authoring-contract.md` — the slice shape being routed.

**When to use this.** When your project has automated route delivery (autonomy loop, lane resolver) into bound runtime sessions. Manual / chat-driven routing doesn't need this contract.

---

## §1. The route lifecycle

```
ROUTE_PREPARED   → loop has identified an eligible slice + target role
       │
       v
ROUTE_SENT       → kickoff prompt delivered to target session
       │
       v
CANARY_ACK       → target session responded with route-id ACK
       │
       v
STARTED          → target session emitted `started` heartbeat
       │
       v
... work ...
       │
       v
CLOSED           → terminal state with evidence
```

Each transition is a heartbeat event with a stable `route_id` that all subsequent events reference. The `route_id` is the join key for downstream `depends_on` resolution.

## §2. The route_id

A stable token authored when the route is prepared:

```
route-<purpose>-<UTC-timestamp>-<role-key>-<short-hash>
```

Example: `route-autonomy-20260614T133133-build-infra-fd181e17`

The `<purpose>` segment identifies the route-emitter:

- `autonomy` — resident autonomy loop
- `coordinator` — manual coordinator session
- `reset` — runtime reset / spawn cycle
- `role-bootstrap` — initial role launch

Once authored, the `route_id` never changes through that route's lifetime. CLOSED heartbeat lines must include it so downstream dependencies can resolve.

## §3. Canary ACK pattern

The problem the canary solves: a route prompt can be delivered to a tmux session that isn't actually ready to consume it (just spawned, mid-shutdown, garbage-collecting an old prompt). Without confirmation, the emitter doesn't know whether the route landed.

**Canary contract:**

1. The emitter checks `prompt_ready` before delivery (the target session's prompt-line indicates ready state).
2. Emitter delivers the route prompt via `tmux send-keys` (or equivalent).
3. Emitter waits for the target session to emit a CANARY-ACK heartbeat line referencing the exact `route_id`.
4. ACK timeout default: 120 seconds. Configurable per route purpose.
5. If ACK arrives in window → ROUTE_ACKED, await STARTED.
6. If ACK times out → ROUTE_ACK_MISSED, the emitter may retry once or escalate.

Reference heartbeat shape:

```
<ts> | <emitter> | note | ROUTE_SENT route_id:<id> target:<role> tmux_session:<session> ack_timeout:120s readiness:prompt-ready | event:ROUTE_SENT
<ts> | <target-canary> | note | CANARY-ACK - <role>; route_id:<id>; STARTUP-PULSE; <state>; NO PUSH | route_id:<id> canary:true role:<role> startup:true
<ts> | <emitter> | note | ROUTE-ACKED - <role>; route_id:<id>; via:<canary-session-id>; NO PUSH | event:ROUTE_ACKED route_id:<id> target:<role>
```

## §4. Readiness check

`prompt_ready` is determined per-runtime. Reference implementations:

- **Tmux:** capture the last N lines of the pane; check whether the last non-empty line ends with the shell prompt character (`$`, `%`, `›`, etc.) and the cursor is at the start of an empty line.
- **iTerm/Terminal:** ANSI cursor position query + prompt-string detection.
- **Custom CLI runners:** project-specific signal (a state file, an API call).

If readiness can't be reliably determined, default to a short pre-delivery wait (3-5 sec) and accept some ACK timeouts as the cost of ambiguity.

## §5. Delivery failure modes

| Mode | Detection | Recovery |
|---|---|---|
| `prompt_not_ready` | Readiness check fails before delivery | Emit `ROUTE_DELIVERY_BLOCKED`, retry after backoff |
| `tmux_session_missing` | Session not found at delivery time | Mark target unhealthy; route to fallback role or hold |
| `ack_timeout` | No CANARY-ACK in window | One retry then `ROUTE_ACK_MISSED`; escalate to orchestrator |
| `wrong_role_acked` | ACK references different role | Reject ACK; treat as ack_timeout |

The autonomy loop respects each failure mode by classifying it explicitly in its state file so the orchestrator/observer can react without a resident LLM daemon.

## §6. Authority boundary

Route delivery:

- **CAN** prepare, send, retry, and close routes.
- **CAN** mark target roles unhealthy on delivery failure.
- **CANNOT** decide whether work is eligible (lane resolver decides admission).
- **CANNOT** approve, modify, or close the underlying CR/slice (that's executor + orchestrator authority).

A route is the delivery vehicle; the work itself lives in the CR + the executor session.

## §7. Spawn delivery hardening

For initial role bootstrap (cold boot, role respawn), route delivery has extra requirements:

- **Pre-respawn ACK** required for each persistent role before resuming routing.
- **All-or-nothing pattern:** if N persistent roles are being respawned, route resumes only after all N have ACKed (or after explicit escalation if any fails).
- **Canary suppression:** the role-bootstrap canary is not treated as a real work CANARY-ACK by downstream loops; it's a runtime-health signal only.

A cold-boot or runtime-reset cycle emits:

```
<ts> | <runtime-routing-session> | note | RUNTIME-RESET-TEST - dropping and respawning all persistent tmux roles | roles:all-persistent
... (per-role ROUTE_SENT + CANARY-ACK events) ...
<ts> | <runtime-routing-session> | closed | CLOSED - spawn delivery hardening validated after full persistent-role respawn | canary:<N>of<N>
```

## §8. Observability

A route-delivery system should expose:

- Route count per role per time window.
- ACK-miss rate per role.
- Average delivery latency.
- Most recent route per role with state.

Surface these in a dashboard or via a CLI status command for orchestrator/observer review. ACK-miss rate trending up is a runtime-health signal that should trigger investigation before more routes are emitted.

## §9. See also

- `runtime-binding.md` — the role registry routes target.
- `resident-autonomy.md` — the loop that emits autonomy-purpose routes.
- `cr-authoring-contract.md` — the slice carried by each route.
- `autonomy-goal-runner.md` — how routes flow through goal-shaped work.
- `operational-patterns.md` §11, §14 — startup pulse + pulse-check.
