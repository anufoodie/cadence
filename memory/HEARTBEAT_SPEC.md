# Heartbeat — cross-session awareness ledger

**File:** `memory/heartbeat.md` (this directory).
**Path from any worktree:** `$WB_REPO/memory/heartbeat.md` — use the absolute path; the heartbeat is a single source of truth across all worktrees.
**Time zone:** all timestamps in your team's chosen local timezone (Pacific in the framework default). Format includes UTC offset for DST resilience.

## Why

Multiple parallel sessions (commit/build, recon, design, IDE-CLI, ad-hoc) operate across worktrees on the same machine. Reading another session's full chronicle to learn its current state is expensive (file size + scrolling). The heartbeat is a single, append-only file giving every session a quick-glance view of recent cross-session state changes.

This is **operational metadata** — not canonical, not a substitute for chronicles or `decisions.md`. It is an index + recency signal, nothing more.

## Format

One event per line, pipe-delimited:

```text
TIMESTAMP | SESSION_ID | EVENT_TYPE | ONE_LINE_SUMMARY | REFS
```

### Field specification

- **TIMESTAMP** — ISO-8601 in your team's local timezone with UTC offset. Example: `2026-05-08T15:30:00-0700`. Generate via:
  ```bash
  TZ=America/Los_Angeles date "+%Y-%m-%dT%H:%M:%S%z"
  ```
  (Substitute your team's `TZ` value.)
- **SESSION_ID** — short canonical name. See "Session IDs" below.
- **EVENT_TYPE** — one of the closed set below.
- **ONE_LINE_SUMMARY** — human-readable; ≤120 chars; no pipe characters.
- **REFS** — space-separated `key:value` pairs pointing at detail. Optional but encouraged.

### Event types (closed set)

| Event | When to use |
|---|---|
| `started` | Session begins (after AGENTS.md §0 bootstrap completes) |
| `resumed` | Session restarts after a pause or stale-cwd recovery |
| `milestone` | Significant progress — output produced, sub-task complete, decision reached, review surface ready |
| `note` | Informational broadcast — no action requested; provides context for other sessions |
| `blocked` | Waiting on external dependency (user input, another session's output, third-party) |
| `interrupt` | Needs user attention now (urgent commit-request, scope conflict surfaced) |
| `closed` | Session ending — chronicle Outcomes appended |

### Session IDs (project-specific; populate per project shape)

Conventions used (illustrative):

| ID | Role |
|---|---|
| `design` | Strategist / decision-author session |
| `session-1` / `session-2` / ... | Numbered persistent role slots (commit/build, recon, etc.) |
| `<agent>-YYYY-MM-DD-<topic>` | Per-task CLI sessions (often equals chronicle filename minus `.md`) |
| `<role-name>` | Ad-hoc spawns; pick a short descriptive name |

Populate `memory/quick-reference.md` "People & Sessions" or equivalent with this project's specific role/session-id table.

### Refs format

Space-separated `key:value`. Recognized keys:

- `chronicle:<filename>` — session's chronicle in `memory/sessions/`
- `output:<path>` — produced file (markdown, dossier, etc.)
- `commit:<hash>` — landed git commit
- `task:<id>` — TodoList task identifier
- `brief:<filename>` — handoff brief
- `commit-request:<filename>` — commit-request artifact in `handoff/notes/commit-requests/`
- `decision:<id>` — decision-log entry
- `target:<session-id-or-all>` — routing hint to a specific session or broadcast

Multiple refs on one line: `chronicle:foo.md output:bar.md commit:abc123`.

## Write discipline

Append one line on each lifecycle event listed above. Single shell idiom (works in any worktree):

```bash
echo "$(TZ=America/Los_Angeles date '+%Y-%m-%dT%H:%M:%S%z') | <session-id> | milestone | <summary> | <refs>" >> $WB_REPO/memory/heartbeat.md
```

### Resilience properties

- **Atomic append.** POSIX guarantees writes ≤ PIPE_BUF (typically 4 KB) via `>>` are atomic; collisions between sessions don't corrupt entries. Each event line is well under 4 KB.
- **Single absolute path.** Sessions in any worktree write to the same file; no worktree-local divergence.
- **Idempotent.** Repeating an event line is harmless (duplicate detection unnecessary at our scale).
- **Tolerant of missing file.** If `memory/heartbeat.md` doesn't exist, `>>` creates it.
- **Format-drift tolerant.** Parsers should treat missing optional fields as empty; pipe-delimited form is robust to extra whitespace.
- **No flock needed.** Event rate (~25 events/day across all sessions at small-team scale) is far below any contention threshold.

## Read discipline

At session start (after AGENTS.md §0 bootstrap), tail the heartbeat to see recent activity:

```bash
tail -n 20 $WB_REPO/memory/heartbeat.md
```

For Step 0.5 pre-action conflict + context check, use a deeper tail:

```bash
tail -n 100 $WB_REPO/memory/heartbeat.md | grep -E "(<worktree-or-anchor-name>|<session-id>)"
```

To find specific session activity:

```bash
grep -E "\| <session-id> \|" $WB_REPO/memory/heartbeat.md | tail -n 10
```

To find recent outputs:

```bash
grep -E "\| (milestone|closed) \|" $WB_REPO/memory/heartbeat.md | grep -E "output:" | tail -n 10
```

To find blockers:

```bash
grep -E "\| blocked \|" $WB_REPO/memory/heartbeat.md | tail -n 10
```

## Maintenance

Memory steward sweeps the heartbeat on its weekly archival pass (see `design/process/scheduled-tasks/memory-steward-prompt.md` §12):

- Entries older than 7 days move to `memory/heartbeat-archive/<YYYY-WW>.md` (ISO week format).
- Live heartbeat stays under ~200 lines for fast tail/grep.
- Archive files are git-tracked for historical retrieval.
- Archival commits are signed, path-restricted, and on the steward's normal cadence — not its own commit per archive event.

## Bootstrapping a new session — full order

1. Read `AGENTS.md` §0.
2. Create chronicle at `memory/sessions/<id>-<date>-<topic>.md` per AGENTS convention.
3. Tail the heartbeat:
   ```bash
   tail -n 20 $WB_REPO/memory/heartbeat.md
   ```
   Surface recent cross-session state before doing other bootstrap reading.
4. Run Step 0.5 pre-action conflict + context check (`tail -n 100 | grep`).
5. Append `started` event to heartbeat with chronicle ref:
   ```bash
   echo "$(TZ=America/Los_Angeles date '+%Y-%m-%dT%H:%M:%S%z') | <session-id> | started | <one-line-task> | chronicle:<your-chronicle-filename>" >> $WB_REPO/memory/heartbeat.md
   ```
6. Continue with task-specific bootstrap (read brief, etc.).

## Anti-patterns

- **Don't put full content in the heartbeat.** It is an index, not the data. Detail belongs in chronicles + outputs.
- **Don't write more than necessary.** Routine progress doesn't warrant entries. Use `milestone` for things other sessions actually need to know about.
- **Don't read the whole file.** `tail` + `grep` is the access pattern. Reading hundreds of lines means you're using it wrong.
- **Don't manually edit past entries.** Append-only. Memory steward archives; do not curate by hand.
- **Don't use the heartbeat for two-way messaging.** It is a state-broadcast ledger, not an inbox/outbox. If session A needs session B to do something, route through the user (commit-request, prompt, etc.) — or emit a `note` with the question and a default-action plan and proceed if no contradiction lands within the stated window.

## Cross-references

- `memory/README.md` — chronicle conventions.
- `AGENTS.md` §0 — agent bootstrap including this heartbeat step.
- `design/process/operational-patterns.md` — RUNBOOK with heartbeat-append idiom (Entry 5) and heartbeat-tail-on-start discipline (Entry 10).
- `design/process/drift-classes.md` — 5-class taxonomy of drift the heartbeat helps detect.
- `design/process/autonomy-gap-framework.md` — Tier 0–3 escalation model using heartbeat events.
- `design/process/scheduled-tasks/memory-steward-prompt.md` §12 — weekly archival pass.
