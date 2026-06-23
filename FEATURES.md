# FEATURES.md — Cadence feature catalog

Cadence is a **pluggable engine**: every subsystem can be activated or deactivated
per project. This file is the catalog. The live on/off state lives in
[`cadence.config.yml`](cadence.config.yml); the tooling that reads it is
[`scripts-infra/cadence.sh`](scripts-infra/cadence.sh).

```bash
./scripts-infra/cadence.sh status              # what's on/off right now
./scripts-infra/cadence.sh disable observer_loop --apply
./scripts-infra/cadence.sh enable  worktrees
./scripts-infra/cadence.sh init --apply        # onboard: prune disabled features
./scripts-infra/cadence.sh doctor              # find config↔filesystem drift
```

Destructive actions are **dry-run by default**; pass `--apply` to execute.

---

## How activation works

- **CORE** features are the minimum viable engine. The tool refuses to disable them
  (removing them would break the contract every agent reads on spawn).
- **OPTIONAL** features layer on coordination scale. Disabling one flips its flag in
  `cadence.config.yml` and prunes the files it owns.
- Some toggles are **doc/config-level** (no files to prune) — they change behavior
  via an instruction edit or a git-config setting, noted below.
- To re-activate a feature whose files were pruned, restore those paths from the
  Cadence starter, then `enable` it. `doctor` reports any mismatch.

A minimal single-developer instance can run with just the CORE four plus
`gpg_signing`, and skip everything else.

---

## Catalog

### CORE (cannot be disabled)

| Feature | What it is | Owns |
|---|---|---|
| `operating_contract` | `AGENTS.md` binding rules + `CLAUDE.md` redirect every agent reads on spawn | `AGENTS.md`, `CLAUDE.md` |
| `memory_index` | `memory/INDEX.md` rolling source of truth + `quick-reference.md` hot cache | `memory/INDEX.md`, `memory/quick-reference.md`, `memory/README.md`, `memory/WORKING_DEFAULTS.md` |
| `design_corpus` | Canonical foundation, feature deep-dives, and process docs | `design/canonical/`, `design/features/`, `design/process/`, `design/references/`, `design/archive/` |
| `handoff_notes` | Session-to-session continuity notes + commit-requests | `handoff/notes/` |

### OPTIONAL (toggle per project)

| Feature | What it is | Owns / effect | Default |
|---|---|---|---|
| `heartbeat` | Append-only cross-session heartbeat ledger for parallel-session awareness | `memory/heartbeat.md`, `memory/HEARTBEAT_SPEC.md` | on |
| `session_chronicles` | Per-session chronicle files reconstructing the project timeline | `memory/sessions/` | on |
| `worktrees` | Git worktree isolation toolkit (`wb-spawn`/`wb-task`/`wb-remove` + `.wb-owner` canary) | `design/process/scripts/wb-session.sh`, `design/process/multi-session-workflow.md` | on |
| `roles_full` | Full 6-role model (Orchestrator / Sync+Async Architect / Executor / Observer / Memory Steward). **Doc-level** — off means run the minimal Orchestrator/Executor/Steward subset; edit `design/process/agent-roles.md` to drop the unused contracts. | (no prune) | on |
| `memory_steward` | Scheduled daily memory reconciliation task | `design/process/scheduled-tasks/`, `memory/MEMORY_STEWARD_LAST_RUN.md` | on |
| `drift_taxonomy` | 5-class agentic-state drift taxonomy + drift reports | `design/process/drift-classes.md`, `memory/drift-reports/` | on |
| `autonomy_framework` | Tier 0–3 self-resolve-vs-escalate escalation framework | `design/process/autonomy-gap-framework.md` | on |
| `observer_loop` | Autonomous "away-but-alive" observer loop + CLI-bootable session spawner | `scripts-infra/spawn-agent.sh`, `memory/last-shutdown-snapshot.md` | off |
| `sync_engine` | Cross-repo sync — pull framework changes from a source repo into this instance, emitting dated sync reports | `sync-reports/`, `.cadence-sync-last-run.md` | off |
| `gpg_signing` | Require GPG-signed commits. **Config-level** — on sets `git config commit.gpgsign true`. | (git config) | on |

### EXTENDED (advanced autonomy + work-unit subsystems)

These features layered on as Cadence's source-instance (a real multi-agent product) shipped them. They're **off by default** because they only pay rent for projects running multi-role autonomy at scale. A small single-developer project can ignore the whole extended set.

| Feature | What it is | Owns / effect | Default |
|---|---|---|---|
| `work_units` | Goal → Wave → Slice work-unit hierarchy that the autonomous build framework dispatches against | `design/process/work-units.md` | off |
| `goal_runner` | Deterministic projection of goal state from a manifest — state machine for `acceptance_pending` / `closed_with_warnings` / `in_progress` etc. | `design/process/autonomy-goal-runner.md` | off |
| `cr_authoring_contract` | Commit-request shape contract (frontmatter schema + lint discipline + walk-readiness gate) | `design/process/cr-authoring-contract.md` | off |
| `runtime_binding` | Tmux-backed role-to-runtime binding contract; role registry + persistent role kinds + state JSON | `design/process/runtime-binding.md` | off |
| `runtime_route` | Route-delivery contract with canary ACK pattern — moves approved CRs from queue to bound executor sessions | `design/process/runtime-route.md` | off |
| `reconciled_truth` | Single deterministic state-read surface that every consumer reads from (instead of stitching live from raw inputs) | `design/process/reconciled-truth.md` | off |
| `resident_autonomy` | Always-on deterministic control plane — autonomous routing of approved slices to executors. Distinct from `observer_loop` (which is an LLM session). | `design/process/resident-autonomy.md` | off |
| `visual_qa_catalog` | Canonical-catalog visual-QA architecture — Storybook-baseline + composition manifest + deterministic-first validation cascade | `design/process/visual-qa-catalog.md` | off |
| `layered_overture` | Reference-instance layer at `examples/overture/` (worked obfuscated example) + `LAYERED.md` | `LAYERED.md`, `examples/overture/` | off |

---

## Dependencies & notes

- `session_chronicles` and `heartbeat` are independent but complementary — the
  chronicle is the per-session narrative; the heartbeat is the shared ledger.
  Running multiple parallel sessions without `heartbeat` loses collision detection
  (see `design/process/drift-classes.md` Class 1).
- `worktrees` is what makes parallel sessions physically isolated. Disabling it
  implies a single-worktree, mostly-sequential workflow.
- `observer_loop` assumes `heartbeat` is on (the loop reads the ledger). Enabling
  the loop with heartbeat off is reported by `doctor`-adjacent guidance, not enforced.
- `sync_engine` is the mechanism that produced the `sync-reports/` in this repo's
  history; for a fresh fork it ships **off** and its operational outputs are
  gitignored (see `.gitignore`) so they never pollute a downstream project.

When you finalize a feature set, run `./scripts-infra/cadence.sh doctor` and commit
both `cadence.config.yml` and the pruned tree together.
