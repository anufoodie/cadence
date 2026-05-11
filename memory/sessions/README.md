# memory/sessions/

Per-session live logs. One file per chat thread / CLI task / scheduled-task run.

**Convention + format documented in `../README.md` §"Per-session chronicle convention".**

## Filename format

```
<agent-prefix>-YYYY-MM-DD-<topic-slug>.md
```

Where `<agent-prefix>` is one of:
- `cowork` — Cowork chat sessions
- `codex` — Codex CLI sessions
- `claude-code` — Claude Code CLI sessions
- `steward` — scheduled memory steward runs
- `design` — strategist / architect sessions (if used as a distinct slot)

Add new prefixes as new agent types join the project. Document them in `memory/quick-reference.md` Agents table.

## Lifecycle

1. **Session start:** agent creates its chronicle here (Step 0 per AGENTS.md §0).
2. **During session:** agent appends timestamped entries autonomously.
3. **Session close:** agent finalizes Outcomes + State at last update; flips Status to `closed` (or leaves as `active` for Cowork sessions that may resume).
4. **Archival:** the memory steward weekly archives eligible files to `archive/<year>/` per `design/process/scheduled-tasks/memory-steward-prompt.md` §11. Cowork chronicles are never auto-archived.

## Read pattern

Cross-session timeline reconstruction:

```bash
ls *.md | sort
# Each file = one session log; read in date order = full timeline
```

Single date across all sessions:

```bash
grep -A 5 "### 2026-05-03" *.md
```

## Active vs closed

`Status: active` is durable — Cowork sessions persist across long quiet stretches by design. The memory steward does NOT flag active chronicles as stale based on log-entry recency alone. See `../README.md` §"Status field semantics" for the full rationale.
