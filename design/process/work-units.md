# Work units — Goal → Wave → Slice

**Status:** CANONICAL (process). The hierarchy of work-unit shapes any autonomous build framework dispatches.

**Purpose** — name the three levels of work granularity that flow through Cadence's coordination machinery, define how they nest, and pin down what shape each level takes on disk so any session (orchestrator, executor, autonomous agent) can read state and route work without ambiguity.

**Pairs with:**

- `autonomy-goal-runner.md` — the deterministic projection of goal state from its manifest.
- `cr-authoring-contract.md` — the slice (commit-request) shape.
- `agent-roles.md` — who owns what authority at each level.

---

## §1. The hierarchy

```
Goal       ─── strategic outcome, manifest-shaped, multi-week
  └─ Wave  ─── phased batch within a goal, sequence-shaped, multi-day
       └─ Slice ── atomic executable unit, claim-shaped, hours
```

| Level | Time horizon | Authority to create | Lives at | Routed by |
|---|---|---|---|---|
| Goal | weeks-months | User + Strategic Orchestrator | `handoff/notes/goals/<goal-id>.md` | Goal Runner (deterministic) |
| Wave | days-weeks | Strategic Orchestrator | section inside the goal manifest, OR a separate file per wave | Goal Runner |
| Slice | hours-days | Any authoring session (gated) | `handoff/notes/commit-requests/<date>-<slug>.md` | Lane resolver → role-specific executor |

A slice without a parent wave is fine — small standalone work doesn't need the larger structure. A wave without a parent goal is fine — themed batches don't need a goal manifest just to exist. The hierarchy is opt-in upward, not forced.

The unit that gets sent to the autonomous build framework is the **slice**. Goals and waves are accumulation structures the orchestrator + autonomy loop use to track context, satisfy dependencies, and aggregate acceptance evidence; they're not themselves claimable by executors.

---

## §2. Goal

**Definition.** A strategic outcome bounded by a manifest. Has acceptance criteria. Closes only when terminal evidence is linked, not just because all child work landed.

**Manifest shape** (full contract in `autonomy-goal-runner.md`):

```yaml
goal_id: <stable-slug>
title: <human-readable name>
status: active | acceptance_pending | closed | closed_with_warnings
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

**When to create a goal.** When a body of approved work is large enough that the orchestrator wants a single bounded surface to track progress / acceptance against, separate from each child CR's individual lifecycle. Typical triggers: a customer milestone, a pre-walk integration, an architectural overhaul that spans 3+ slices.

**When NOT to create a goal.** Single-slice work. Routine maintenance. Anything that's already adequately tracked by one CR + heartbeat closeout.

**Goal closeout.** A goal closes when:

1. All `child_crs` are CLOSED with concrete evidence, OR explicitly parked with reason.
2. Each `acceptance_criteria` entry has evidence linked (heartbeat milestone with the criterion ID, OR a closeout artifact citing the ID).
3. The manifest is updated to `status: closed` by the orchestrator (or to `closed_with_warnings` if any child is in an exception state).

Children landing is necessary but not sufficient. The orchestrator owns the close call.

---

## §3. Wave

**Definition.** A phased batch of slices within a goal (or standalone). Waves give the orchestrator a way to sequence work that has internal dependency ordering or natural batch boundaries — "all of Wave 2 lands before any of Wave 3 starts."

**Shape.** A wave can live as a section in the goal manifest:

```yaml
waves:
  - wave_id: w1-foundation
    title: Foundation wave
    phase_ids:
      - foundation-a
      - foundation-b
    status: in_progress
  - wave_id: w2-integration
    title: Integration wave
    phase_ids:
      - integration-a
    depends_on:
      - w1-foundation
    status: pending
```

OR as a separate file per wave at `handoff/notes/waves/<goal-id>-<wave-id>.md` when the wave is large enough that inline-in-goal-manifest is cluttered. The separate-file shape carries the same `wave_id`, `depends_on`, `child_crs`, `status` contract.

**Wave dependency rule.** A wave's `child_crs` are claimable as soon as the wave's own `depends_on` waves are all closed. The route admission check honors wave dependency the same way it honors slice-level `depends_on`.

**When to create a wave.** When a goal has 5+ slices AND has natural batch boundaries (foundation work has to land before integration; design decisions have to lock before build can start). When a goal is just a flat list of 3-4 parallel slices, skip wave structure.

---

## §4. Slice

**Definition.** An atomic executable unit. The thing that gets routed to and claimed by an executor (build-ux, build-backend, build-infra, etc.). Always has a commit-request file.

**Shape.** See `cr-authoring-contract.md` for the full frontmatter contract. Minimum:

```yaml
title: <human-readable>
scope: <ux-patch | frontend | backend | infrastructure-autonomous | project-HITL>
status: <proposed_for_so_review | approved_for_spawn | ready_for_build | accepted_for_promotion>
target_role: <build-ux | build-backend | build-infra | ...>
change_paths:
  - <path>
no_push: true
strategic_orchestrator_approval: <pending | approved>
```

If the slice belongs to a goal:

```yaml
goal_id: <stable-slug>           # parent goal
wave_id: <stable-slug>           # parent wave (optional)
phase_id: <stable-slug>          # phase-within-wave label (optional)
dependency_order: <integer>      # ordering hint within wave
depends_on:
  - <upstream-route-id-or-CR-path>
route_id: <stable-token>         # recommended for goal children
```

**Slice closeout.** A slice closes when:

1. The build role emits a heartbeat `closed` event with concrete evidence (commit SHA, test pass, route ACK).
2. The CR status transitions through its lifecycle (`approved_for_spawn` → `ready_for_build` → `accepted_for_promotion` or equivalent terminal state).
3. The route ID is referenced in a CLOSED heartbeat line so downstream `depends_on` can resolve.

Slices that close successfully are how goal/wave acceptance criteria get satisfied. A goal can only close after every claimed slice closes terminally.

---

## §5. Dispatch into the autonomous build framework

This is the question this hierarchy was designed to answer: **what gets sent to the resident autonomy loop?**

```
              orchestrator authors / approves           
                     ▼                                   
Goal manifest ──▶ goal_runner projects state            
                     │                                   
                     ▼                                   
              Goal next-action ─── points at one of:    
                     │                                   
                     ├─▶ a routeable Slice               
                     │   (admitted to lane resolver)     
                     │                                   
                     ├─▶ a blocked child                 
                     │   (surfaces what's blocking)      
                     │                                   
                     ├─▶ a final-acceptance gap          
                     │   (surfaces missing evidence)     
                     │                                   
                     └─▶ a wave-dependency wait          
                         (this wave's upstream not done) 
                                                         
              Slice ──▶ resident_autonomy loop          
                     ▼                                   
              admission check ──▶ route_id ─▶ executor  
```

The autonomy loop NEVER claims a goal or a wave. It only ever claims slices. Goals and waves are read-only context for the loop — they tell it *which slice is eligible next* and *whether the goal needs orchestrator attention* (acceptance gap, closed-with-warnings, etc.).

The orchestrator owns:
- Goal creation, wave decomposition, acceptance-criteria authoring.
- Approval gate (a slice becomes `approved_for_spawn` only when SO marks it so).
- Closeout call when goal is done.

The autonomy loop owns:
- Routing approved slices into worktrees + executor sessions.
- Honoring dependency ordering (slice `depends_on`, wave `depends_on`).
- Surfacing terminal goal state for orchestrator review.

---

## §6. When a goal needs orchestrator attention

The goal runner projects one of these states; orchestrator action is required for the first three:

| State | What it means | Orchestrator action |
|---|---|---|
| `acceptance_pending` | All children closed; final acceptance evidence not yet linked. | Link evidence, mark `closed`. |
| `closed_with_warnings` | Manifest closed but a child still projects blocked / validation-failed / missing. | Attach satisfying evidence, park the child explicitly, or update manifest. |
| `blocked` | One or more children blocked OR goal lacks `no_push: true`. | Resolve the blocker or escalate. |
| `in_progress` | Routine — at least one child is routeable / routed / started. | None — the loop is working it. |
| `waiting_for_children` | Goal has no `child_crs` or `child_routes` yet. | Author slices for the goal. |

---

## §7. See also

- `autonomy-goal-runner.md` — the deterministic projection contract.
- `cr-authoring-contract.md` — slice frontmatter contract and routing-gate rules.
- `runtime-binding.md` — how slices end up bound to a runtime role.
- `runtime-route.md` — route-delivery contract for getting a slice from queue to executor.
- `agent-roles.md` — who has authority to create goals, approve slices, route work.
- `operational-patterns.md` §11 — heartbeat-tail-on-start (how a session sees current goal/wave/slice state).
