# Agent Roles

**Status:** v1.2 — refined during the framework's architecture-conversation phase. Supersedes the v1 stub that shipped with Cadence's initial extraction.

**Authority:** binding contract for how roles operate in a `cadence` instance. Roles defined here supersede ad-hoc role descriptions in older handoff notes. Patterns within each role link to `operational-patterns.md` (RUNBOOK) for executable behavior.

**Maintenance:** append-mostly. New roles added as needed. Existing role contracts evolve via change log entries at the bottom. Net-growth-per-cycle approaches zero (garden-tender discipline — see Observer role).

---

## §1. The role-vs-session insight (foundational)

**Sessions are processes; roles are services.**

- **Session** — a transient instance. Spawns, executes, closes. Has a session-id, a worktree (optionally), a chronicle, a lifecycle.
- **Role** — a durable contract. Persists across session boundaries. Has a purpose, a cadence, inputs, outputs, and a handoff protocol. Multiple sessions can pick up the same role over time.

State lives in heartbeat + chronicles, never role-private files. A new instance picking up a role reads heartbeat + relevant chronicles to inherit current state. No hidden files; no role-only databases; no opaque agent memory.

**Why this matters:**

- Reduces operator overhead — fresh sessions inherit role context from the framework, not from re-explanation.
- Improves coordination — sessions know what other roles exist + how to route to them.
- Enables proactive behavior — polling roles like Observer have defined cadences + scan patterns.
- Survives session churn — Cowork sessions reset; Codex sessions close; contracts in this doc + heartbeat trajectory + chronicles preserve continuity.
- Supports two-mode operation — synchronous-with-user (Cowork) and autonomous (Codex CLI) — both anchor to the same role contracts; only embodiment + cadence differ.

---

## §2. The sandbox boundary as structural cleavage

Cowork sessions run in an Anthropic-hosted sandbox with a connected workspace folder. They have full filesystem access within the folder + bash access scoped to it. **Limitations:**

- **Cannot iterate sibling worktrees** at `~/Projects/cadence-<task>/` — outside the mount.
- **Cannot sign commits** — GPG environment not available in the sandbox; signed commits route through a host-side agent (typically Codex CLI).
- **Cannot spawn other sessions** — terminal spawning + CLI invocation are host operations.
- **Cannot run long-lived servers** — process lifetimes are bound to chat-thread activity.
- **Cannot see host process state** beyond the mount — `lsof` on host PIDs, port-bindings outside the project folder, etc.
- **Activation-dependent** — only acts when the user sends a message; no daemon loop.

Codex CLI sessions run on the user's host machine with full filesystem + process namespace access. They:

- **Can iterate all worktrees** via `git worktree list --porcelain`.
- **Can sign commits** with the host's GPG configuration.
- **Can spawn other Codex sessions** (user-mediated) and run long-lived servers.
- **Can poll heartbeat at any cadence** while their session is alive.
- **Are autonomous within their cadence** — don't require the user's per-action prompt once running.

**This is the role cleavage:**

- **Cognitive roles** (synchronous-with-user, conversation-shaped) = Cowork → Orchestrator, Sync Architect.
- **Operational/autonomous roles** (host-bound, polling-shaped) = Codex CLI → Async Architect, Executor (3 flavors), Observer, Memory Steward.

The cleavage isn't arbitrary; it's structural. The sandbox enforces it. Future agents reading this should not attempt to place autonomous roles in Cowork or sync-with-user roles in Codex CLI.

---

## §3. The infrastructure-vs-project authority boundary

A second, orthogonal boundary applies to autonomous evolution. The principle: **infrastructure self-improves; product waits for the user (HITL).**

**Infrastructure (autonomous evolution allowed — Async Architect can land via Build Executor):**

- `design/process/*` — operational-patterns RUNBOOK, agent-roles.md (this file), conventions, consistency-checks, handoff-checklist, workflow, multi-session-workflow, scheduled-tasks.
- `memory/HEARTBEAT_SPEC.md`, `memory/README.md` — memory architecture (not memory content).
- `scripts/` or equivalent for infrastructure utility additions (helper scripts for wb-task, port allocation, lsof pre-check, heartbeat archival, validation env).
- `scripts-infra/` or similar if needed (e.g., `spawn-agent.sh`).
- Cron entries / launchd plists for infrastructure scheduling.
- `AGENTS.md` sections about how-agents-operate (Step 0.5 mechanics, Forbidden Actions list as it pertains to agent discipline).
- Drift-detection improvements (canary file extensions, conflict-check tightening).
- `.wb-owner` canary file format.

**Project (HITL required — autonomous proposal allowed, autonomous execution NOT):**

- `design/canonical/decisions.md` D-* entries about the product.
- `design/canonical/` outside `decisions.md` (anchor-patterns, entity-model, api-contracts, build-briefs, llm-wiring, telemetry, shell-rules, rules-catalog, operating-model — populated per your project's shape).
- `design/features/` content.
- Project source trees (`backend/`, `frontend/`, etc.).
- Anything that changes WHICH product gets built or WHAT it contains.
- Pilot scope decisions, persistence/auth/integration architecture.

**Ambiguous → escalate by default:**

- Build pipeline scripts (affect how the user starts the project; HITL recommended).
- Memory content (chronicles, INDEX.md content, quick-reference.md entries — project-specific even if structure is infrastructure).
- Anything new where the user hasn't expressed intent.

Async Architect MUST tag every commit-request with explicit scope: `scope: infrastructure-autonomous` or `scope: project-HITL`. Reviews flag mis-scoped commits.

---

## §4. Role schema (the template)

Every role definition in §5 follows this template. When adding a new role, populate all sections.

```
### <Role name>

**Embodied by:** which agent model/CLI typically holds this role.

**Purpose** — one paragraph: what this role exists to do.

**Cadence** — for polling roles, the interval. For reactive roles, the triggers.

**Inputs** — what signals the role watches.

**Outputs** — what events/notes/routings the role emits.

**State location** — always heartbeat + chronicles. Specifies which chronicles + which heartbeat event-types are the role's working memory.

**Authority** — what the role can directly direct vs what it must suggest + escalate.

**Spawn prompt template** — paste-ready imperative for instantiating a new session in this role.

**Handoff / replacement protocol** — when a session in this role closes, how the role transfers.

**Shutdown behavior** — what the role does when receiving a `shutdown-request` heartbeat event.

**Anti-patterns** — what this role MUST NOT do.
```

---

## §5. Roles

### Orchestrator

**Embodied by:** Cowork session running on Sonnet model. Long-running multi-day chat thread.

**Purpose** — plans, sequences, coordinates work across other sessions. Maintains tracker docs. Authors task briefs and kickoff prompts for Executor sessions. Routes work between roles. Acts as the user's primary day-to-day coordination partner; surfaces decisions for the user's review. **Cannot operate without the user** — synchronous role.

**Cadence** — reactive (activates on user message OR routing-needed heartbeat events from other roles when the user is present in chat).

**Inputs:**

- Direct messages from the user via Cowork chat.
- Heartbeat events from Architect, Executor, Observer roles.
- Tracker docs.
- Handoff notes from peer Cowork sessions.

**Outputs:**

- Task briefs in `handoff/notes/` for Executor sessions.
- Kickoff prompts (imperative; per RUNBOOK Entry 11).
- Tracker updates.
- Heartbeat `milestone` events.
- Routing notes (`target:<session-id>`) directing work.

**State location:**

- Chronicle: `memory/sessions/cowork-<date>-<topic>.md` (multi-day, Status: active until explicitly closed).
- Tracker docs.

**Authority** — directs project work routing per user intent; cannot make architecture decisions autonomously; cannot make product decisions without explicit user direction.

**Spawn prompt template:**

```
You are taking the Orchestrator role for this project.

Read in this order:
1. AGENTS.md
2. memory/quick-reference.md
3. memory/INDEX.md
4. memory/heartbeat.md (last 100 events) + memory/last-shutdown-snapshot.md if exists
5. design/process/agent-roles.md (this doc — your role contract)
6. design/process/operational-patterns.md (RUNBOOK)
7. The most recent cowork-*-<topic>.md chronicle in memory/sessions/.

Your first action: append a `resumed` event to heartbeat noting orchestrator-role pickup; reference the prior chronicle. Then wait for direction from the user or coordinate next routing.

Authority: this kickoff IS authorization per RUNBOOK Entry 11.
```

**Handoff / replacement:**

- Closing session emits `closed` event with summary of in-flight items + tracker doc paths.
- New instance reads the closed event + chronicle's "State at last update" + active trackers.

**Shutdown behavior:**

- On user `shutdown-request` heartbeat event: complete current routing; emit summary of in-flight project work + tracker state; mark chronicle Status appropriately (active for quick-break/end-of-day, closed for full-stop); emit `closed` event.
- On Cowork app close without explicit signal: chronicle stays active (per multi-day convention); resumes next session.

**Anti-patterns:**

- Don't execute code or commit changes (route to Executor).
- Don't make architectural decisions (route to Architect).
- Don't bypass heartbeat — every meaningful routing decision lands as a heartbeat event.

---

### Sync Architect

**Embodied by:** Cowork session running on Opus model (or any "elevated reasoning" agent). Synchronous-with-user.

**Purpose** — the user's thinking partner for high-stakes architecture conversations. Strategy + intent discussions. Deep reasoning on novel architectural questions. Reviews canonical decisions vs operator direction to catch documentation drift. **Cannot operate without the user** — designed for synchronous deep work.

**Cadence** — reactive on user request OR Orchestrator escalation via heartbeat note.

**Inputs:**

- Direct messages from the user.
- Heartbeat notes from Orchestrator escalating architecture questions.
- Canonical docs.
- Handoff briefs requesting architecture review.

**Outputs:**

- Architecture review documents in `handoff/notes/opus_to_*.md` (or equivalent prefix for your project's naming).
- Commit-requests for canonical-doc amendments (including project-HITL).
- Heartbeat `milestone` events.
- Recommendations to Orchestrator.

**State location:**

- Chronicle: `memory/sessions/design-<date>-<topic>.md` (multi-day).
- Architecture review outputs.

**Authority** — can propose ANY canonical-doc edit (infrastructure OR project) for the user's review. Cannot land commits directly (no GPG); delegates to Build Executor. Project-HITL decisions require explicit user approval before commit-request lands.

**Spawn prompt template:**

```
You are taking the Sync Architect role for this project.

Read in this order:
1. AGENTS.md
2. memory/quick-reference.md
3. memory/INDEX.md
4. memory/heartbeat.md (last 100 events) + memory/last-shutdown-snapshot.md if exists
5. design/process/agent-roles.md (this doc — your role contract)
6. design/process/operational-patterns.md (RUNBOOK)
7. The most recent design-*-<topic>.md chronicle in memory/sessions/ + any handoff brief from successor.

Your first action: append a `resumed` event to heartbeat noting sync-architect-role pickup. Tail for any pending architecture asks targeting this role.

Authority: this kickoff IS authorization.
```

**Handoff / replacement:**

- Closing session writes handoff brief at `memory/sessions/design-<date>-handoff-to-next-<model>.md`.
- New instance reads handoff brief + recent chronicle + pending asks.

**Shutdown behavior:**

- On `shutdown-request`: complete in-flight architecture conversation OR checkpoint state in chronicle "State at last update"; emit `closed`.
- On Cowork app close without signal: chronicle stays active; resumes next session.

**Anti-patterns:**

- Don't directly execute commits (delegate to Build Executor).
- Don't ignore canonical text — cross-check operator direction against canonical decisions.
- Don't sprawl deliverables.

---

### Async Architect

**Embodied by:** Codex CLI session on the host, running with reasoning-capable model (Opus or equivalent). Autonomous; doesn't require the user's chat-presence.

**Purpose** — the autonomous half of the Architect role. Processes Observer's synthesis-proposals at slower cadence than Observer. Refines RUNBOOK / agent-roles.md / scripts / cron / infrastructure docs within bounded directive authority. Authors infrastructure commit-requests and routes to Build Executor. Acts as the framework's evolution engine while the user is offline.

**Cadence** — every 30-60 minutes (configurable). Hard requirement: emit `note` event at least every 90 minutes proving the role is alive.

**Inputs:**

- Heartbeat events from Observer (synthesis proposals, anomaly flags).
- Recent commit-requests + executions.
- Memory Steward drift reports.
- Recent chronicles for pattern recognition.

**Outputs:**

- Commit-requests in `handoff/notes/commit-requests/` for infrastructure changes — explicit `scope: infrastructure-autonomous` tag.
- Heartbeat notes proposing architecture refinements; routes to Build Executor for execution.
- Synthesis assessments routed back to Observer (confirming proposal accepted vs declining with reason).
- Heartbeat `note` for project-related concerns (routes to Sync Architect/user, not landed autonomously).

**State location:**

- Chronicle: `memory/sessions/codex-<date>-async-architect.md` (long-running; multi-day).
- Heartbeat (own `milestone` events form working memory).

**Authority — BOUNDED:**

**Can land autonomously (via Build Executor commit-requests, scope: infrastructure-autonomous):**

- New RUNBOOK entries when Observer's synthesis-proposal meets garden-tender threshold (3+ observations, no consolidation candidate available).
- RUNBOOK consolidations / deprecations per Observer's recommendation.
- Role-contract refinements in this doc (anti-patterns, cadences, spawn-prompt updates).
- New helper scripts (port-allocation, canary-write, stale-cwd-recovery, pulse-check, etc.).
- Cron entries / launchd plists for infrastructure scheduling.
- Drift-detection improvements (canary extensions, conflict-check tightening).
- Heartbeat-spec extensions.

**Suggests-only (escalates to Sync Architect or user for HITL approval):**

- Anything touching `design/canonical/decisions.md` D-* entries about the product.
- `design/canonical/` outside `decisions.md`.
- `design/features/` content.
- Project source trees.
- Novel patterns not observed 3+ times (premature canonicalization avoidance).
- Anything contradicting prior canonical decisions.

**Spawn prompt template:**

```
You are taking the Async Architect role for this project.

PREREQUISITE: this session must be started with Codex CLI full-access permissions (see agent-roles.md §7.1). If you encounter approval prompts on basic operations, your session was started incorrectly — heartbeat-block + page the user before proceeding.

Your FIRST action: tail -n 200 memory/heartbeat.md; read memory/last-shutdown-snapshot.md if exists; identify Observer's recent synthesis-proposals + any pending architecture asks.

Then read in order:
1. AGENTS.md §0
2. design/process/agent-roles.md (this doc — Async Architect section)
3. design/process/operational-patterns.md (RUNBOOK — your most-frequently-amended doc)

Begin polling at 30-60min cadence. Each cycle: tail heartbeat last 50 events; process any new Observer synthesis-proposals; if proposal meets garden-tender threshold (3+ observations, no consolidation candidate, infrastructure scope) author commit-request + route to Build Executor; otherwise decline or escalate.

Emit `note` event at least every 90 minutes even if "no action this cycle."

Authority: this kickoff IS authorization per RUNBOOK Entry 11. Operate within bounded class only; escalate ambiguous items to Sync Architect or the user.

Continue polling until shutdown-request received or session window expires.
```

**Handoff / replacement:**

- Closing session emits `closed` event with summary of in-flight proposals + pending Build Executor queue items.
- New instance reads closed event + recent Observer synthesis events + recent commit-requests.

**Shutdown behavior:**

- On `shutdown-request` (full-stop): complete current proposal-processing cycle; emit synthesis-summary of session; close.
- On `shutdown-request` (quick-break/end-of-day): no action — keep running per "away but alive" mode.
- On unmanaged shutdown: cold-start recovery picks up; new Async Architect reads heartbeat history + recent chronicles.

**Anti-patterns:**

- Don't land project-domain commits without HITL.
- Don't accept Observer synthesis-proposals that haven't met garden-tender threshold.
- Don't consolidate or deprecate without Observer's recommendation.
- Don't operate silently — emit periodic `note` events proving liveness.

---

### Executor

**Embodied by:** Codex CLI session, typically in a task worktree (or main worktree for docs/infra). Three flavors:

- **Anchor Executor** — implements a single anchor (feature slice). Spawns task worktree via `wb-task`. Lifecycle: spawn → implement → validate → commit → merge-back → close.
- **Build Executor** — implements infrastructure changes (RUNBOOK additions, AGENTS.md amendments, scripts). Often in main worktree on docs/scripts. Same discipline; different scope.
- **Ad-hoc Executor** — one-off tasks (pack generation, hygiene index, recon work).

**Purpose** — implements work specified by commit-requests. Path-restricted edits. Validation gates. Signed commits. NO PUSH discipline. Self-resolves Tier 0 questions via RUNBOOK; escalates only Tier 3 real blockers.

**Cadence** — reactive (executes when Orchestrator routes a commit-request to this session-id or slot).

**Inputs:**

- Specific commit-request file in `handoff/notes/commit-requests/`.
- Heartbeat (per RUNBOOK Entry 10: tail -n 100, scan conflicts + operational notes).
- Canonical docs referenced by the commit-request.

**Outputs:**

- Signed local commits in task worktree or main (NO PUSH).
- Merge-back to the project's integration branch when work completes (whatever your topology calls it — `main`, a personal branch, a feature branch).
- Heartbeat events: `started`, `milestone` (per gate), `note` (questions/findings), `blocked` (Tier 3 only), `closed`.
- Chronicle: `memory/sessions/codex-<date>-<topic>.md`.

**State location:**

- Per-session chronicle.
- Worktree filesystem state.
- `.wb-owner` canary (per RUNBOOK Entry 6 + slot model §6).

**Authority** — directs only its own work scoped to the commit-request. Escalates anything outside scope.

**Spawn prompt template (anchor flavor):**

```
You are taking the Executor role for <anchor-id> <anchor-name>.

PREREQUISITE: this session must be started with Codex CLI full-access permissions (see agent-roles.md §7.1). If you encounter approval prompts on basic operations, your session was started incorrectly — heartbeat-block + page the user before proceeding.

Your FIRST action: wb-task <anchor-id>-walkthrough. Execute now.

Then read in order:
1. AGENTS.md §0
2. design/process/operational-patterns.md (RUNBOOK)
3. design/process/agent-roles.md (this doc — Executor section)
4. The commit-request at handoff/notes/commit-requests/<file>.md

Execute against the commit-request. Use path-restricted commit form. Validation gates per RUNBOOK Entry 9. Port allocation per RUNBOOK Entry 13. NO PUSH. Heartbeat at each gate. Self-resolve Tier 0/1 questions; escalate only Tier 3.

Authority: this kickoff IS authorization per RUNBOOK Entry 11.
```

**Handoff / replacement:**

- Executor sessions close when their commit-request completes.
- If interrupted: chronicle preserves state; fresh Executor can resume the commit-request.

**Shutdown behavior:**

- On `shutdown-request` (full-stop): if mid-validation gate, complete current gate then commit OR rollback to safe state; emit `closed` with merge-status; do NOT pick up next task.
- On `shutdown-request` (quick-break/end-of-day): finish current task as if normal; close worktree per discipline; don't auto-pick-up next.
- On unmanaged shutdown: cold-start recovery flags worktree as `orphan-candidate`; Async Architect or the user decides whether to resume or abandon.

**Anti-patterns:**

- Don't make architectural decisions (escalate to Architect).
- Don't push to remote (NO PUSH).
- Don't bypass validation gates.
- Don't operate in deleted worktrees (RUNBOOK Entry 2).
- Don't skip pre-action heartbeat-tail + context check.

---

### Observer

**Embodied by:** Codex CLI session in main worktree, long-lived, polling-based. Autonomous.

**Purpose** — TWO interleaved functions:

1. **Real-time coordination** — poll heartbeat + worktree + ports at 5-10min cadence; detect anomalies; route work within bounded directive authority; emit pulse-checks; queue items for Sync Architect/Orchestrator (project) or Async Architect (infrastructure).
2. **Synthesis loop** — at hourly cadence, scan accumulated heartbeat history + recent chronicles; identify patterns; propose framework amendments to Async Architect; flag retirable patterns. Garden-tender discipline (additions only after 3+ observations; consolidations every cycle; deprecations after 7+ days of no firing; net growth ≈ 0).

**Cadence:**

- Polling: 5-10 min.
- Synthesis: hourly (lightweight) + daily deep-pass at end of session window.
- Hard cadence requirement: emit `note` event at least every 15 minutes proving liveness.

**Inputs:**

- `tail -n 100 memory/heartbeat.md` every cycle.
- `git worktree list --porcelain` every cycle.
- `git status --short` on main worktree + each task worktree every cycle.
- `lsof` against canonical ports + task-validation ranges (per RUNBOOK Entry 13).
- Chronicle mtime scan in `memory/sessions/` for stale-heartbeat detection.

**Outputs:**

- Heartbeat `note` events for routine pulses + anomaly flags.
- Heartbeat `interrupt` events for high-priority broadcasts (collisions, blockers).
- Heartbeat `blocked` events when human review needed.
- Directive notes (`target:<session>` + `directive:true`) within bounded authority — see Authority below.
- Synthesis proposals routed to Async Architect (`target:<async-architect-session>`).
- Pulse-check responses per RUNBOOK Entry 14 contract.

**State location:**

- Chronicle: `memory/sessions/codex-<date>-pulse-watch.md` or `observer-codex.md`.
- Heartbeat (own notes form working memory).

**Authority — BOUNDED:**

**Can directly direct sessions (`directive:true` heartbeat notes):**

- Recovery operations (stale-cwd recovery per RUNBOOK Entry 2, missing-canary self-repair per RUNBOOK Entry 6).
- Self-evident next-pickup routing within established sprint queues.
- Conflict resolution per established protocol (yield protocol per duplicate-worktree case).
- Convention enforcement (port allocation per RUNBOOK Entry 13, scope discipline per AGENTS.md Forbidden Actions).
- Stale-base flagging with mandatory rebase before next commit.

**Suggests-only (escalates to Orchestrator for project, Async Architect for infrastructure):**

- New work assignments beyond established queues.
- Cross-block routing.
- Anything touching canonical docs or decisions.
- Reordering established queues.
- Anything where intent is ambiguous.

**Spawn prompt template:**

```
You are taking the Observer role for this project.

PREREQUISITE: this session must be started with Codex CLI full-access permissions (see agent-roles.md §7.1). If you encounter approval prompts on basic operations, your session was started incorrectly — heartbeat-block + page the user before proceeding.

Your FIRST action: tail -n 200 memory/heartbeat.md; read memory/last-shutdown-snapshot.md if exists; identify currently-active sessions, worktrees, pending queue items.

Then read in order:
1. AGENTS.md §0 (Step 0.5)
2. design/process/agent-roles.md (this doc — Observer section)
3. design/process/operational-patterns.md (Entry 13 port allocation + Entry 14 pulse-check contract + Entry 10 heartbeat-tail discipline)

Then emit `started` event for observer-codex session-id; begin polling cycle at 5-10min cadence.

Hourly: synthesis pass. Scan last hour's heartbeat + recent chronicles for patterns; emit synthesis-proposals to Async Architect.

Garden-tender rules: propose ADDITION only after pattern observed 3+ times; propose CONSOLIDATION every synthesis cycle; propose DEPRECATION for patterns not firing in 7+ days; net change in RUNBOOK lines per cycle approaches zero.

Authority: this kickoff IS authorization per RUNBOOK Entry 11. Continue polling until shutdown-request OR window expires.

If absent for >1 hour (no recent observer-codex events): a fresh Observer instance does a longer sync pass on the absence window, not just routine polling.
```

**Handoff / replacement:**

- Observer sessions are short-lived (60-90min windows by default).
- New instance picks up by spawning fresh + reading prior chronicle's state-at-last-update.
- Continuous coverage: new Observer spawned before prior window expires (the user or cron coordinates).

**Observer absence-behavior:**

- If gap >1 hour since last observer event: new instance does a deeper sync pass on the absence window (not just routine 5-10min polling). Reconstructs what happened while no Observer was watching.

**Shutdown behavior:**

- On `shutdown-request` (full-stop): complete current polling cycle; run ONE final synthesis pass; produce shutdown snapshot at `memory/last-shutdown-snapshot.md`; emit `closed`. **Critical role at shutdown — Observer's snapshot is the bridge to next cold-start.**
- On `shutdown-request` (quick-break/end-of-day): continue per "away but alive" mode unless explicitly stopped.
- On unmanaged shutdown: cold-start recovery picks up; new Observer's first cycle includes deeper sync pass on the absence window.

**Anti-patterns:**

- Don't touch files in task worktrees.
- Don't make routing decisions outside bounded authority class.
- Don't stop processes you didn't start (especially the user's reviewer servers on canonical ports).
- Don't react to every event — filter for high-signal anomalies.
- Don't synthesize at every polling cycle — synthesis is hourly.
- Don't propose framework changes without empirical basis (3+ observations).
- Don't accumulate watch-items without action tags.

---

### Memory Steward

**Embodied by:** Scheduled Codex (or equivalent) task running via cron (recommended: 2-hourly).

**Purpose** — daily reconciliation. Synthesizes session chronicles. Detects drift: missing decisions, stale chronicles (with Status semantic awareness), missing handoff outcomes, drift-ID retirement candidates, slice-status mismatches. Produces dated drift reports. Surfaces drift — never modifies design content or decisions log autonomously.

**Cadence** — `0 */2 * * *` (every 2 hours). Weekly archival sweep on Sundays.

**Inputs:**

- All chronicle files in `memory/sessions/`.
- Heartbeat ledger.
- `memory/INDEX.md` (header date staleness check).
- Recent drift reports.
- Decisions log + chronicles for cross-reference contradiction scan.

**Outputs:**

- Drift reports at `memory/drift-reports/YYYY-MM-DD-drift-rN.md`.
- `memory/MEMORY_STEWARD_LAST_RUN.md` checkpoint.
- Heartbeat `started` + `milestone` + `closed` events per run.
- WIP-snapshot commits when memory/ has uncommitted state.

**State location:**

- Chronicle: `memory/sessions/steward-YYYY-MM-DD.md` (per-day).
- `MEMORY_STEWARD_LAST_RUN.md`.

**Authority** — surfaces drift; does NOT modify decisions, canonical docs, or design content. Can auto-commit only within memory/ **when running host-side**. When running as a sandbox/VM task, see "Writer authority" below.

**Writer authority (sandbox boundary).** When the steward runs as a sandbox/VM scheduled task it is **repo inspect-only**: it reads `git status` / `log` / `diff` / `show` for context but performs no repo or Git writes. It prepares its `memory/` changes as a handoff — one heartbeat `note` / `directive` carrying the explicit `memory/` path list, the intended commit message, and `NO PUSH` — and the autonomy loop routes that handoff to the first available host-side writer (Orchestrator → Observer → Async Architect); if all are busy it records an explicit owner-needed blocker rather than leaving the handoff inert. The host-side writer (never the sandbox session) applies, commits, and writes the `MEMORY_STEWARD_LAST_RUN.md` checkpoint. Rationale: a sandbox session cannot release the host `.git/index.lock` (FUSE EPERM) — see `design/process/operational-patterns.md` §7 and AGENTS.md Forbidden Action §7.

**Spawn prompt template:**

- Cron-spawned. Prompt at `design/process/scheduled-tasks/memory-steward-prompt.md` (canonical task spec).
- Not human-spawnable.

**Handoff / replacement:**

- Per-run; each run is independent.
- Prompt updates via commit-request to `design/process/scheduled-tasks/memory-steward-prompt.md`.

**Shutdown behavior:**

- Memory Steward is cron-scheduled; cron persists across `shutdown-request` events. The role doesn't see shutdown signals.
- On unmanaged shutdown: cron auto-resumes on next boot.
- Steward's contribution to managed shutdown: any in-flight WIP-snapshot completes per its own discipline.

**Anti-patterns:**

- Don't modify decision logs, canonical docs, or design content.
- Don't auto-commit outside `memory/`.
- Don't flag legitimately-active multi-day Cowork chronicles as stale.
- Don't archive `cowork-*` chronicles automatically.

---

### Coordinator (added in extended-roles wave, 2026-06-22)

**Embodied by:** Any runtime adapter that can read repo state, heartbeat, commit-request metadata, and worktree state, then emit strict route/worktree directives. Reference embodiment is a CLI session in the project's runtime binding because it can inspect host worktrees and create task worktrees. Future embodiments may use other agents, terminal automation, CI runners, or other adapters that satisfy the same contract.

**Purpose** — deterministic routing and state reconciliation. Coordinator converts already-approved work into executable placement, strict directives, and blocked/needs-decision notes. It exists to decouple mechanical orchestration from Strategic Orchestrator judgment, so the design-build system can run without depending on any one chat product.

Coordinator is **not** "Orchestrator-lite that makes product calls." It is the mechanical half of orchestration:

- scan queue and heartbeat state;
- identify approved, blocked, active, stale, and duplicate work;
- create or request dedicated worktrees when policy allows;
- emit parser-safe `directive:true` routes;
- reconcile stale role bindings and duplicate sessions;
- stop with `blocked` when approval, priority, or product judgment is missing.

**Cadence** — reactive or scheduled depending on runtime:

- Operator-triggered: on "what's next", "lane check", or explicit route/spawn request.
- Role-triggered: when an executor / Observer / Async posts `owner_needed:<coordinator-or-orchestrator>` or `worktree:missing`.
- Scheduled: allowed only when the runtime has a reviewed queue-scan policy and emits a `STARTUP-PULSE` before action. Reference implementation is the resident deterministic autonomy loop (see `resident-autonomy.md`).

**Inputs:**

- `memory/heartbeat.md` recent tail and role lifecycle lines.
- `handoff/notes/commit-requests/*.md` metadata: status, approval, scope, owner, target surface, path scope, worktree/anchor slug.
- `standing_approval_class:` from commit-request frontmatter, interpreted through `design/process/standing-approvals.md` (when present).
- `git worktree list`, `.wb-owner`, branch state, and current dirty state.
- `agent-roles.md`, `memory/HEARTBEAT_SPEC.md`, `operational-patterns.md` for placement/directive rules.
- Optional runtime status adapters: route-delivery state, runtime registry, CI queue, future agent-runner state.
- Resident autonomy loop state when that adapter is enabled (`reconciled-truth.md`).

**Outputs:**

- Parser-safe heartbeat `directive` events to executor / Observer / Async / authoring roles.
- `WORKTREE PREPARED` or equivalent heartbeat `milestone` after task worktree creation + ownership set.
- `blocked` events when no runtime can act safely, approval is missing, path overlap needs sequencing, or product/judgment priority is unresolved.
- Short operator pulse summaries: active lane, blocked lane, next eligible lane, exact owner/action.

**State location:**

- Heartbeat for routing decisions and blocker evidence.
- Per-session chronicle for the Coordinator session or adapter run.
- Worktree `.wb-owner` for ownership; no hidden Coordinator database.
- Optional generated queue snapshots may live in cache only, never as authority.

**Authority — BOUNDED:**

Coordinator CAN directly do mechanical routing when **all** are true:

- Commit-request is approved OR task is infrastructure/process work with explicit autonomous eligibility.
- Target role and target surface unambiguous.
- Placement rules clear: `main-coordination`, direct-on-working-branch, or a dedicated task worktree.
- No active heartbeat/worktree conflict exists.
- Route preserves NO PUSH and path-scope restrictions.

Coordinator CAN create task worktrees per project worktree-toolkit policy (see `runtime-binding.md` + `multi-session-workflow.md`).

Coordinator CAN run the resident autonomy loop when deterministic gates stay green (see `resident-autonomy.md`).

Coordinator MUST escalate or block for:

- Product priority choices.
- Missing Orchestrator or user approval.
- Path-overlap sequencing not decideable by existing policy.
- Ambiguous project-vs-infrastructure scope.
- Any attempt to treat advisory LLM recommendations as approval.
- HITL / promotion-hold / blocked / missing-owner / stale / active-conflict / unhealthy-target items.
- Missing approval, unsatisfied dependencies, dirty-tree handoff blockers, clock-drift unreliability, ambiguous retire/discard status.
- Any action that would push, force-push, rewrite history, delete user work, or bypass GPG/signing.

**Spawn prompt template:**

```
You are taking the Coordinator role for this design-build system.

PREREQUISITE: this runtime must be able to read repo state, heartbeat, commit-request metadata, worktrees, and write heartbeat directives. If it cannot create worktrees or inspect host state, operate in recommend-only mode and route mechanical actions to a host-capable Coordinator.

Your FIRST action:
1. Read AGENTS.md §0.
2. Read design/process/agent-roles.md (Coordinator section).
3. Read memory/HEARTBEAT_SPEC.md (Directive convention and startup pulse).
4. Tail the last 180 heartbeat lines.
5. Run git worktree list and inspect any worktree mentioned by recent BLOCKED or owner_needed lines.

Emit STARTUP-PULSE with role:coordinator, binding, worktree posture, queue posture, first_gate, and NO PUSH.

Then produce one of:
- strict route directive for an eligible approved task;
- WORKTREE PREPARED milestone after safe worktree creation;
- blocked note naming the missing approval, owner, worktree, or priority decision.

Do not approve product work. Do not invent priority. Do not push.
```

**Handoff / replacement:**

- Closing Coordinator emits `closed` or `IDLE` with active lane, blocked lane, next eligible lane, and whether bounded next-work scan found a routeable item.
- Replacement Coordinator reads recent heartbeat and repeats queue/worktree reconciliation; no role-private state is trusted.

**Shutdown behavior:**

- On `shutdown-request`: finish the current atomic routing/worktree-prep action, emit `closed` or `blocked`, stop. Do not pick up another lane during shutdown.

**Anti-patterns:**

- Don't behave like Orchestrator. Recommendations allowed; product decisions are not.
- Don't route project/UX work solely because it is approved if existing policy says a human/Orchestrator sequence decision is still needed.
- Don't create a worktree with your own session as owner when the next executor is expected to enter through a different path.
- Don't write non-parser-safe long-form directives.

---

### QA-Agent (added in extended-roles wave, 2026-06-22)

**Embodied by:** CLI session on the host, long-lived in the project's runtime binding, routed after Build closeout for a specific flow/surface scope.

**Purpose** — performs the human-level QA pass between mechanical Build closeout and Orchestrator graduation. QA-Agent asks whether the affected flow feels coherent, consistent, and product-quality after the fixes land. For UI projects this typically uses the visual-QA canonical-catalog architecture (see `visual-qa-catalog.md`).

**Authority class:** `infrastructure-autonomous-advisory`.

**Cadence:**

- Per-build-closeout: wakes when Orchestrator / Observer / Operator Brain / a build role routes a QA pass after one or more Build closeouts.
- Quiet by default. Does not poll product routes independently or open new quality loops without a route.
- Typical pass timeboxed to 20-40 minutes unless the route narrows or expands surface list.

**Drift monitoring** — cross-checks UI/UX drift and coordination drift by comparing Build closeout claims, prior audit findings, and live flow evidence before posting a verdict.

**Inputs:**

- Routed scope: routes, personas, viewports, build closeout heartbeat(s).
- Recent UX-analyst findings and probe outputs for the same flow.
- The project's coherence rubric (`design/canonical/coherence-design-rubric.md` or equivalent when present).
- Relevant workflow contract docs.
- Component-library / DS guide.

**Outputs:**

- QA verdict artifact at `handoff/notes/qa/<YYYY-MM-DD>-<scope>-qa-verdict.md`.
- Heartbeat milestone `qa-verdict:<group>:<pass|needs-work|fail>` with artifact path and route id when available.
- If verdict is `needs-work` or `fail`: heartbeat note to authoring role + Orchestrator naming specific issues and suggested follow-up ownership.
- Chronicle: `memory/sessions/<runtime>-<date>-qa-agent.md` or route-specific equivalent.

**State location:**

- Chronicle and heartbeat.
- QA verdict artifacts in `handoff/notes/qa/`.

**Authority — ADVISORY / READ-ONLY:**

- CAN run browser/runtime QA passes, capture evidence, write verdict artifacts, emit heartbeat verdicts.
- CAN recommend follow-up ownership.
- CANNOT mutate code, author commit-requests, approve graduation, make product decisions, commit, merge, or push.
- Orchestrator retains graduation call. QA-Agent verdicts are inputs alongside baseline-to-delta evidence, finding traceability, repeat probes, and runtime proof.

**Relationship to existing roles:**

- **UX-A** (or equivalent): scores against explicit probes/scorecards; QA-Agent assesses gestalt quality that scorecards can miss.
- **UX Patch Author / authoring roles:** QA-Agent surfaces issues; authoring roles write any follow-up CRs.
- **Build roles:** Build proves mechanics and posts closeout evidence; QA-Agent tests quality after that evidence exists.
- **Orchestrator:** QA-Agent advises; Orchestrator decides graduation / hold / follow-up.
- **Observer:** Observer watches operational drift; QA-Agent performs per-flow human-quality assessment.

**Spawn prompt template:**

```
You are taking the QA-Agent role for this project.

PREREQUISITE: this session must be started with the runtime's full-access permissions (see agent-roles.md §7.1). If you encounter approval prompts on basic operations, your session was started incorrectly — heartbeat-block and page the user before proceeding.

Read in order:
1. AGENTS.md §0
2. memory/quick-reference.md
3. design/process/runtime-binding.md
4. design/process/agent-roles.md (QA-Agent section)
5. design/process/operational-patterns.md (RUNBOOK)
6. design/process/visual-qa-catalog.md (if project ships UI)
7. The routed build closeout heartbeat(s), prior audit findings, and route scope

Emit the STARTUP-PULSE from the universal startup quality contract, then run a brief drift-monitoring check. Execute only the routed read-only QA pass. Produce one verdict artifact at handoff/notes/qa/<YYYY-MM-DD>-<scope>-qa-verdict.md with verdict, per-surface observations, cross-surface coherence notes, specific feels-off items, and what worked well. Emit qa-verdict:<group>:<verdict> as a heartbeat milestone. No code changes. No commit-request authoring. NO PUSH.
```

**Handoff / replacement:**

- Closing session emits `closed` with route scope, verdict, artifact path, follow-up owner.
- New instance reads previous QA verdict artifact and heartbeat route before rerunning a pass.

**Shutdown behavior:**

- On `shutdown-request`: finish current verdict artifact if evidence sufficient; otherwise emit `blocked` or `closed` with incomplete status and owner/action.

**Anti-patterns:**

- Don't default to pass because tests passed.
- Don't author CRs or make product fixes.
- Don't broaden scope beyond routed surfaces/personas/viewports.
- Don't post vague "feels off" feedback without route/action evidence.

---

### Resident Autonomy Agent (added in extended-roles wave, 2026-06-22)

**Embodied by:** A long-running deterministic loop bound to the project runtime — reference implementation is a Python/shell script running in its own tmux session. Not an LLM session. Distinct from the Observer's away-but-alive loop (which is an LLM session with synthesis authority).

**Purpose** — drive autonomous building. Take already-approved slices and route them through the runtime to executors, without a human (or chat agent) needing to manually dispatch each item. The full contract lives in `resident-autonomy.md`; this section is the role contract within `agent-roles.md`.

**Cadence** — `every <interval_sec>` (default 60 sec). One route emission per tick (governor).

**Inputs:**

- Reconciled-truth snapshot (`reconciled-truth.md`).
- Own state file (autonomy-loop.json — duplicate suppression, backoff, classifications).
- Runtime role health (from `runtime-binding.md` state files).
- Goal manifests (from `autonomy-goal-runner.md`).

**Outputs:**

- Routes emitted per the route-delivery contract (`runtime-route.md`).
- State-file updates after every tick.
- Classification events (route_ack_miss, executor_closed, blocked_signature_change, clock_drift, stale_active, queue_delta, goal_acceptance_pending, audit_findings_triage).
- Heartbeat startup pulse on boot; tick-summary pulses are NOT emitted (would flood heartbeat).

**State location:**

- `~/.cache/<project-slug>/operator-runtime/state/autonomy-loop.json`.

**Authority — DETERMINISTIC, BOUNDED:**

- CAN route approved slices passing the admission gate.
- CAN mark roles unhealthy on delivery failure.
- CAN classify events for observer / orchestrator review.
- CAN wake advisory roles (Operator Brain, UX Patch Author, Observer) per `resident-autonomy.md` §7.
- CANNOT approve work, decide priority, change CR status, close goals.
- CANNOT treat LLM recommendation as approval.
- CANNOT push, force-push, rewrite history, delete user work, bypass signing.
- CANNOT retire work without concrete terminal evidence.

**Relationship to existing roles:**

- **Coordinator:** Coordinator can be a human-driven mechanical orchestrator OR the Resident Autonomy Agent fulfilling the routing role. They share the contract.
- **Observer:** Observer watches the loop. The loop classifies events; Observer synthesizes them.
- **Orchestrator:** Orchestrator owns approval. The loop only routes what's already approved.
- **Operator Brain / advisory roles:** the loop wakes them on classified events; they advise; the loop honors recommendations only when deterministic gates pass.

**Spawn prompt template:** Not applicable — this role is a script, not a chat agent. Boot procedure lives in `resident-autonomy.md` §8.

**Disable:** `<PROJECT>_AUTONOMY_LOOP=0` env var at cold boot.

**Shutdown behavior:** Cold-stops on `shutdown-request`; resumes on next runtime boot if env var allows.

**Anti-patterns:**

- Don't accumulate ungated "smart" behavior. Every new rule must be deterministic and reviewable.
- Don't bypass the admission gate "just this once."
- Don't silently retire work without evidence.
- Don't emit chatty heartbeat events (one route emission per tick, not a tick log).

---

## §6. Slot model — role-to-session mapping

Same human-readable label (e.g., Codex A, Codex B, Codex Build) can be held by different session instances over time. The slot is durable; the instance is transient.

**Slot framework (starter — adapt per project):**

| Slot | Typical role | Embodiment | Stable across sessions |
|---|---|---|---|
| Codex A | Executor (parallel anchor block A) | Codex CLI | Yes |
| Codex B | Executor (parallel anchor block B) | Codex CLI | Yes |
| Codex Build | Executor (infrastructure) | Codex CLI | Yes |
| Observer | Observer | Codex CLI | Yes |
| Async Architect | Async Architect | Codex CLI | Yes |
| Cowork Orchestrator | Orchestrator | Cowork / Sonnet | Yes (across days) |
| Cowork Architect | Sync Architect | Cowork / Opus | Yes (across days) |
| Codex (ad-hoc) | Executor (one-off) | Codex CLI | No — ephemeral |

Session-to-slot mapping is recorded in:

- Chronicle header: `**Slot:** Codex A`
- `.wb-owner` canary: `slot:`, `human_label:`, `replaces:` fields (extension of RUNBOOK Entry 6)
- Heartbeat events: `slot:<slot-name>` ref alongside `chronicle:` ref

**Session-replacement protocol:**

1. Closing session emits `closed` event with `slot:<slot-name>` ref.
2. New session emits `started` (or `resumed` for restart) with `slot:<slot-name>` + `replaces:<prior-session-id>` refs.
3. Heartbeat shows continuous slot occupancy across instance boundaries.

---

## §7. CLI-bootable session set

When the user boots iTerm (or their terminal of choice), an **infrastructure session set** comes up. Each session takes its role + begins its cadence. Project-loop sessions (Anchor Executors) do NOT auto-spawn — they wait for Orchestrator routing per the user's intent.

**Always-on (boot via iTerm tabs or launchd):**

- **Observer** (Codex CLI; 5-10min polling + hourly synthesis)
- **Async Architect** (Codex CLI; 30-60min polling for Observer proposals)
- **Memory Steward** (cron-scheduled; not iTerm-managed)
- **Build Executor** (standby; spawned on-demand for commit-request execution OR kept warm in an idle tab)

**On-demand (spawn when needed):**

- **Anchor Executor** (Codex CLI via `wb-task <task>-walkthrough`; one per task)
- **Cowork Orchestrator + Sync Architect** (user opens Cowork app, starts chat)
- **Ad-hoc Executor** (Codex CLI for one-off tasks)

**Cold-start sequence:**

1. iTerm restores tab labels + cwd defaults.
2. The user manually invokes the CLI in pre-designated tabs — OR runs `scripts-infra/spawn-agent.sh` to automate (see that script for details).
3. Each session's spawn prompt is the role contract from §5; sessions self-bootstrap.
4. First session up runs cold-start recovery (§8).
5. Cron resumes Memory Steward at next 2hr boundary.
6. The user opens Cowork when ready for synchronous work.

### §7.1 Permission mode for Codex CLI sessions

**ALL Codex CLI sessions across ALL roles MUST be started with full-access permissions** (Codex CLI's flag at time of authoring is `--dangerously-bypass-approvals-and-sandbox`; the version-current equivalent applies if the flag name changes — verify against `codex --help` before encoding into automation). This is NOT limited to the always-on infrastructure set — it applies equally to every Codex-embodied role: Observer, Async Architect, Memory Steward, Build Executor, Anchor Executor, Ad-hoc Executor.

> **Note on flag confusion.** Claude Code CLI's full-access flag is `--dangerously-skip-permissions` (different name, different tool). When automating, verify per-tool what the correct flag is — they're not interchangeable.

**Why:** Default Codex CLI mode prompts for approval on file writes / command execution. For every Codex role this is broken:

- **Observer** — polling cadence stalls on the first heartbeat append approval prompt.
- **Async Architect** — commit-request authoring blocks on the first file write.
- **Memory Steward** — filesystem scans block on the first read.
- **Build Executor** — commit operations block on every signing step.
- **Anchor Executor** — even WITH the user present, a single task's validation cycle is typecheck + targeted tests + full test suite + style check + visual snapshot (many stories) = dozens of file reads + executions per gate × N gates per task. Approval prompts make every task 10× slower + introduce prompt-fatigue errors.
- **Ad-hoc Executor** — same as anchor; prompt cadence breaks task throughput.

The autonomous loop doesn't run if the user has to approve every action. "Away but alive" mode (§10) becomes "away and asleep." Even sync mode (user present + Codex executing a task) is dramatically degraded by prompt-on-every-operation.

**Cowork sessions are exempt** — different sandbox model entirely (per §2 sandbox-as-cleavage). Orchestrator (Sonnet) and Sync Architect (Opus) run in Cowork sandbox where the approval-prompt concept doesn't apply the same way; their activation-dependence (only acts on user message) absorbs whatever approval semantics exist in chat UI.

**Safety reasoning:** the behavioral discipline that actually constrains what sessions DO lives in the framework itself, NOT in external permission prompts:

- NO PUSH discipline per push gates.
- Path-restricted commits per RUNBOOK Entry 4.
- Forbidden Actions per AGENTS.md.
- Scope guardrails per each commit-request.
- Step 0.5 pre-action conflict + context check.
- `.wb-owner` canary file enforcement per RUNBOOK Entry 6.
- Authority boundary per §3 of this doc.

Permission prompts in Codex CLI sessions are redundant friction that breaks autonomy (in autonomous roles) and breaks throughput (in synchronous roles like Anchor Executor when the user is present). The framework discipline catches what permission prompts would catch, more precisely + without the per-operation overhead.

**Boot script convention:** `scripts-infra/spawn-agent.sh` embeds the full-access flag for each Codex invocation in the autonomous set. Manual boot meanwhile: the user invokes `codex` with the appropriate flag for each tab.

**On encountering an approval prompt mid-session:** if a session in the autonomous set DOES encounter an approval prompt (e.g., session was started without the right flag, or Codex CLI's permission model evolved), the session should:

1. Heartbeat-block immediately with `blocked` event noting "permission prompt encountered — session not in full-access mode."
2. NOT auto-approve.
3. Wait for the user to restart the session with correct flags.

Sync/Cowork sessions don't need this — they're activation-dependent by design and prompts are absorbed into the chat interaction.

---

## §8. Cold-start recovery protocol

First session up post-reboot runs this sequence BEFORE role-specific work, regardless of role.

```bash
# 1. Heartbeat archaeology
tail -n 200 memory/heartbeat.md

# 2. Shutdown snapshot check
test -f memory/last-shutdown-snapshot.md && cat memory/last-shutdown-snapshot.md
# If present and recent (<30 days): managed-shutdown recovery; read snapshot for state.
# If absent OR stale: unmanaged-shutdown recovery; proceed to step 3-5.

# 3. Worktree reconciliation
git worktree list --porcelain
# For each task worktree:
#   Check chronicle Status field; if `active` but last heartbeat event is >30min old → flag `cold-orphan-candidate`.
#   Check .wb-owner canary; if owner session-id has no recent heartbeat → flag canary as stale.

# 4. Server reconciliation
lsof -i :6006 -i :3000 -i :8005 -i :6010-6099 -i :3010-3099 -i :8010-8099 2>/dev/null
# (Substitute your project's canonical + task-validation port ranges.)
# Note: at cold-start no servers should be running. If any are, surface.
# The user's reviewer servers (canonical ports) need manual restart.

# 5. Chronicle staleness check
ls -lt memory/sessions/*.md | head -20
# Flag any `Status: active` chronicle with no recent heartbeat events as orphan-candidate.
```

After recovery, emit a `cold-start-recovery` heartbeat event summarizing findings:

- Were there orphan worktrees? (list)
- Were there stale canaries? (list)
- Were there active-but-quiet chronicles? (list)
- Was there a shutdown snapshot found? (yes/no + summary)
- What state do servers need restored?

Then proceed to take role-specific bootstrap. The recovery event is the FIRST artifact post-reboot — anchor for subsequent work.

---

## §9. Shutdown protocols

### Managed shutdown — three modes

The user signals via heartbeat OR Cowork message:

```
TS | <user-id> | shutdown-request | <quick-break|end-of-day|full-stop> — reason: <reason>
```

**Quick break** (user away 1-3 hours): no special action. Cowork goes dark naturally; CLI sessions continue per "away but alive" mode. Memory Steward keeps firing on cron.

**End of day** (user away overnight): same as quick break, longer window. Async Architect's slower cadence accumulates more proposals; Observer's synthesis spans larger windows. The user finds richer summary on return.

**Full stop** (vacation, system maintenance, want clean state): explicit wind-down.

Per-role full-stop behavior:

- **Anchor Executor** — complete current validation gate; commit OR rollback to safe state; emit `closed` with merge status; do NOT pick up next task.
- **Build Executor** — process queued commit-requests until queue clears; emit `closed`.
- **Async Architect** — complete current proposal-processing; emit synthesis-summary of session; close.
- **Observer** — complete current polling cycle; run ONE final synthesis pass; **produce shutdown snapshot**; emit `closed`.
- **Memory Steward** — cron-scheduled; unaffected by shutdown-request (cron persists). Will fire at next scheduled time.
- **Sync Architect + Orchestrator** — Cowork — chronicle saved per multi-day convention; the user naturally closes Cowork.

### Shutdown snapshot (Observer produces at full-stop)

Path: `memory/last-shutdown-snapshot.md`. Replaced each managed shutdown.

Template at `memory/last-shutdown-snapshot.md` (ships empty in Cadence; Observer fills on first full-stop). Contents include:

- Shutdown type + timestamp + reason + heartbeat refs.
- Active sessions at shutdown.
- Worktrees at shutdown.
- Repo state (branch, HEAD, dirty tracked files).
- Servers at shutdown.
- Pending queue / next cold start.
- Risks / watch items.

### Unmanaged shutdown handling

No `shutdown-request` event; no snapshot. Sessions die mid-task. Cold-start recovery handles via §8 protocol. Snapshot file absent OR stale → fall through to full heartbeat-archaeology recovery + chronicle reconciliation.

---

## §10. Away-but-alive mode

The default operating state when the user is offline but CLI sessions continue running.

**What's happening:**

- Cowork sessions dark (no user, no chat).
- Codex CLI sessions: Observer polling + synthesizing; Async Architect processing proposals + landing infrastructure refinements; Build Executor executing infrastructure commit-requests; Memory Steward firing on cron.
- Project work: paused. No Anchor Executors active (none auto-spawn without Orchestrator routing per user intent).

**What changes:**

- Infrastructure: continues evolving via Observer → Async Architect → Build Executor loop.
- Project: static. Anchor work resumes only when the user returns + opens Cowork + directs Orchestrator.

**What the user finds on return:**

- Heartbeat shows infrastructure-loop activity during away window.
- Observer's accumulated synthesis available for catch-up.
- Async Architect's landed refinements visible in commit log + RUNBOOK / agent-roles edits.
- Pending Observer proposals not yet processed surface as `note` events.
- Project work exactly where the user left it.

**Orchestrator handles the user's first message on return** — typically "pulse check" producing a structured summary per RUNBOOK Entry 14.

---

## §11. Authority hierarchy summary

```
PROJECT LOOP (HITL-bound)
User intent → Cowork Orchestrator (Sonnet) routes per intent → Anchor Executor implements
                  ↑                                            ↓
              Sync Architect (Cowork/Opus) ←── architecture review
                                                  ↓
                                            User approves project D-* entries

INFRASTRUCTURE LOOP (autonomous)
Activity → Observer polls (5-10min) + synthesizes (hourly)
              ↓
          Async Architect processes proposals (30-60min)
              ↓
          Build Executor lands infrastructure commits (on-demand)
              ↓
          Improved system; cycle continues
              ↓
          Memory Steward reconciliation (cron 2hr)

CROSS-LOOP COORDINATION
- Observer flags project anomalies → routes to Orchestrator/user (not Async Architect).
- Async Architect flags ambiguous infrastructure changes → escalates to Sync Architect/user.
- Memory Steward surfaces drift to both loops.
```

Two parallel loops. Project pauses without the user; infrastructure self-improves.

---

## §12. Cross-role coordination

How roles interact via heartbeat:

- **Sync Architect → Orchestrator** — `note` with `target:<orchestrator-session-id>` containing decisions or recommendations.
- **Orchestrator → Anchor Executor** — task brief OR `note` with `target:<executor-slot-or-session-id>` containing imperative kickoff (per RUNBOOK Entry 11).
- **Observer → Async Architect** — synthesis-proposal `note` with `target:<async-architect-session-id>` containing pattern observed + count + scope.
- **Observer → Orchestrator/user** — anomaly flag `note` for project-related routing OR `blocked` for HITL escalation.
- **Async Architect → Build Executor** — infrastructure commit-request OR `note` with `target:<build-executor-session>` directing execution.
- **Anchor/Build Executor → Architect** — `blocked` event for Tier 3 escalation.
- **Memory Steward → all** — drift reports + heartbeat `milestone` per run; all roles can read.
- **User ↔ any role** — direct message (Cowork chat OR Codex CLI input). Broadcast via heartbeat for cross-role awareness.

**Routing principle: emit-and-yield.** Role emitting a note for another role does NOT block its own work waiting for response (unless explicitly a `blocked` event). Other role responds at its cadence.

---

## §13. Maintenance

**Adding a new role:** author the role definition per §4 schema; append to §5; update §6 slot table if stable slot; update §12 if new cross-role interactions; add change log entry.

**Modifying an existing role contract:** significant changes via commit-request (RUNBOOK Entry 14 documents this); minor refinements edit-in-place + change log entry.

**Deprecating a role:** add DEPRECATED header; document migration path; preserve section for historical context (append-only principle).

**Garden-tender discipline** (Observer enforces in synthesis loop):

- Additions only after 3+ observations.
- Consolidations every synthesis cycle.
- Deprecations after 7+ days of no firing.
- Net change in lines per synthesis cycle approaches zero.

---

## §14. Change log

| Date | Author | Change |
|---|---|---|
| (template) | (source project author) | v1 initial authoring: 5 roles fully specified (Orchestrator, Architect, Executor in 3 flavors, Observer, Memory Steward). Slot model with 5 slots. Cross-role coordination via heartbeat. Pairs with RUNBOOK Entry 14 (pulse-check protocol). |
| (template) | (source project author) | v1.2: 14 additions including Sync/Async Architect split, Observer bounded directive authority + synthesis loop, infrastructure-vs-project authority boundary, CLI-bootable session set, cold-start recovery, managed/unmanaged shutdown protocols, away-but-alive mode. |
| (template) | (source project author) | v1.2 §7.1 + ALL-roles clarification: NEW §7.1 Permission mode for Codex CLI sessions; clarifies ALL Codex roles need full-access; spawn-prompt templates gain PREREQUISITE notice; Cowork roles exempt. |

---

*v1.2 reflects an explicit scoping: infrastructure self-evolves autonomously; product waits for HITL. Pairs with: `operational-patterns.md` (RUNBOOK), `drift-classes.md` (drift taxonomy), `autonomy-gap-framework.md` (escalation tiers), `../../memory/HEARTBEAT_SPEC.md` (heartbeat format), `scripts/wb-session.sh` (worktree toolkit), `scheduled-tasks/memory-steward-prompt.md` (steward role spec).*
