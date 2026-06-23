# Runtime Binding Contract

**Status:** CANONICAL (process). Tmux-backed role-to-runtime binding pattern.

**Scope** — role registry and runtime state shape only. Detailed role authority remains in `agent-roles.md`. This doc covers the *binding* layer that makes role contracts physically addressable from coordination tooling.

**When to use this.** When your project has multiple standing roles that need to be reliably routed to from automation (autonomy loop, lane resolver, scheduled tasks). Single-developer or small-team projects can skip this whole pattern — direct chat/CLI invocation is enough.

---

## §1. The runtime

Cadence's reference runtime binding is **tmux-backed**. Each role has one persistent tmux session, one display name, one short badge identifier (useful for iTerm/Terminal tabs), one tab color, one default cwd, one launch command, one log path, and one state path.

Runtime state files are JSON documents under:

```
~/.cache/<project-slug>/operator-runtime/state/
```

Logs live under:

```
~/.cache/<project-slug>/operator-runtime/logs/
```

The state JSON shape is project-specific; the binding contract only requires that *some* deterministic state document exists per role so coordination tooling can query "is this role healthy / claimed / idle?".

## §2. Role registry

A runtime role registry (per project) defines the exact set of bound roles:

| Role key | Tmux session | Badge | Tab color | Kind | Persistent |
|---|---|---|---|---|---|
| `<role-key>` | `<project>-<role>` | `<short>` | `<color>` | `<kind>` | true/false |

**Kinds** (suggested taxonomy):

- `operator` — orchestration roles (Strategic Orchestrator, Operator Brain).
- `coordination` — the mechanical orchestration roles (Coordinator, Observer, Async Architect).
- `analysis` — read-only / advisory roles (QA-Agent, UX-Analyst, Design Cartographer).
- `authoring` — CR-writing roles (UX Patch Author).
- `executor` — work-doing roles (Build-UX, Build-Backend, Build-Infra).

**Persistence semantics:**

- **Persistent** roles stay running between work items; the autonomy loop routes to them by their tmux session name.
- **Non-persistent** roles spawn per-task and exit on closeout.

A project's role registry lives at `<project>/design/process/operator-runtime.json` (the canonical machine-readable registry) plus the human prose in `operator-runtime.md` (in core Cadence: this file).

## §3. Role-launch contract

Each persistent role's launch command:

1. Sets `WB_SESSION_ID` (or the project's session-id env var) to a deterministic value.
2. Sources the project's runtime env (paths, defaults).
3. Invokes the CLI / chat agent with full permissions appropriate to the role kind.
4. Reads `AGENTS.md` §0 before any work.
5. Emits a startup pulse to heartbeat (see `operational-patterns.md` §11 / §14).

Reference flow:

```bash
tmux new-session -d -s <project>-<role> \
  "cd <project-root> && WB_SESSION_ID=<role-runtime-id> <launch-command>"
```

## §4. Cold-boot sequence

A clean cold boot of the runtime:

1. Read `operator-runtime.json` for the role-set.
2. For each persistent role:
   a. Check if tmux session exists; if not, launch per §3.
   b. Wait for startup pulse confirmation in heartbeat.
   c. Mark role healthy in state JSON.
3. Start the resident autonomy loop (if `resident_autonomy` feature is enabled) after all coordination roles are healthy.

A cold-boot failure on any one role does **not** prevent the others from coming up; the loop honors `role_healthy: false` and skips routing to unhealthy roles.

## §5. State contract

Per-role state JSON shape (suggested minimum):

```json
{
  "role_key": "<role>",
  "tmux_session": "<project>-<role>",
  "started_at": "<ISO-timestamp>",
  "last_startup_pulse_at": "<ISO-timestamp>",
  "last_heartbeat_event_at": "<ISO-timestamp>",
  "claimed_route_id": null,
  "claimed_worktree": null,
  "health": "healthy | unhealthy | stale | unknown"
}
```

Authorities:

- **Healthy** — startup pulse received, heartbeat activity within freshness threshold.
- **Stale** — no heartbeat activity within freshness threshold (default 5 min) and no `claimed_route_id`.
- **Unhealthy** — startup pulse never received, OR tmux session missing.

The autonomy loop reads this state to decide routing eligibility.

## §6. Authority boundary

Runtime binding:

- **CAN** launch / restart / health-check role sessions.
- **CAN** report role state to the autonomy loop and the lane resolver.
- **CANNOT** change role authority (that's `agent-roles.md`).
- **CANNOT** approve work, decide priority, or grant authority a role doesn't have.

Authority lives in the role contract; binding just makes the role addressable.

## §7. Runtime parallelism

Multiple instances of the same role kind can be bound when work is path-orthogonal and the role's authority allows multiple lanes (e.g. `build-ux`, `build-ux-2`, `build-ux-3`). The autonomy loop must:

1. Only route a new work item to an idle parallel role when its path scope is non-overlapping with any active sibling lane.
2. Honor the same role authority for all parallel instances (no looser permissions for "extra" lanes).
3. Treat parallel lanes as substitutable from the routing perspective.

Path-overlap protection lives in the lane resolver; binding only knows "is this lane busy."

## §8. Visibility

The runtime should make role state visible at a glance:

- **Tmux session list** (`tmux ls`) — what's bound.
- **Status feed** (project-specific dashboard or `cadence status`-style tool) — what's healthy / claimed / stale.
- **Heartbeat** — recent activity per role.

The `runtime-route.md` contract defines how routes flow through the runtime; this doc just covers binding.

## §9. See also

- `agent-roles.md` — the role authority contracts that this binding makes physical.
- `runtime-route.md` — route delivery into bound runtime sessions.
- `resident-autonomy.md` — the loop that reads runtime state to decide routing.
- `reconciled-truth.md` — the canonical state read the runtime exposes.
- `operational-patterns.md` §11, §14 — startup pulse + pulse-check contract.
