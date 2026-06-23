# Autonomy Goal Runner

**Status:** CANONICAL (process). Deterministic projection of goal state.

**Owner pattern:** Async Architect or equivalent runtime-infra role.

**Scope** — deterministic goal tracking, child slice (CR) sequencing, and closeout-evidence aggregation. Pairs with `work-units.md` (the hierarchy this projects) and the resident autonomy loop / lane resolver (the consumers of this projection).

---

## §1. Purpose

The goal runner lets the orchestrator express a larger approved body of work as one **bounded goal** while the existing deterministic runtime still routes one safe child slice at a time. The goal runner is **not** a free-form LLM operator. It is a manifest, a state projection, and a dependency/acceptance contract layered over the existing approval / route-ACK / QA / HITL / GPG-signing gates.

If your project does not run a resident autonomy loop, you can still use goal manifests as bookkeeping; the runner's `goal_next_actions` projection is what becomes operational only when an autonomy loop consumes it.

## §2. Manifest location

Live goal manifests live under:

```
handoff/notes/goals/*.md
```

Files whose names start with `_` are templates or examples and are ignored by the loop.

## §3. Goal frontmatter

Required:

```yaml
goal_id: <stable-slug>
title: <human-readable name>
status: active | acceptance_pending | closed | closed_with_warnings | blocked | waiting_for_children
objective: <one-line operational intent>
no_push: true
allowed_child_roles:
  - <role-key>
allowed_surfaces:
  - <surface-key>
child_crs:
  - handoff/notes/commit-requests/<...>.md
child_routes:
  - <route-id>
acceptance_criteria:
  - id: <stable-id>
    text: <what must be true>
final_acceptance_required: true
```

Recommended:

```yaml
source_plan: <handoff-note-path>           # the doc that motivated this goal
owner: <orchestrator-or-role>              # who owns the goal
hitl_owner: <user-or-orchestrator>         # who provides final acceptance call
landing_policy: <how children land>        # e.g. observer_host_side_signed_no_push
```

If your project uses Wave structure (see `work-units.md` §3), add a `waves:` block:

```yaml
waves:
  - wave_id: <stable-slug>
    title: <human-readable>
    phase_ids:
      - <phase-slug>
    depends_on:
      - <upstream-wave-id>
    status: pending | in_progress | closed
```

## §4. Child slice contract

Each executable child is a normal commit-request slice (see `cr-authoring-contract.md`). It must pass CR-lint and the normal route gates. Goal membership does not weaken child safety.

Slices in a goal carry these additional fields:

```yaml
goal_id: <parent-goal-id>
wave_id: <parent-wave-id>           # optional
phase_id: <phase-within-wave-label> # optional
dependency_order: <integer>          # ordering hint within wave
depends_on:
  - <route-id-or-CR-path>            # upstream dependencies
route_id: <stable-token>             # recommended for stable depends_on resolution
```

`route_id` is recommended for goal children because it gives downstream `depends_on` fields a stable token before the route is sent. If `route_id` is omitted, downstream children should depend on the child CR path and closeout must include that CR path in heartbeat evidence.

## §5. Dependency semantics

The route gate treats a child CR dependency as satisfied when **either**:

1. The child CR frontmatter explicitly has `dependencies_satisfied: true`, or
2. Every token in `depends_on:` appears in a CLOSED heartbeat line.

`STARTED`, `ROUTE_SENT`, `ACKED`, `BLOCKED`, and `VALIDATION_FAILED` do **not** satisfy a dependency. This is deliberate: a goal chain advances only after terminal closeout evidence exists.

## §6. Goal states

The autonomy loop projects `goal_details` in `run-once --json` and `status --json`. States:

| State | When |
|---|---|
| `in_progress` | At least one child is routeable, routed, started, pending, or present. |
| `blocked` | At least one child is blocked / validation-failed / missing; OR the goal lacks `no_push: true`. |
| `acceptance_pending` | All children closed; final goal acceptance evidence not yet linked. |
| `waiting_for_children` | Goal has no `child_crs` / `child_routes`. |
| `closed` | Manifest explicitly marked closed and no child-warning state visible. |
| `closed_with_warnings` | Manifest closed but at least one child still projects blocked / validation-failed / missing / outside-scan-truth. |

**Closing rule.** Children closing is not enough to close the goal. A goal closes only after final-acceptance proof is linked AND the orchestrator updates the manifest (or emits equivalent terminal evidence). `closed_with_warnings` does **not** automatically reopen the goal, but it must appear as goal attention until the orchestrator attaches satisfying evidence, parks the stale child explicitly, or updates the manifest.

## §7. Acceptance evidence IDs

Acceptance criteria should use stable `id` values. Child route closeouts, QA verdicts, walk packets, and land closeouts should cite `goal_id`, `phase_id`, and the relevant criterion id when practical. This keeps the runner from relying on fuzzy prose matching and lets the orchestrator see which acceptance proof is still missing.

Example heartbeat closeout:

```
<ts> | <session-id> | closed | <slice closing> | goal_id:e2e-simulation phase_id:E2a criterion:e2e.validation.linked evidence:<path-or-sha>
```

## §8. Goal next actions

The runtime exposes `goal_next_actions` in `run-once --json` and `status --json`. This is a deterministic next-step hint, **not** a product-decision engine. It may point to:

- A blocked child (needs orchestrator).
- A closed-with-warning contradiction.
- A routeable child (autonomy loop can take it).
- A final-acceptance gap.

It must still honor CR lint, HITL approval, route ACK, QA, signing, and NO PUSH gates.

## §9. Role-targeted message ingress

Approved role-targeted heartbeat notes can be admitted as runtime work when they include exactly one runtime target, an approval token (e.g. `approval:<user-direct>`), and `no_push: true` / `NO PUSH`. This bridge exists for sandbox-to-CLI handoff messages. It is intentionally process-scoped by default and does **not** grant broad product-build authority; product paths still need orchestrator / user approval.

## §10. Authority boundary

The goal runner:

- **CAN** project deterministic state from the manifest + heartbeat + queue.
- **CAN** surface `goal_next_actions` for the autonomy loop to consume.
- **CAN** flag missing acceptance evidence and closed-with-warnings contradictions.
- **CANNOT** create goals, decide priority, approve children, or close goals on its own.
- **CANNOT** treat any LLM recommendation as approval.

The orchestrator + user retain authority over goal authoring, approval, prioritization, and closeout.

## §11. See also

- `work-units.md` — the Goal/Wave/Slice hierarchy this runner projects.
- `cr-authoring-contract.md` — the slice (child CR) frontmatter contract.
- `resident-autonomy.md` — the autonomy loop that consumes `goal_next_actions`.
- `runtime-route.md` — how routed children get delivered to executors.
- `agent-roles.md` — the role contracts that author / approve / claim goals and slices.
