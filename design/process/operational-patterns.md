# Operational Patterns

**Status:** Living document — append-mostly. Captures emergent operational patterns from running the project that are not yet canonical decisions but are stable team conventions. Often referred to as the **RUNBOOK**.

**Distinction from AGENTS.md:** AGENTS.md is the binding contract: forbidden actions, Git workflow, GPG signing, deferred set, and §0 bootstrap. This file is how the team currently works. If a pattern crystallizes into a hard rule, migrate it to AGENTS.md as a decision.

**Reading order:** every fresh Codex, Cowork, Claude Code, or other agent session reads this after AGENTS.md §0 bootstrap and before the first heartbeat `started` event. Patterns are ordered by likelihood of blocking fresh pickup.

> **Provenance.** The 13 entries below are patterns accumulated through empirical multi-agent operation. Some are universally applicable; others are stack-specific (npm / Storybook / Vite). Keep what fits; replace stack-specific items with your equivalent; add new ones as your project's operational reality surfaces.

---

## 1. Per-worktree validation environment (stack-specific — adapt)

**Pattern:** Task worktrees do not need their own dependency install. Symlink `<your-deps-dir>/node_modules` (or equivalent) to the main checkout's `<deps-dir>/node_modules`. Run typecheck / build steps in a mode that doesn't write build-cache files that race across worktrees.

**Why:** Per-worktree dependency installs add time and disk churn to every task. The symlink pattern keeps one dependency tree per machine.

**Exception:** If a task genuinely needs a new dependency, run the install in the worktree, stage the lockfile alongside the feature files, and flag the dependency addition in the commit body.

**Edge case:** If the main checkout's deps directory is absent, install once in main, then symlink from worktrees. Do not default to a full install in every worktree.

**Do:**
- Check whether the deps directory already exists in main before doing anything expensive.
- Prefer one dependency tree per machine session unless a package change is part of the task.
- Mention any deviation in heartbeat so later sessions understand why the worktree differs.

**Do not:**
- Run a full install in a task worktree as a reflex.
- Delete an active worktree's deps directory while another validation process may be using it.
- Treat an ignored deps directory as something to stage or clean during merge-back.

## 2. Stale-cwd recovery procedure

**Pattern:** If your shell `pwd` reports a worktree path that no longer exists, execute this recovery:

```bash
cd $WB_REPO   # main worktree
pwd
git branch --show-current
git status --short
tail -n 100 memory/heartbeat.md
```

Then emit a `resumed` heartbeat event noting the cwd correction and state catch-up. Do not start new work until the `resumed` event lands.

**Why:** A Unix shell holds cwd as an inode reference. When a worktree is removed, the inode is freed but the shell can still report the old path while filesystem operations fail.

**UI quirk:** Some agent UIs may continue to display the deleted path even after recovery. Use explicit `cd`, `workdir`, or `git -C <path>` for all subsequent operations until the session is restarted.

**Signals that you are in stale cwd:**
- A command without explicit cwd fails with `No such file or directory`.
- The status bar shows a removed worktree after heartbeat says it was merged and removed.
- `ls -ld <worktree-path>` from `/` reports the path is gone.

**Do not infer safety from the UI alone.** Shell-backed confirmation wins over status-bar labels. If the UI cannot update, continue only with explicit `workdir` or restart the session from the main worktree.

## 3. Per-anchor / per-slice build pattern (project-specific — adapt)

**Pattern:** Each implementation slice follows the same template: read the build brief, read the canonical anchor / surface pattern, inspect the visual spec, find the existing route mount, build the slice against existing wrappers and helpers, wire one or two key interactions, add tests, run validation gates in order. Don't reshape canonical structure unless the brief explicitly asks for it.

**Why:** Predictable per-slice flow lets multiple parallel sessions build without each having to relearn the contract.

**Scope guard:** Per-slice work is anchor-specific adapter work. It may compose existing wrappers and preview helpers, but it should not reshape the canonical library unless the brief explicitly asks for that work.

**Interaction guard:** Wire the smallest meaningful interaction that proves the slice is not static. Keep it local or mock-backed unless the brief explicitly calls for full integration.

> Adapt this entry to your project's actual per-slice pattern as it stabilizes. Delete if your project doesn't have a per-slice structure.

## 4. Commit discipline

**Pattern:** All commits use path-restricted staging:

```bash
git add -- <path1> <path2>
git status --short -- <path1> <path2>
git commit -S -m "type(scope): summary" -- <path1> <path2>
```

The trailing `-- <paths>` on `git commit` ensures ONLY the listed paths land, regardless of what's currently in the index. Verify staging matches the intended list before committing. Signed commits are required. No force-push or history rewrite on shared branches.

**Why:** Path-restricted staging prevents accidental capture of unrelated dirty files during multi-session work. Becomes the defensive default after any incident where broad staging captures a concurrent agent's WIP.

**Before commit, always inspect:**

```bash
git diff --cached --name-status
git status --short
```

If unrelated files are staged, unstage only those paths. Do not reset the whole index unless the user explicitly asked for destructive cleanup.

**Commit messages:** If execution required a scoped expansion, such as adding a dependency or repairing a canary from a stale prompt, state it in the commit body. Reviewers should not have to infer why the path list grew.

## 5. Heartbeat append mechanic

**Pattern:** Append heartbeat events atomically with `>>` to the canonical main-worktree path. Use timestamps with UTC offset:

```bash
TS=$(TZ=America/Los_Angeles date '+%Y-%m-%dT%H:%M:%S%z')
echo "$TS | <session-id> | <event-type> | <summary> | <refs>" >> $WB_REPO/memory/heartbeat.md
```

Event types: `started`, `resumed`, `milestone`, `note`, `blocked`, `interrupt`, `closed`. One line per event. No internal newlines.

**Why:** Atomic append is concurrency-safe across sessions, the absolute path avoids cwd-dependent failures, and timezone-with-offset timestamps stay aligned across DST.

**Cadence:** Emit heartbeat events at start, major validation transitions, before merge-back, on blocker, on ownership handoff, and on close. A session that is doing meaningful work but has been silent long enough for another agent to wonder is creating coordination debt.

**Audience:** Write heartbeat entries for other agents, not for yourself. Include the worktree or anchor name, validation status, commit hashes, and whether the event changes routing.

## 6. Worktree lifecycle

**Pattern:** Spawn via `wb-task <name>`. This is the canonical path for per-task work. `wb-task` writes the `.wb-owner` canary file automatically through `wb-spawn` and prevents duplicate sessions from silently sharing a worktree.

**Stale-prompt fallback:** If you are executing a brief, commit request, or kickoff prompt that directs raw `git worktree add` instead of `wb-task`, the worktree can lack `.wb-owner`. Self-repair when you notice the gap or when a peer flags it:

```bash
cat > <worktree-path>/.wb-owner <<EOF
session_id: <your-session-id-or-WB_SESSION_ID>
claimed_at: <timestamp with offset>
worktree: <worktree-name>
branch: <branch-name>
created_via: raw-git-add
EOF
```

Then continue after a heartbeat note explaining the repair.

**On merge-back:** Standard sequence is full validation gates green, signed commits on the task branch, signed merge into the project's integration branch from the main worktree, worktree removal, branch deletion, then heartbeat `closed`.

**Why:** Raw `git worktree add` bypasses the canary write. The self-repair path lets stale prompt scenarios recover without rewriting the original prompt while still closing the ownership gap.

**For prompt authors:** Any new task brief, kickoff prompt, or commit request that creates a worktree must direct `wb-task <name>`, not raw `git worktree add`.

**Ownership check:** A task worktree should have `.wb-owner` at its root. If it does not, pause before adding more code. Either re-enter through `wb-task` if possible or apply the stale-prompt fallback and broadcast the repair.

**Cleanup guard:** Worktree removal is allowed after merge-back only when generated or untracked artifacts are either intentionally ignored or preserved. Do not use hard-delete cleanup while another session may still be validating in that worktree.

## 7. Known shell quirks

- **macOS APFS is case-insensitive by default.** `Heartbeat.md` and `heartbeat.md` collide. Use exact casing: `memory/heartbeat.md` for the ledger and `memory/HEARTBEAT_SPEC.md` for the spec.
- **`#` in zsh paste blocks** does not default-honor as a comment. Avoid comments in paste blocks or run `setopt interactive_comments` first.
- **Network-first check when loopback at `127.0.0.1:<port>` is unreachable.** Check firewall / VPN posture before assuming session sandboxing semantics.
- **GPG signing is mandatory.** If signing fails, do not retry unsigned. Emit `blocked`, fix the signing environment or stale lock, and then commit with `-S`.
- **Sandbox sessions never acquire the host Git lock (prevention, not release-discipline).** A sandbox/VM session (e.g. a hosted-sandbox chat session or scheduled task) that writes to a host-mounted repo acquires the **host** `.git/index.lock` through the mount, then cannot unlink it on cleanup — the mount layer returns EPERM, the lock strands, and every host-side writer is blocked until manual removal. A "remember to release the lock" rule cannot fix this because the writer traps cleanup and the mount defeats it. Therefore: **sandbox/VM sessions are Git inspect-only** (`status` / `log` / `diff` / `show` only — never `add` / `commit` / `merge` / `cherry-pick`, never create or remove `.git/*.lock`). All repo writes and lock-resolution are owned by **host-side** writer sessions, each preceded by a lock-preflight evidence check (`<lock-preflight-script>`). Stale-lock auto-heal (no live fd holder + age over threshold) is a **host-side**-only action.

**Why:** These quirks are machine-local and easy to misdiagnose as code issues. Treat them as environment checks before changing implementation. The sandbox-vs-host distinction in particular has been root-caused: the FUSE-EPERM bug strands locks that the originating writer cannot clean up, blocking every host-side writer until manual intervention. Prevention is the only working discipline.

## 8. Dependency-add discipline

**Pattern:** If task work requires a new dependency:

1. Run the install in the task worktree.
2. Stage the manifest + lockfile alongside the feature files.
3. Flag the dependency addition explicitly in the commit body.

**Why:** Dependency additions are scope expansion beyond most task briefs. Explicit commit-body language prevents reviewers from misclassifying a necessary addition as accidental scope drift.

**Review question:** Could this be implemented with an existing repo dependency or local helper? If yes, prefer the existing path. If no, add the package deliberately and leave a clear rationale.

**Lockfile guard:** If the lockfile changes unexpectedly after running tests, inspect the diff before staging. Do not commit lockfile churn unrelated to the dependency you intended to add.

## 9. Validation gate sequence (project-specific — adapt)

**Pattern:** Per-slice validation runs gates in order; each must pass before the next:

1. Typecheck.
2. Targeted tests for the slice.
3. Style / token / lint checks.
4. Full unit test suite.
5. Visual / integration snapshot (or rendered-route QA) — choose port per Entry 13 port-allocation convention.

Do not skip gates or accumulate failures across gates. If a gate fails, fix it before proceeding.

**Why:** Ordered gates catch issues at the cheapest point: type errors before tests, focused tests before full suite, and unit/style cleanliness before the slower visual snapshot.

**Failure handling:** A failed gate is a work item, not a reason to continue to later gates. Fix, rerun the failed gate, then continue.

> Adapt to your project's actual validation order. Drop the snapshot step if you don't have one.

## 10. Heartbeat-tail-on-start

**Pattern:** Fresh sessions, before writing their first `started` event, run:

```bash
tail -n 100 $WB_REPO/memory/heartbeat.md | grep -E "(<worktree-or-anchor-name>|<session-id>)"
```

Inspect for:

- **Conflict events:** `started` events for the same worktree or anchor from a different session-id with no subsequent `closed`. If found, abort and emit `conflict-detected`.
- **Operational `note` events:** notes targeting your session-id, worktree-name, or work scope, such as validation patterns, dependency directives, or recent guidance. Treat these as Tier 0 self-resolve signals.
- **Recent `blocked` events:** similar work indicating known issues you should account for.

**Why:** AGENTS.md Step 0.5 handles claim collisions; this extension handles operational-context drift (Class 2 in `drift-classes.md`). Conflict-grep alone does not catch operational decisions in non-conflict heartbeat events.

**Search terms:** Include the slice ID, worktree slug, session-id, and nearby known aliases. For example, if a slice is sometimes referred to by feature name and sometimes by slug, search both.

**If grep has no matches:** Tail without grep and scan the last events anyway. A broad operational note may target `all`, an observer session, or a session family rather than your exact slug.

## 11. Kickoff-prompt authority

**Pattern:** A kickoff prompt issued by the orchestrator / architect is authorization. No separate "go" signal is required. If you have a kickoff prompt and heartbeat shows no conflict on your target worktree or anchor, execute the kickoff prompt's first action immediately.

Do not bootstrap, read heartbeat, emit a note asking "can I start?", and wait for routing when you already have a kickoff prompt.

Do bootstrap, read heartbeat per Entry 10, emit `started` if no conflict exists, and execute the kickoff prompt's first action.

**Why:** Procedure-style kickoff phrasing combined with Step 0.5 caution can collapse into wait-mode. The heartbeat-tail is the safety check, not a wait-state.

**For prompt authors:** Phrase kickoffs as imperatives. "Your first action is: `wb-task <task>`. Execute now." reads as authorization. "Pattern for tasks: use `wb-task`" reads as documentation.

**Boundaries still apply:** Kickoff authority does not override AGENTS.md, deferred paths, explicit user pauses, or a heartbeat conflict. It removes the need for an extra permission question only after those checks are clear.

**When in doubt:** If the kickoff and heartbeat conflict, heartbeat wins until clarified. If the kickoff is clear and heartbeat is clear, execute.

## 12. Post-task state announcement (suggested — under evaluation)

**Pattern:** After completing a routed task, an executor session announces current role, non-ownership, observed active owners, and next-action boundary in a heartbeat `note` event.

**Why:** Without an explicit state announcement, peer sessions can't tell whether a session that just shipped is still ownership-active or has stepped down. Closing a task ≠ closing the session.

**Example:**

```
TIMESTAMP | codex-build-session | note | STATE ANNOUNCEMENT: this Codex Build session is now observer/pulse-only in main worktree; docs/RUNBOOK sequence is closed; not owning <task-X>, <task-Y>; will not touch active anchor worktrees unless explicitly routed after heartbeat conflict check. | ...
```

> Status: this pattern surfaced empirically; not yet hardened. Keep an eye on whether it reduces coordination friction; promote to a hard convention if so.

## 13. Port allocation across worktrees (canonical vs task-worktree ports)

**Pattern:** The main worktree owns canonical ports for long-lived reviewer surfaces (e.g., your default dev server / UI / API ports per `scripts/run-local.sh` or equivalent). These ports are reserved for the reviewer's review surface and must not be bound by active validation sessions.

Active sessions running validation gates must use distinct ports from task worktrees, in a reserved range:

- **Validation UI servers:** use a port in your designated task-validation range (e.g., 3010-3099).
- **Validation API servers:** use a port in your designated task-validation range (e.g., 8010-8099).
- **Validation snapshot / visual servers:** use a port in your designated task-validation range (e.g., 6010-6099).

**Pre-check pattern:**

```bash
PORT=6020
lsof -i :$PORT >/dev/null 2>&1 && echo "Port $PORT in use; scanning upward" && PORT=$((PORT + 1))
<validate-command> --port=$PORT
```

Pass the assigned port to the validation command. For rendered-route QA that needs a full local stack, pre-check each port (`UI_PORT`, `API_PORT`, etc.) before binding.

**Why:** Reviewer workflows are long-lived by design — servers run across multiple task cycles for human-eye review. Active sessions are short-lived but bind ports during validation gates. Without port isolation, every parallel validation run can collide with the reviewer's session or another active session's validation cycle.

**Pre-validation port pre-check:** before starting any local servers in a task worktree, run:

```bash
lsof -i :<canonical-ports> -i :<task-range> 2>/dev/null
```

Identify what is currently bound, then pick a distinct port.

**Heartbeat-note pattern:** when binding a port for validation, emit a heartbeat note specifying the port assignment:

```text
TIMESTAMP | <session-id> | note | Allocated validation ports - UI: 3024, API: 8024, Snapshot: 6024 | chronicle:<chronicle-file>
```

Peer sessions should tail-grep before binding their own ports; observer and pulse-watch can detect collisions proactively when the assignment is visible.

**Reviewer surface — do not touch:**

- Main worktree dev / UI / API processes on canonical ports when heartbeat or observer notes identify them as the reviewer's surface.
- Never stop a process you did not start unless heartbeat explicitly authorizes it.

**Follow-up:** allocate ports at worktree spawn time via `wb-spawn` and record assignments in the `.wb-owner` canary file. Sessions would then read ports from canary, eliminating most `lsof` races.

## 14. Pulse-check response contract

**Pattern:** When any session is asked "pulse check" or an equivalent state-sync request, respond in this exact order.

**Required response sections — in order, no deviations:**

1. **Session(s) — details**
   - Active sessions, worktrees, owner, current task, last heartbeat timestamp, blocker or risk, and next action.
   - Completed work only if state changed since the last pulse; otherwise omit it to avoid noise.

2. **Repo / worktree — latest update**
   - Main branch and HEAD commit.
   - Active worktrees and their HEADs.
   - Dirty summary by count and category; do not enumerate full lists unless asked.
   - Stale-base risks for worktrees behind main.
   - Merge-back risks or uncommitted state that needs handling.

3. **Server / Storybook / dev-server active URLs**
   - UI, API, and visual / snapshot URLs currently bound, with PIDs when visible.
   - Canonical port owners — the user's reviewer surface per Entry 13.
   - Validation ports in use and any collisions.

4. **Anything you see fit to report — high-signal only**
   - Routing recommendations.
   - User-facing feedback queued.
   - Anomalies the requestor should know about.
   - Filter out routine activity; surface only what changes decision-making.

**Required checks before responding:**

```bash
# 1. Heartbeat tail
tail -n 60 memory/heartbeat.md

# 2. Worktree list
git worktree list

# 3. Status of main and active worktrees
git status -sb
git -C <each-active-worktree-path> status -sb

# 4. Port-binding scan (substitute your project's canonical + task-validation ranges)
lsof -i :<canonical-ports> -i :<task-validation-ranges> 2>/dev/null

# 5. Verify heartbeat claims match observable state
# For example, if heartbeat says "<task> closed", verify the worktree is actually gone.
```

**Required flags:**

- Sessions with no heartbeat in more than 10 minutes: flag as `stale`. They may be hung, paused, or working silently.
- Branches behind the project's default/integration branch HEAD: flag as `stale-base` risk for the relevant session.
- Port collisions on canonical ports: flag as `interrupt` priority.
- Any session operating in a deleted worktree: flag for Entry 2 stale-cwd recovery.

**Forbidden during pulse-check execution:**

- No code mutation except urgent heartbeat coordination, such as posting an `interrupt` if the pulse discovers a serious collision.
- No file edits in active task worktrees.
- No commits, pushes, or worktree creation.

**Why:** Pulse-checks are the primary state-syncing surface between the user (or any orchestrator) and the multi-session system. Formalizing the response contract makes pulse outputs reproducible: any session asked for a pulse produces the same shape. It reduces operator overhead because the required checks are explicit rather than implicit.

**Cross-references:**

- Observer role contract: `agent-roles.md` §5 Observer role.
- Port allocation: Entry 13.
- Stale-cwd recovery: Entry 2.
- Heartbeat-tail conflict and context check: Entry 10.

---

## 15. Warm pickup vs cold-start spawn

**Pattern:** When a role-bound session needs to claim work, prefer **warm pickup** (resuming an already-bound session) over **cold-start spawn** (creating a new session). Cold-start spawning incurs a startup-pulse round-trip + bootstrap reading cost; warm pickup just routes a new prompt to an idle session.

**When cold-start is the right move:**

- The role isn't bound yet (cold boot of the runtime).
- The bound session is unhealthy (stale, no recent heartbeat).
- Authority requires fresh context (e.g. a permission-mode change).

**When warm pickup is the right move:**

- The bound session is healthy and idle.
- The new work is within the role's standing authority scope.
- The bound session has recent context that's useful (recent route history, current state).

**Why:** Cold-start spawn churn fragments role context across many short-lived sessions. Warm pickup preserves operational memory. Per `runtime-binding.md`, persistent roles are designed for warm pickup as the default.

## 16. CLI operator-trigger model

**Pattern:** Sessions that operate from a CLI runtime (not a chat interface) take action on triggers, not on intent. Triggers come from heartbeat directives, scheduled cadence, or explicit operator commands. A CLI session does not "decide on its own" to do work — it sees a trigger and responds to it.

**Trigger types:**

- **Heartbeat directive:** parser-safe `directive:true` event targeting this session/role.
- **Scheduled cadence:** cron / runtime-loop tick.
- **Operator-explicit:** human types a command in the CLI session.

**Why:** A CLI session has no chat-context to interpret. Triggers must be parseable from heartbeat state alone. This pattern keeps CLI sessions deterministic — same triggers in, same actions out.

## 17. Outcome reporting contract

**Pattern:** Every terminal heartbeat event (`closed`, `blocked`, `merged`) must include a structured outcome ref so downstream consumers (autonomy loop, observer, lane resolver) can parse without prose interpretation.

**Required outcome fields per terminal state:**

| State | Required refs |
|---|---|
| `closed` | `outcome:<short-label>` `evidence:<artifact-or-sha>` |
| `blocked` | `blocked:<reason-class>` `owner_needed:<role>` `evidence:<artifact-if-any>` |
| `merged` | `outcome:merged` `commit:<sha>` `branch:<source>` |

**Why:** Prose interpretation of "what happened" doesn't scale. Refs in a defined grammar let deterministic consumers route follow-ups without needing to read English.

## 18. Canonical-orphan watchdog

**Pattern:** Run a background watchdog that detects canonical files (under `design/canonical/`) that have been uncommitted longer than a threshold (default 24h). Emit a heartbeat warning when found. Pairs with the principle that canonical content shouldn't live indefinitely as uncommitted working state.

**Heartbeat shape:**

```
<ts> | <watchdog> | note | canonical orphan risk warning: <N> uncommitted canonical path(s) older than threshold; paths:<list>; oldest:<age>h; likely_owner:<role>; suggested_action:commit, route CR, mark held, or explicitly exclude | detector:canonical-orphan target:<orchestrator> target:<observer>
```

**Why:** Canonical material that lives only as uncommitted working state is invisible to other sessions, the sync engine, and git history. A watchdog turns the visibility into a known-quantity warning.

## 19. Session push-wake watcher

**Pattern:** When the autonomy loop or a coordinator routes work to a target session, the watcher records `<session-pid>.wake-signal` files in a known directory. Targets see the file and know they have routed work waiting.

**Why:** A push-based wake-signal beats poll-based "tail the heartbeat every N seconds." The watcher writes once; the target reads when ready. Reduces idle-tick overhead.

## 20. Submit-confirmation contract for spawned executors

**Pattern:** A newly-spawned executor session, after reading its kickoff prompt and bootstrapping, emits an explicit `submit-confirmation` heartbeat event before doing real work. Confirms it actually got the prompt vs the prompt being lost in spawn race.

```
<ts> | <executor-session> | note | submit-confirmation - <role>; route_id:<id>; kickoff received and parsed; first_action:<what>; NO PUSH
```

**Why:** Spawn races can drop the kickoff prompt (target session wasn't ready, race with terminal config). Without explicit confirmation, the emitter assumes success and the work silently doesn't start. Confirmation closes the loop.

## 21. External health watchdog (out-of-process)

**Pattern:** Health monitoring for in-process sessions runs **out-of-process** — a separate watchdog, not the session itself. The session may be wedged; only an outside observer can detect wedge.

**Why:** A wedged session can't emit "I'm wedged." Out-of-process monitoring is the only reliable detection.

## 22. Bounded next-work scan

**Pattern:** When a role-bound session goes IDLE, it runs **one bounded scan** of the queue for eligible work. If found, it claims one. If not, it remains IDLE — does NOT loop scanning until something appears.

**Boundary:** scan reads reconciled-truth (see `reconciled-truth.md`) once, applies role-specific eligibility filter, picks zero or one item.

**Why:** Unbounded poll-loops eat CPU and flood heartbeat with no-op pulses. A bounded scan + true IDLE is healthier.

## 23. Marshal-before-route inbox

**Pattern:** Before routing a slice to an executor, marshal it through an inbox stage: validate frontmatter, confirm worktree availability, confirm dependencies satisfied, confirm path-scope orthogonal. Only after inbox passes does the route emit.

**Why:** Half-baked routes that fail at the executor end pollute heartbeat with VALIDATION_FAILED noise. The inbox catches the failures earlier and surfaces them as authoring/orchestrator concerns rather than executor failures.

## 24. Self-disambiguating startup pulse

**Pattern:** Every startup pulse explicitly carries the session-id, role, binding mode, worktree posture, queue posture, and first-gate so downstream consumers can parse it without lookup.

```
<ts> | <session-id> | note | STARTUP-PULSE - <role>; binding:<mode>; worktree:<posture>; queue:<posture>; first_gate:<what>; NO PUSH
```

**Why:** A pulse that just says "started" requires consumers to cross-reference role / session / runtime registry. A self-disambiguating pulse parses in one read.

## 25. Pulse-snapshot status surface

**Pattern:** The runtime's status command exposes a single JSON snapshot of role health + queue state + recent events. Consumers read it for status; they don't poll heartbeat directly.

```bash
<runtime>-status --json
```

Equivalent to `reconciled-truth.md` for the runtime-state layer; the two surfaces compose.

## 26. Fast-claim queue for spawn requests

**Pattern:** When multiple sessions could claim a newly-spawned route, a fast-claim mechanism ensures exactly one wins. Reference implementation: first session to write its session-id to a claim file claims; others read and skip.

**Why:** Without fast-claim, two sessions can both think they got the work, leading to duplicate execution and conflicting commits.

## 27. Safe context refresh before `/clear`

**Pattern:** A chat session about to run a context-clearing operation (compaction, `/clear`, or equivalent) writes its current critical state to compaction-survival docs (`design-build-roadmap.md`, `TODO-tracker.md`, chronicle) **before** the clear, not after.

**Why:** Post-clear, the session has no memory of what it was doing. Pre-clear write preserves the state for the post-clear session (whether same session or replacement) to recover from.

## 28. Heartbeat text-safety discipline

**Pattern:** Every heartbeat append must escape pipes (`|`) in human-prose fields. Pipe is the field separator; unescaped pipes in note bodies break parsers downstream.

**Why:** Heartbeat is parsed by every consumer. Format breaks propagate everywhere.

## 29. Chronicle closeout guard

**Pattern:** Before a session emits `closed` to heartbeat, it verifies its chronicle has an Outcomes section. A `closed` heartbeat event without a corresponding chronicle Outcomes block is incomplete and the Memory Steward flags it as drift.

**Why:** The chronicle is the per-session narrative; closing without writing the outcomes loses the "what actually happened" record.

## 30. Portable coordinator routing

**Pattern:** Routes emitted by the Coordinator (or autonomy loop) are parser-safe and runtime-portable. They don't reference specific tmux session names or CLI runtimes — they reference role keys + route IDs. Any runtime binding can consume them.

**Why:** Coupling routes to a specific runtime (tmux, iTerm, etc.) locks the framework into one embodiment. Role-keyed routes survive runtime migration.

---

*Maintenance: append new patterns as they emerge. Existing patterns rarely change. If a pattern proves universally binding, migrate it to AGENTS.md as a decision. Coordinate with `drift-classes.md` — new operational patterns often pair with newly-observed drift classes.*

*Entries 15-30 batch-landed 2026-06-22 from the accumulated sync backlog (sync-reports 2026-05-17 through 2026-06-07). Per-entry provenance lives in the source sync reports; this batch landing was the bottleneck clearance after Cadence HEAD advanced beyond initial commit.*
