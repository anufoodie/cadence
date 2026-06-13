# Cadence

A portable starter kit for **multi-agent workflow infrastructure**. Distilled from empirical learning running parallel Cowork / Codex / Claude Code sessions against a single repository — captured as the project-agnostic shape that powers that coordination.

The name **Cadence** captures the load-bearing concept: the heartbeat / pacing / rhythm of multi-agent coordination. Agents broadcast and listen on a shared heartbeat ledger; the system runs on durable role contracts and reconciliation cadences, not on hope.

---

## What this is

A scaffolding for running multiple coding-agent and chat-agent sessions in parallel against a single repository without coordination collapse. It is a **pluggable engine** — every subsystem below can be activated or deactivated per project from a single manifest (`cadence.config.yml`), so a new project onboards with exactly the coordination machinery it needs and nothing it doesn't. It encodes:

- **A feature manifest** (`cadence.config.yml` + `FEATURES.md` + `scripts-infra/cadence.sh`) — one place to turn subsystems on/off; the onboarding tool prunes what you disable.
- **An operating contract** (`AGENTS.md`) — binding rules every agent reads on spawn: Git workflow, GPG signing, forbidden actions, deferred set, bootstrap reading order, pre-action conflict + context check.
- **A memory architecture** (`memory/`) — INDEX.md as the rolling source of truth; per-session chronicles; an append-only cross-session heartbeat ledger; the daily memory steward.
- **A design corpus shape** (`design/`) — canonical foundation, vertical feature deep-dives, archive, references, and the process docs that govern how they evolve.
- **A worktree-isolation toolkit** (`design/process/scripts/wb-session.sh`) — `wb-spawn`, `wb-task`, `wb-remove` with `.wb-owner` canary enforcement.
- **A drift taxonomy** (`design/process/drift-classes.md`) — 5 classes of agentic-state drift named with structural mitigations.
- **An escalation framework** (`design/process/autonomy-gap-framework.md`) — Tier 0–3 rule for when sessions self-resolve vs escalate.
- **A role-vs-session model** (`design/process/agent-roles.md`) — orchestrator / architect / executor / observer / memory-steward as durable contracts, distinct from transient session instances.
- **An operational RUNBOOK** (`design/process/operational-patterns.md`) — emergent operational conventions captured as they surface.

---

## What's included

```
cadence/
├── README.md                              # this file
├── AGENTS.md                              # operating contract (with <PLACEHOLDERS>)
├── CLAUDE.md                              # thin redirect to AGENTS.md
├── cadence.config.yml                     # feature manifest — activate/deactivate subsystems
├── FEATURES.md                            # feature catalog — what each toggle owns
├── .gitignore                             # sensible defaults
├── memory/
│   ├── README.md                          # memory architecture
│   ├── INDEX.md                           # rolling state template
│   ├── quick-reference.md                 # hot-cache template
│   ├── WORKING_DEFAULTS.md                # operating conventions
│   ├── HEARTBEAT_SPEC.md                  # heartbeat format
│   ├── heartbeat.md                       # empty starter with format header
│   ├── MEMORY_STEWARD_LAST_RUN.md         # checkpoint placeholder
│   ├── last-shutdown-snapshot.md          # cold-start anchor (template; Observer fills)
│   ├── sessions/
│   │   └── README.md                      # per-session chronicle convention
│   └── drift-reports/
│       └── README.md                      # drift-report convention
├── design/
│   ├── README.md                          # design corpus entry point
│   ├── canonical/
│   │   ├── README.md                      # canonical foundation index
│   │   ├── decisions.md                   # decision-log format (empty)
│   │   ├── implementation-plan.md         # slice template
│   │   ├── implementation-status.md       # status template
│   │   └── adrs/
│   │       └── README.md                  # ADR pattern
│   ├── features/
│   │   ├── README.md                      # 4-layer per-feature structure
│   │   └── _template/                     # scaffold for a new feature
│   │       ├── README.md
│   │       ├── build-spec.md
│   │       ├── agent-handoff.md
│   │       ├── user-stories.md
│   │       └── references.md
│   ├── process/
│   │   ├── workflow.md                    # 5-stage workflow
│   │   ├── multi-session-workflow.md      # worktree + spawn pattern
│   │   ├── operational-patterns.md        # RUNBOOK (14 entries — Entry 14 = pulse-check contract)
│   │   ├── conventions.md                 # naming + Markdown + cross-ref rules
│   │   ├── consistency-checks.md          # pre-merge QA
│   │   ├── handoff-checklist.md           # coding-agent handoff prep
│   │   ├── drift-classes.md               # 5-class drift taxonomy
│   │   ├── autonomy-gap-framework.md      # Tier 0-3 escalation
│   │   ├── agent-roles.md                 # v1.2 — 14-section role-vs-session model
│   │   ├── scripts/
│   │   │   └── wb-session.sh              # worktree toolkit
│   │   └── scheduled-tasks/
│   │       └── memory-steward-prompt.md   # steward prompt
│   ├── archive/
│   │   └── README.md                      # archive convention
│   └── references/
│       └── README.md                      # references slot
├── scripts-infra/
│   ├── cadence.sh                         # onboarding + feature toggle tool
│   └── spawn-agent.sh                     # boot script for the CLI-bootable session set
│                                          #   (Observer + Async Architect + optional Build Executor)
│                                          #   enforces agent-roles.md §7.1 full-access flag
└── handoff/
    └── notes/
        ├── README.md                      # handoff-note convention
        └── commit-requests/
            └── README.md                  # commit-request template
```

~37 files total — most are concise templates or canonical-reference docs.

### What's in agent-roles.md v1.2 (since the initial extraction)

The v1.2 role contract is the framework's load-bearing doc. It defines:

- **Sandbox boundary as structural cleavage** — Cowork sessions (synchronous-with-user) vs Codex CLI sessions (host-bound, autonomous). Roles map cleanly to one or the other.
- **Infrastructure-vs-project authority boundary** — `design/process/*`, `memory/HEARTBEAT_SPEC.md`, scripts, cron all evolve autonomously; `design/canonical/decisions.md` D-* entries, features, source code all require HITL.
- **Six roles with full contracts** — Orchestrator (Cowork/Sonnet), Sync Architect (Cowork/Opus), Async Architect (Codex CLI), Executor (3 flavors), Observer (with garden-tender synthesis loop + bounded directive authority), Memory Steward.
- **Slot model** — same human-readable label (Codex A, Codex B, Codex Build) held by different session instances over time.
- **§7 CLI-bootable session set** — Observer + Async Architect + optional Build Executor boot via `scripts-infra/spawn-agent.sh`.
- **§7.1 permission mode** — ALL Codex CLI sessions must start with `--dangerously-bypass-approvals-and-sandbox`. Framework discipline replaces per-operation approval prompts.
- **§8 cold-start recovery** — first session post-reboot does heartbeat archaeology + shutdown-snapshot check + worktree reconciliation.
- **§9 shutdown protocols** — three managed-shutdown modes (quick-break / end-of-day / full-stop) + Observer-produced shutdown snapshot at `memory/last-shutdown-snapshot.md`.
- **§10 away-but-alive mode** — infrastructure loop continues running while user is offline; project loop pauses.

If your project is small or single-developer, you can run with just the Orchestrator + Executor + Memory Steward roles and skip the autonomous loop. The framework supports incremental adoption.

---

## How to instantiate Cadence on a new project

This is a one-time customization pass. Plan ~30 minutes.

1. **Copy this directory** to your new project location:
   ```bash
   cp -R ~/Projects/cadence ~/Projects/<your-project>
   cd ~/Projects/<your-project>
   ```

2. **Choose your feature set.** Cadence is a pluggable engine — open `cadence.config.yml`
   and edit the `project:` identity block and the `features:` toggles, or drive it from the CLI:
   ```bash
   ./scripts-infra/cadence.sh status               # see what's on/off
   ./scripts-infra/cadence.sh disable observer_loop --apply
   ./scripts-infra/cadence.sh disable sync_engine  --apply
   ```
   `FEATURES.md` is the catalog — what each toggle is, the files it owns, and its dependencies.
   CORE features can't be disabled; optional ones prune their files when turned off.

3. **Customize AGENTS.md placeholders** with project-specific values. Search and replace:
   - `<PROJECT_NAME>` → your project name
   - `<GIT_HOST_URL>` → your Git host URL (Cadence defaults to GitHub)
   - `<GROUP>` → your org / group
   - `<PROJECT>` → your repo name in the host
   - `<DEVELOPER>` → primary developer / decision-maker

   These same placeholders appear in `memory/INDEX.md`, `memory/quick-reference.md`, `memory/WORKING_DEFAULTS.md`, and a handful of process docs. A single `find . -type f -name '*.md' | xargs grep -l '<PROJECT_NAME>'` pass shows all sites.

   Branching topology is project-specific and intentionally not a placeholder — the framework is agnostic. Document your team's convention (trunk-based / GitHub Flow / GitLab Flow / etc.) in `memory/WORKING_DEFAULTS.md` "Current Operating Model" once it solidifies.

4. **Customize the worktree helper.** Edit `design/process/scripts/wb-session.sh`:
   - Replace `<PROJECT_NAME>` in `WB_REPO` default and `WB_PROJECT_BASENAME` derivation. The script ships with `<PROJECT_NAME>` placeholders; `WB_PROJECT_BASENAME` is derived from `basename $WB_REPO` so once `WB_REPO` is right, worktree naming follows automatically.
   - Customize `wb-restore-all` for your standing-session list.
   - If you don't use iTerm2, replace the AppleScript block with your terminal's equivalent.

5. **Customize the memory steward prompt.** Edit `design/process/scheduled-tasks/memory-steward-prompt.md`:
   - Replace timezone (`America/Los_Angeles`) with your team's local timezone.
   - Adjust path references for any project-specific canonical docs that won't exist on day one (e.g., `code-audit.md`, `implementation-status.md`).
   - Confirm the steward's "working branch" abort guard matches your project's branching topology.

6. **Decide which canonical patterns to keep.** This starter is opinionated about *shape* (5-folder design corpus, append-only decisions, per-session chronicles, heartbeat ledger). It is not opinionated about content. Open `design/canonical/README.md` and decide which of the source content patterns fit yours (anchor patterns, entity model, rules catalog, etc.). Drop the rest from your project's `canonical/README.md`.

7. **Initialize git** and make the first signed commit:
   ```bash
   cd ~/Projects/<your-project>
   git init -b main
   git config user.signingkey <your-gpg-key>
   ./scripts-infra/cadence.sh init --apply   # prunes disabled features + sets commit.gpgsign
   git add .
   git commit -S -m "feat: initialize project from Cadence starter"
   ```

   (Don't push until you're ready — AGENTS.md "Explicit push confirmation" rule applies. If your team's topology uses a different default branch than `main`, swap it here.)

8. **Spawn your first agent session** with `AGENTS.md` as the bootstrap reference. The agent reads `AGENTS.md` §0, creates its chronicle in `memory/sessions/`, appends a `started` event to `memory/heartbeat.md`, and is ready to work.

---

## What's deliberately NOT included

This starter is the project-agnostic shape only. The following are explicitly out of scope:

- **Project code** — no `backend/`, `frontend/`, or other stack-specific source trees. Add them per your project's needs.
- **Project-specific canonical content** — no anchor patterns, no entity model, no rules catalog, no API contracts, no component library, no LLM wiring spec, no telemetry catalog. These were specific to the framework; populate your own canonical docs as your project's shape solidifies.
- **Project-specific decision log entries** — `design/canonical/decisions.md` ships with the format only, not the framework's 30+ D-* entries.
- **Project-specific persona content** — no named personas, no role-vocabulary specific to a domain.
- **Project-specific feature topics** — `design/features/` ships with the `_template/` only, no real topic folders.
- **Historical artifacts** — `design/archive/` ships empty; no migration logs, no superseded specs.
- **Session history** — `memory/sessions/` ships with the convention README only, no past chronicles.
- **Heartbeat history** — `memory/heartbeat.md` ships as a header-only starter.

---

## Provenance

Cadence is distilled from a period of empirical multi-agent operation. During that period the system:

- Operated 4-7 concurrent agent sessions across multiple worktrees.
- Surfaced 5 distinct drift classes (Classes 1-5 in `drift-classes.md`), of which Class 1 has been closed structurally.
- Accumulated 13 operational-pattern entries in the RUNBOOK from real incidents.
- Locked ~30 product decisions and 2 ADRs through the 5-stage workflow.
- Shipped 32 design slices with parallel anchor-walkthrough builds.

The shape codified here is what survived that period — what proved durable, repeatable, and worth carrying to the next project. It is not a fixed framework. Running it on a new project will surface new operational patterns, new drift classes, and new role contracts; expect the RUNBOOK + canonical decisions to grow.

---

## Maintenance philosophy

This starter is a snapshot, not a fixed framework. The expectation is:

- **`operational-patterns.md` evolves continuously.** Every new operational ambiguity that surfaces becomes a RUNBOOK PR.
- **`drift-classes.md` expands.** When a novel drift class surfaces, name it; codify the structural mitigation; close the loop.
- **`agent-roles.md` accepts new roles.** New role contracts surface as parallelism grows; add them with the §0 template.
- **`canonical/decisions.md` is append-only.** Project decisions accumulate here as a permanent record.
- **AGENTS.md stays minimal.** Only patterns that prove universally binding migrate from RUNBOOK to AGENTS.md as hard rules.

The closure loop — observe → name → mitigate → codify — is the point. The artifacts are scaffolding for that loop.

---

## Acknowledgments

The shape distilled here is the cumulative work of:

- **Anu Singh** — direction, judgment calls, the empirical pressure that surfaced the patterns.
- **Claude Sonnet + Opus (Cowork sessions)** — orchestration + reasoning-heavy architectural authorship.
- **Codex CLI** — executor sessions running anchor builds in parallel worktrees.
- **The empirical drift incidents** — the grounding for Classes 1-4 of `drift-classes.md` and many RUNBOOK entries.

---

## License

(Add a LICENSE file per your project's needs. The framework itself has no specific license requirement — adapt and use freely.)
