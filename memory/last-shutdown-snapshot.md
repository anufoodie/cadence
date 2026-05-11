# Managed Shutdown Snapshot

_No managed shutdown has occurred yet. Observer writes this file on full-stop shutdowns per `design/process/agent-roles.md` §9. Cold-start sessions read it as the first artifact post-reboot per §8._

---

## Template (Observer fills this on first full-stop)

```markdown
# Managed Shutdown Snapshot

**Generated:** <ISO timestamp>
**Shutdown type:** full-stop
**Reason:** <reason from user's shutdown-request>
**Heartbeat refs:** <heartbeat event timestamps triggering shutdown>

## Active sessions at shutdown

- **Observer / current session:** executing final synthesis pass, writing this snapshot, then emitting `closed`. No further pickup.
- **<session-id>:** role=<role>, slot=<slot>, chronicle=<path>, final state=<state>, worktree=<path-if-any>, last commit=<sha>

## Worktrees at shutdown

```text
<worktree path>           <HEAD-sha> [<branch>]
<worktree path>-<task>    <HEAD-sha> [<branch>]
```

No active task worktrees were present.
(— OR list the active task worktrees with their HEADs.)

## Repo state at shutdown

- **Main worktree:** <path>
- **Branch:** <project's default/integration branch>
- **HEAD:** <sha> <one-line commit message>
- **Recent commits:**
  - <sha> <one-line message>
  - ...
- **Dirty tracked files before this snapshot:**
  - <path>
  - ...
- **Untracked notable files/folders:** <list significant untracked artifacts>

## Servers at shutdown

Canonical long-lived servers (the user's reviewer surface):

```text
127.0.0.1:<port>  <process>  pid <pid>
...
```

Task-worktree validation listeners observed in the task-validation ranges:
<none / list>

## Pending queue / next cold start

1. Bring up the replacement §7.1-compliant agent set using `scripts-infra/spawn-agent.sh --with-build` or the current equivalent full-access startup path.
2. New Observer should cold-start from this snapshot, then tail the last 200 heartbeat events, reconcile worktrees, and verify canonical servers.
3. <Any specific pending commit-requests, queued work, or paused threads worth surfacing.>
4. <Drift / bloat scan output if available.>
5. Push gates remain in force; no push.

## Risks / watch items

- <Any modified files that should be approached carefully.>
- <Any stale-base or merge-back risks.>
- <Untracked infrastructure files added since last commit.>
- <Anything the next cold-start session needs to know about.>
```

---

## When this gets written

Observer's `shutdown-behavior` for `shutdown-request (full-stop)`, per `agent-roles.md` §5 Observer + §9 shutdown protocols:

> Complete current polling cycle; run ONE final synthesis pass; **produce shutdown snapshot**; emit `closed`. **Critical role at shutdown — Observer's snapshot is the bridge to next cold-start.**

## How it's read

First session up post-reboot reads this file per `agent-roles.md` §8 cold-start recovery protocol step 2:

```bash
test -f memory/last-shutdown-snapshot.md && cat memory/last-shutdown-snapshot.md
# If present and recent (<30 days): managed-shutdown recovery; read snapshot for state.
# If absent OR stale: unmanaged-shutdown recovery; proceed to step 3-5.
```

## Maintenance

- **Replaced each managed shutdown.** Not append-only; the most recent shutdown overwrites prior content. Prior shutdown state lives in heartbeat-archive + chronicles.
- **Sensitive content:** snapshot may include process PIDs, port numbers, file paths. Keep `.git` excluded from any sync target that could leak host state.

## See also

- `../design/process/agent-roles.md` §8 cold-start recovery, §9 shutdown protocols.
- `../design/process/operational-patterns.md` §2 stale-cwd recovery (a related recovery pattern).
- `HEARTBEAT_SPEC.md` — the heartbeat ledger this file complements.
