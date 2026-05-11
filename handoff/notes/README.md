# handoff/notes/

Session handoff briefs between agents, between sessions, and between agent ↔ human.

**Status:** Empty. Populate as handoffs accumulate.

---

## Filename convention

```
<author>_to_<target>_YYYY-MM-DD-<topic-slug>.md
```

Where:
- **`<author>`** — short identifier for the originating session or role (e.g., `cowork`, `codex`, `design-opus`, `observer-codex`).
- **`<target>`** — short identifier for the target session, role, or agent (e.g., `cowork`, `codex`, `agent`, `anu` for the user).
- **`<topic-slug>`** — kebab-case topic identifier (3-5 words).

Examples:
- `cowork_to_agent_2026-05-04-wiki-mvc-build.md` — Cowork orchestrator handing build work to a CLI agent.
- `cowork_to_cowork_YYYY-MM-DD-extract-workflow-architecture.md` — one Cowork session handing scope to another.
- `opus_to_cowork_YYYY-MM-DD-autonomy-gap-analysis.md` — architect (Opus) responding to orchestrator (Sonnet).
- `codex_recon_<project>_2026-05-08.md` — recon-style brief with discovery output.

## What a handoff brief contains

Adapt to your need; the framework's briefs commonly include:

1. **Header** — authored by, date, target executor, source artifact, scope.
2. **Why this exists** — context and motivation.
3. **What's in scope** — explicit list of files/work the executor should touch.
4. **What's out of scope** — explicit list of files/work to leave alone.
5. **Execution sequence** — step-by-step instructions.
6. **Success criteria** — what proves the work complete.
7. **Open questions** — anything that the executor should flag rather than decide unilaterally.
8. **Cross-references** — pointers to related chronicles, commits, decisions.

## Outcome / closeout blocks

When the work the brief authorizes lands, append an `## Outcomes` or `## Closeout` section with:

- Commit hashes that landed.
- Decisions that were taken (with D-* entries if applicable).
- Open follow-ups.

The memory steward flags handoff briefs missing outcome blocks for landed work as `MISSING_HANDOFF_OUTCOMES` drift.

## Subfolders

- **`commit-requests/`** — commit-request artifacts (a specific type of handoff brief; see that folder's README).

## Preservation rule

**Never delete a handoff brief** (AGENTS.md Forbidden Actions §3). Old briefs stay for archaeology and are git-traceable.
