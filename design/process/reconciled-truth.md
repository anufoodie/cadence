# Reconciled-Truth Surface

**Status:** CANONICAL (process). Single deterministic state read for operator-facing state.

**Pairs with:**

- `runtime-binding.md` — runtime state contribution.
- `resident-autonomy.md` — primary consumer.
- `agent-roles.md` — Coordinator + Observer roles consume.

---

## §1. The pattern

Operator-facing state ("what is active, what is blocked, what is next, what's awaiting human-in-the-loop, what's safe to execute") must be read from a **single deterministic reconciliation**, not stitched live from raw heartbeat + raw worktree list + raw commit-request metadata + raw role state by every consumer.

Each consumer that does its own reconciliation produces a slightly different picture. The orchestrator, the autonomy loop, the dashboard, the observer pulse-check, and a freshly-spawned session each compute state independently — and disagree. The reconciled-truth surface is the fix: one tool, one read, every consumer agrees.

## §2. Surface shape

A reconciled-truth surface is a CLI / script that:

1. Reads all inputs (heartbeat tail, worktree list, CR metadata, role state, optional autonomy-loop state, optional goal manifests).
2. Applies deterministic reconciliation rules (no LLM judgment, no human prose interpretation).
3. Emits a single snapshot with stable structure.

Reference invocations:

```bash
<reconciled-truth-tool> --snapshot          # full reconciled state
<reconciled-truth-tool> --print             # human-readable summary
<reconciled-truth-tool> --dashboard-feed    # JSON for downstream tooling
<reconciled-truth-tool> --owner-needed      # only items needing orchestrator attention
```

Each call should produce identical output given identical inputs. No timestamps in the output that aren't from the inputs; no randomness; no LLM calls.

## §3. Reconciliation rules

The deterministic rules a reconciled-truth tool applies (project-adapted as needed):

| Input combination | Reconciled state |
|---|---|
| CR `status: approved_for_spawn` + no recent `started` event + role healthy + no path overlap | `claimable` |
| CR `status: approved_for_spawn` + recent `started` event from any session | `active` (claimed) |
| CR `status: approved_for_spawn` + recent `blocked` event citing this CR/route | `blocked` |
| CR with closed worktree + no recent terminal CLOSE event | `cleanup_pending` |
| Goal manifest `child_crs` all CLOSED + no acceptance evidence linked | `acceptance_pending` |
| Heartbeat `started` event with no matching `closed` after staleness window | `stale_active` |
| Worktree present + branch ahead of base + no recent commit | `dirty_uncommitted` |
| CR file present + status `proposed_for_so_review` | `awaiting_orchestrator` |
| CR file present + status `approved_for_spawn` but target role not in runtime registry | `routeable_to_nothing` |

The rules above are illustrative — your project may need additional rules for product-specific states. The discipline is **deterministic**: rules turn inputs into outputs without judgment.

## §4. Snapshot structure

A reconciled-truth snapshot exposes these surfaces (suggested):

```json
{
  "generated_at": "<ISO-timestamp>",
  "active": [
    {"cr_path": "...", "route_id": "...", "role": "...", "started_at": "..."}
  ],
  "claimable": [
    {"cr_path": "...", "scope": "...", "target_role": "..."}
  ],
  "blocked": [
    {"cr_path": "...", "reason": "...", "owner_needed": "..."}
  ],
  "stale": [
    {"item": "...", "stale_since": "...", "reason": "..."}
  ],
  "awaiting_orchestrator": [
    {"cr_path": "...", "submitted_at": "..."}
  ],
  "acceptance_pending": [
    {"goal_id": "...", "criteria_missing": [...]}
  ],
  "warnings": [
    {"item": "...", "warning": "..."}
  ]
}
```

Total counts in each bucket are the headline numbers consumers care about — surface them in `--print` output.

## §5. Who's authoritative

The reconciled-truth surface is **authoritative** for "what is the current state" — every consumer must read from it rather than re-deriving:

- The autonomy loop reads it to decide what to route next.
- The orchestrator reads it for status summaries.
- The observer reads it for pulse-check synthesis.
- The lane resolver reads it before route admission.
- Dashboards / status feeds read it to display state.

The surface is **not authoritative** for:

- Approval (orchestrator authority).
- Priority (orchestrator + user authority).
- Route emission (autonomy loop + lane resolver authority).
- Closeout evidence (executor + CR authority).

Reconciled truth tells you *what is*; it never tells you *what should be next*. The latter requires judgment that lives in agents' role contracts.

## §6. Cache discipline

The surface may cache its snapshot for performance:

- Cache invalidates on any new heartbeat event (file mtime change).
- Cache invalidates on any CR file change.
- Cache TTL default 30 sec for "what is active" queries.

A consumer that needs guaranteed-fresh truth bypasses cache via `--no-cache` (or equivalent).

## §7. Failure modes

| Failure | Detection | Recovery |
|---|---|---|
| Heartbeat unreachable | File doesn't exist / can't read | Emit warning, fall back to git log + CR scan |
| CR metadata unparseable | YAML frontmatter error | Skip the CR, emit warning in `warnings:` |
| Stale autonomy-loop state file | mtime > 5 min and no recent heartbeat ping | Mark loop unhealthy, continue with non-loop sources |
| Reconciliation rule contradiction | Same item resolves to multiple states | Emit `contradiction:` warning, prefer most conservative state |

The surface fails *loudly* — silent reconciliation errors are worse than emitting partial state with warnings, because consumers will trust silent output.

## §8. See also

- `resident-autonomy.md` — the primary consumer; uses reconciled-truth as its admission gate.
- `runtime-binding.md` — runtime state contributes to reconciliation.
- `agent-roles.md` — Coordinator + Observer consume the surface.
- `autonomy-goal-runner.md` — goal state projects through reconciled-truth.
- `operational-patterns.md` §14 — pulse-check contract reads from this surface.
