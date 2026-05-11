# Working Defaults

**Purpose:** Lightweight default operating behavior for `Anu Singh` and the agent team (Cowork, Codex, Claude Code, etc.).
**Status:** Draft operational default — evolve as this project's specific norms surface.
**Audience:** User first, then agents.

## Core Intent

This file exists so the team does not need to re-decide the same operational questions every session.

The goal is not to create process overhead. The goal is to make good collaboration happen by default.

## Current Operating Model

- `cadence` is the single consolidated repo for specs, design, and code.
- Git host: _(remote not yet configured — set when first remote is added)_
- Branching topology: working branch `anu-singh` (developer branch). Carries day-to-day commits; integration to `main` goes through merge/PR. Framework is otherwise agnostic — common patterns include trunk-based (commits land on `main`), GitHub Flow (short-lived feature branches), or GitLab Flow (long-lived per-developer branches with environment branches). See `../AGENTS.md` "Git Workflow" for the framework-level requirements that apply regardless of topology.
- Cowork (or your orchestrator agent) primarily maintains planning, design, architecture, and canonical context.
- Coding agents primarily maintain active execution state, runtime assumptions, and implementation checkpoints.
- The user is the final decision-maker on priorities, product direction, and cross-agent alignment.

## Default Behavior For CLI Agents (Codex, Claude Code, etc.)

Unless told otherwise, a CLI agent should do the following automatically:

1. When starting or resuming work in a worktree:
   - read the local chronicle if present
   - read AGENTS.md §0 bootstrap reading order
   - reconstruct the last known runnable state before making assumptions

2. When runtime assumptions are confirmed:
   - record the run command
   - record the expected URL/port
   - reuse that convention unless it stops working

3. When a meaningful implementation pass is completed:
   - append a short note to the per-session chronicle
   - promote only stable milestones into canonical memory (INDEX.md / decisions.md)
   - heartbeat-emit `milestone` if cross-session relevance is non-zero

4. Before a commit or handoff:
   - prepare a concise recovery/handoff summary
   - separate planning context from execution context

5. During unstable exploratory work:
   - keep active scratch state local to the worktree
   - avoid promoting noise into canonical memory

## Memory Model

### Canonical Memory

Lives in `memory/` and is intended to survive session switches, interruptions, and crashes.

Examples:
- `memory/INDEX.md` — master checkpoint and build progress
- `memory/WORKING_DEFAULTS.md` — this file
- `memory/HEARTBEAT_SPEC.md` — heartbeat format spec
- `memory/heartbeat.md` — live event ledger

### Session-Local Memory

For immediate recovery and active execution loops. May live in handoff notes or per-session chronicles.

Examples:
- `memory/sessions/<agent>-YYYY-MM-DD-<topic>.md` — per-session chronicle
- `handoff/notes/<author>_to_<target>_YYYY-MM-DD-<topic>.md` — handoff brief

### Per-Session Chronicle

Every Cowork session and CLI agent task autonomously maintains its own chronicle file in `memory/sessions/`. **Convention + format documented in `memory/README.md` §"Per-session chronicle convention".**

Behavior:
- **Session start (first time):** create chronicle file; reconstruct topic timeline + active log retrospectively from conversation history; read other sessions' files for parallel context.
- **During session:** append timestamped entries as work progresses; on topic shift, add row to topic timeline + new dated section to active log.
- **Session close (or pause):** finalize Outcomes + State at last update; mark Status appropriately.

Each session owns its own file — no write conflicts across parallel sessions. Cross-session timeline reconstructable by reading all `memory/sessions/*.md` files in date order.

## Decision Ownership Model

(Adapt this section to your team's roles. Suggested default categories:)

- `P-OWNED` = product/workflow decision, owned by the product/architect lead
- `T-OWNED` = technical/non-functional/architecture decision, owned by tech lead
- `JOINT` = requires alignment between multiple owners
- `EXEC` = a CLI executor can proceed without escalation
- `DOC` = the orchestrator/design session consolidates or formalizes

## Handoff Defaults

When a real handoff is needed, the minimum useful packet should answer:

1. What is the objective?
2. Which worktree/branch should be used?
3. What command runs the app (or the work)?
4. What URL/port should be used (if applicable)?
5. What is stable?
6. What is still moving?
7. Which files are in scope?
8. Which files should be avoided?
9. Which docs govern the work?
10. What does done look like?

## Anti-Complexity Rules

- Do not rely on chat memory as the only recovery mechanism.
- Do not let runtime assumptions remain implicit.
- Do not let architecture decisions silently drift inside implementation work.
- Do not let product behavior silently drift inside technical work.
- Do not hand collaborators a moving target without a documented checkpoint.

## Practical Default Commands

When appropriate and already validated for the active worktree, record commands in canonical or per-session state files in this style:

```bash
cd /absolute/path/to/worktree/<app>
PORT=<port> <run-command>
```

If a worktree depends on shared dependencies or environment quirks, record that explicitly once and reuse it.

## Status

This file is intentionally short and operational. It is not the final collaboration protocol. It is the default behavior the team can follow now, and formalize later as roles solidify.

*Instantiated for `cadence` on 2026-05-11. For instantiation guidance when forking into a new project, see `../README.md` "How to instantiate Cadence on a new project". Drop the Decision Ownership Model section if your team isn't ready to formalize ownership; add stack-specific operational notes as they emerge.*
