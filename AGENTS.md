# AGENTS.md — `cadence` Operating Contract

This file defines mandatory behavior for any agent (Codex, Claude Code, Cowork task session, or other CLI / chat-shell agent) working in this repository. Codex auto-reads this file on startup; Claude Code and Cowork sessions reach it via `CLAUDE.md` redirect.

> **Provenance.** The shape of this contract — bootstrap reading order, per-session chronicle convention, heartbeat ledger, pre-action conflict + context check, deferred set, role/session model — is distilled from empirical multi-agent operation. See `README.md` for full instantiation guide and `cadence` provenance details.

---

## §0. Bootstrap reading order — read every session

You're an agent that just spawned in this repo. Read these files in order before starting any work.

### Required reading (every session)

1. **This file (`AGENTS.md`)** — operating contract (Git workflow, branch rules, GPG signing, forbidden actions). **Never push without `Anu Singh`'s explicit approval.**
2. **`memory/quick-reference.md`** — hot cache for project shorthand: people, terms, slice IDs, drift IDs, decisions. First-stop decoder for any unknown name or acronym.
3. **`memory/INDEX.md`** — live project state, build priority queue, ownership model, recent decisions. The single rolling source of truth for "what's shipped, what's queued, where we are."
4. **`memory/README.md`** — memory architecture: how to read each memory file + when to update them.
5. **`design/README.md`** — design corpus entry point. Has reading orders for understanding the product (architecture / review / refinement work) vs implementation (feature slice pickup).
6. **`design/process/operational-patterns.md`** — RUNBOOK of emergent operational patterns. Tier 0 self-resolve reference. Read before the first action.
7. **`design/process/agent-roles.md`** — role-vs-session framework and per-role contracts (Orchestrator / Sync Architect / Async Architect / Executor / Observer / Memory Steward). Read to understand what role you are taking and how to hand off.

### For feature-specific work (when you're picking up a slice)

After the universal reads above (1-7), continue with the per-feature pickup sequence — typically `memory/INDEX.md` build progress section → `design/features/<NN-topic>/agent-handoff.md` → `build-spec.md` → `references.md` → relevant canonical anchors. See `design/README.md` for the project-specific shape.

### For architectural / review / refinement work

After the universal reads above (1-7), continue with the canonical foundation sequence — typically `design/canonical/README.md` → `decisions.md` → `design/process/workflow.md`. See `design/README.md` for the project-specific shape.

### Other context (read on demand)

- `memory/WORKING_DEFAULTS.md` — stable agent preferences/conventions.
- `memory/last-shutdown-snapshot.md` — Observer-written snapshot of state at last managed full-stop. Cold-start sessions read this first per `design/process/agent-roles.md` §8.
- `design/process/conventions.md` — naming + Markdown style + cross-reference rules.
- `design/process/consistency-checks.md` — pre-merge QA checklist.
- `design/process/drift-classes.md` — taxonomy of agentic-state drift classes (project-agnostic reference).
- `design/process/autonomy-gap-framework.md` — escalation tiers (Tier 0–3) for self-resolve vs escalate decisions.
- `cadence.config.yml` + `FEATURES.md` — the feature manifest and catalog. Cadence is a pluggable engine; this is where subsystems are activated/deactivated. Check `./scripts-infra/cadence.sh status` to see which features are live before assuming a subsystem exists.
- `scripts-infra/cadence.sh` — onboarding + feature toggle tool (`status` / `enable` / `disable` / `init` / `doctor`). Destructive ops are dry-run unless `--apply`.
- `scripts-infra/spawn-agent.sh` — boot script for the CLI-bootable session set (Observer + Async Architect + optional Build Executor), enforces `agent-roles.md` §7.1 permission-mode requirement. (Feature: `observer_loop`.)
- `handoff/notes/` — recent session handoff notes.

### After bootstrap

You're now context-ready. Take the user's prompt as the task instruction. If anything in the project state contradicts what the prompt asks, surface the conflict before acting — don't assume one or the other is right.

If `memory/INDEX.md` looks stale (last-updated date older than recent git commits), flag it but proceed with current `git log` + `INDEX.md` together as the working state.

### Per-session chronicle — REQUIRED for every session

**Required behavior, not optional.** Every Cowork session and CLI agent task creates and maintains its own chronicle file in `memory/sessions/` autonomously (no user prompt needed). Convention + format documented in `memory/README.md` §"Per-session chronicle convention".

**Step 0 — at session start (before any other work):**

Create your chronicle file:
- **Cowork sessions:** `memory/sessions/cowork-YYYY-MM-DD-<topic-slug>.md`
- **Codex CLI sessions:** `memory/sessions/codex-YYYY-MM-DD-<topic-slug>.md`
- **Claude Code CLI sessions:** `memory/sessions/claude-code-YYYY-MM-DD-<topic-slug>.md`

Where:
- Date = when this session first became active (best estimate from conversation/handoff)
- Topic slug = your starting task or focus area (kebab-case, 3-5 words)

Reconstruct topic timeline + active log retrospectively from conversation history. **Read other sessions' files first** (`ls memory/sessions/*.md`) to understand parallel context — what other agents are working on, what's been recently committed, what's pending.

**If you're a CLI agent picking up a handoff brief** (e.g., `handoff/notes/cowork_to_agent_*.md`): chronicle setup is **Step 0 of the work** — done before any code/migration/design work begins.

### Step 0.5 — Pre-action conflict + context check (REQUIRED before any first-action heartbeat event)

Before writing your first `started` event for a worktree or anchor, run:

```bash
tail -n 100 $WB_REPO/memory/heartbeat.md | grep -E "(<worktree-or-anchor-name>|<session-id>)"
```

(Where `$WB_REPO` is your absolute path to this repo; e.g., `~/Projects/cadence`.)

Inspect the results:

**Conflict-detection (Class 1 drift — worktree-claim):**
- **No matches in the last hour, OR most recent event is `closed` from any session:** safe to proceed.
- **Recent `started` event for this worktree/anchor from a DIFFERENT session-id with no subsequent `closed`:** another session has claimed this work. **ABORT.** Emit a `conflict-detected` heartbeat event referencing the other session's claim; stand by for coordination.
- **Recent `started` event from YOUR OWN session-id:** restart scenario. Emit a `resumed` event rather than duplicate `started`.

**Context-detection (Class 2 drift — operational-context):**
- Scan for `note` events targeting your session-id, worktree-name, or work scope (for example validation patterns, dependency directives, or recent operational guidance). **These are Tier 0 self-resolve signals.** Follow them; do NOT emit `blocked` events for questions answered in the heartbeat tail.
- Scan for recent `blocked` events on similar work indicating known issues; incorporate them as context before acting.

This check pairs with:
- `.wb-owner` canary file enforced by `wb-spawn` (`design/process/scripts/wb-session.sh`) — directory-level collisions
- `design/process/operational-patterns.md` — emergent operational conventions
- `design/process/drift-classes.md` — full drift taxonomy

**During session:** append timestamped entries to active log as work progresses. On topic shift: add new row to topic timeline + new dated section to active log + update `Current topic` header.

**At session close (or pause):** finalize Outcomes + State at last update. Mark Status appropriately.

Each session owns its own file (no write conflicts across parallel sessions). The chronicle is how the team reconstructs project timeline if coherence breaks across sessions — your maintenance is non-negotiable.

**Worktree identity — confirm placement.** This project may use per-session git worktrees. If a multi-session workflow is in effect, every CLI session operates in its own dedicated task worktree, not the main worktree. If your spawn prompt specifies a worktree path (e.g. `~/Projects/cadence-<slug>`), `cd` there now and confirm with `git branch --show-current`. **If no worktree was pre-created for you, STOP** — do not work in the main worktree. Surface to the design session; it will run `wb-task <slug>` on the host to create your worktree and provide the path. Convention reference: `design/process/multi-session-workflow.md`.

**Cross-session awareness — heartbeat ledger.** After creating your session chronicle (per the chronicle convention above), tail the heartbeat to surface recent cross-session state:

```bash
tail -n 20 $WB_REPO/memory/heartbeat.md
```

Then append a `started` event line to the heartbeat with a ref to your chronicle:

```bash
echo "$(TZ=America/Los_Angeles date '+%Y-%m-%dT%H:%M:%S%z') | <session-id> | started | <one-line-task> | chronicle:<your-chronicle-filename>" >> $WB_REPO/memory/heartbeat.md
```

Append additional events on `milestone` (significant progress), `blocked` (waiting on external), `interrupt` (urgent user attention), or `closed` (session done). Full convention spec at `memory/HEARTBEAT_SPEC.md`.

> **Timezone note.** The default `TZ=America/Los_Angeles` above is the convention `cadence` set as the framework default. Override to your team's local timezone if different — but pick one and use it consistently so timestamps from all sessions align on the same calendar day.

---

## Repository

- **Git host:** GitHub — `https://github.com/anufoodie/cadence`
- **Default branch:** `main`
- **Working branch:** `anu-singh` (developer branch; integrate to `main` via PR)

## Git Workflow

The framework is agnostic about branching topology — adapt the section below to your team's convention (GitHub Flow, GitLab Flow, trunk-based, etc.). What it does require:

1. **Never push directly to shared / protected branches** (`main`, `staging`, `production`, or whatever your project uses). All changes reach those branches through merge / pull requests.
2. **GPG-signed commits required.** Keep commit signing enabled in your Git config (`git config commit.gpgsign true`).
3. **Explicit push confirmation.** Never push to any remote until the user explicitly confirms they are ready.
4. **Signed merges and path-restricted staging** when working in worktrees (see `design/process/operational-patterns.md` §4 commit discipline).

The starter ships with the assumption that commits land on `main` in early-stage projects. If your team uses long-lived developer branches, feature branches, or a more elaborate topology, document the project-specific convention in `memory/WORKING_DEFAULTS.md` and adapt the daily sequence below.

### Daily Sequence (early-stage / trunk-based default — adapt as needed)

```bash
git checkout main
git pull origin main
# ... do work ...
git add <files>
git status --short
git commit -S -m "Describe the change"
# Open a GitHub PR when ready; do not push until the user confirms.
```

## Repository Structure

```
cadence/
├── README.md            # framework provenance + instantiation guide
├── AGENTS.md            # this file — operating contract
├── CLAUDE.md            # thin redirect to AGENTS.md
├── cadence.config.yml   # feature manifest — which subsystems are active
├── FEATURES.md          # feature catalog — what each toggle does + its files
├── scripts-infra/
│   └── cadence.sh       # onboarding + feature toggle tool
├── design/
│   ├── canonical/       # horizontal foundation — decisions, ADRs,
│   │                    # implementation plan + status, project-specific
│   │                    # spec content (anchor patterns, entity model,
│   │                    # rules catalog, etc. — populate per project shape)
│   ├── features/        # vertical deep-dives — 4-layer per-feature
│   │                    # structure (user-stories / build-spec /
│   │                    # agent-handoff / references)
│   ├── process/         # operating manual — workflow, conventions,
│   │                    # operational-patterns (RUNBOOK), drift-classes,
│   │                    # autonomy-gap-framework, agent-roles, scripts/,
│   │                    # scheduled-tasks/
│   ├── archive/         # historical artifacts (read-only)
│   └── references/      # supporting material — glossary, idea registers
├── handoff/
│   └── notes/           # recent session handoff notes + commit-requests/
└── memory/              # rolling project state — INDEX.md, quick-reference,
                         # heartbeat, sessions/, drift-reports/
```

Project-specific source trees (e.g., `backend/`, `frontend/`, `scripts/`) sit alongside `design/`, `memory/`, `handoff/` as your stack requires. The list above documents the framework-provided slots; add your stack-specific slots as needed and document them here as the project takes shape.

## Non-Negotiable Rules

1. Follow the Git workflow for all Git operations.
2. Never commit secrets, credentials, or `.env` files.
3. Keep all design decisions in versioned markdown under `design/`.
4. Preserve handoff notes for session continuity.
5. Do not delete or overwrite existing handoff notes.

## Forbidden Actions

1. No direct push to `main`, `staging`, or `production`.
2. No force-push or history rewrite on shared branches.
3. No deletion of handoff notes or implementation journal entries.
4. No bypass of GPG signing.
5. **No staging, modifying, or committing files in the Deferred set** (see below). If your work makes you want to touch a deferred path, STOP and surface to `Anu Singh` as a scope question.
6. No bypassing Step 0.5 pre-action conflict + context check. Skipping the `tail -n 100` heartbeat read is the same severity as skipping `git status --short` before commit.

## Deferred set (out-of-scope by default — do not touch)

Some folders and files are tracked-pending-decision: the maintainer has not yet decided whether to commit, archive, gitignore, or rework them. **Agents must not stage, modify, commit, or `git add` anything in the Deferred set.** They may be READ for reference, but never written to.

**This list is project-specific and starts empty.** Populate it as your project accumulates undecided artifacts (e.g., experimental scripts, third-party drops, generated outputs awaiting curation, work-in-flight pending a fork decision).

Example format:

```
Folders (whole-folder deferred):
- <path>/  — <why deferred, who decides>

Files (root-level):
- <path>  — <why deferred>
```

**What agents do if their work intersects:** STOP, write a one-line note in your chronicle ("encountered deferred path X while doing Y; halting"), and surface to `Anu Singh`. Do not stage, do not modify, do not "fix while I'm here."

**What this protects against:** scripts that walk the index (e.g., GPG self-checks, bulk `git add` patterns) accidentally capturing deferred files into commits or orphan branches.

**When the maintainer decides:** an entry will be added to `design/canonical/decisions.md` and the relevant folder/file will be removed from this section.

---

## Instantiation record

This Cadence instance was instantiated on 2026-05-11. Placeholders replaced:

| Placeholder | Replaced with |
|---|---|
| `<PROJECT_NAME>` | `cadence` |
| `<DEVELOPER>` | `Anu Singh` |
| `<ARCHITECT_ROLE>` | `Sync Architect (Cowork/Opus)` (used in `memory/INDEX.md` Ownership Model) |
| `<GIT_HOST_URL>` / `<GROUP>` / `<PROJECT>` | GitHub — `https://github.com/anufoodie/cadence` (`anufoodie` / `cadence`) |

For instructions on forking this repo into a new project, see `README.md` "How to instantiate Cadence on a new project".
