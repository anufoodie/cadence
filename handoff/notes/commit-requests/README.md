# handoff/notes/commit-requests/

Commit-request artifacts. A specific type of handoff brief that asks an executor to land specific files with a specific commit message.

**Status:** Empty. Populate as commit-requests accumulate.

---

## When to use a commit-request

When the work has been fully designed/decided by one agent (often Cowork or an architect session) but landing it requires a path-restricted signed commit by another agent (often Codex or a Claude Code session with a working GPG signing setup) — for example:

- Architecture sessions running in sandboxes that can't sign locally.
- Multi-agent coordination where the deciding agent isn't the executing agent.
- Work that requires deliberate path restriction to avoid sweeping in concurrent WIP.

## Filename convention

```
YYYY-MM-DD-<topic-slug>.md
```

Examples:
- `YYYY-MM-DD-port-allocation-runbook-entry-13.md`
- `2026-05-08-T117-steward-section-1-path-restrict-and-section-11-archival.md`

(Task-tracker IDs can be embedded in the slug for traceability.)

## Standard structure

```markdown
# Commit request — <T# if applicable> — <one-line summary>

**Requested by:** <originating session / chronicle path>
**Reason for delegation:** <why this isn't being landed by the requesting agent>
**Target executor:** <name or any-session-with-signing>
**Tracking:** <task ID / ticket ID, if applicable>

## Files to commit

| Path | Change | Notes |
|---|---|---|
| ... | Modified / New | ... |

## Path restriction (CRITICAL)

Commit must be path-restricted to avoid sweeping in unrelated WIP:

```bash
git add -- <path1> <path2>
git commit -S -m "<message>" -- <path1> <path2>
```

## Suggested commit message

```
type(scope): subject line

Body paragraph 1 explaining the change.

Body paragraph 2 with rationale or supersession info.

Closes <task-id> if applicable.
```

## Validation before commit

Any checks the executor should run before committing (build, typecheck, targeted tests, etc.).

## Validation after commit

Any post-commit checks (verify staged paths match, verify signed status, etc.).

## Cross-references

- Originating chronicle: `memory/sessions/<filename>.md`
- Related decisions: `D-*` entries in `design/canonical/decisions.md`
- Related RUNBOOK entries: `design/process/operational-patterns.md` §N
```

## Lifecycle

1. **Requesting agent** authors the commit-request and emits a heartbeat `note` or `milestone` event referencing the artifact.
2. **Executing agent** picks up the request (often via `target:<session-id>` heartbeat routing), validates path restriction is achievable, runs pre-commit checks, lands the signed commit.
3. **Executing agent** emits a heartbeat `milestone` or `closed` event with the commit hash.
4. **Requesting agent** observes the close event and proceeds with downstream work.

## See also

- `../README.md` — broader handoff-note convention.
- `../../../design/process/operational-patterns.md` §4 — commit discipline (path-restricted staging).
- `../../../AGENTS.md` Forbidden Actions §1 — no direct push; commit-requests stop at commit, never push.
