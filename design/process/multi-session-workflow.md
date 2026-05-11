# Multi-session workflow — worktrees, roles, and spawn pattern

**Purpose:** Canonical reference for operating multiple agent CLI sessions concurrently against this repository.

**Pairs with:** `../../memory/HEARTBEAT_SPEC.md` (cross-session awareness ledger) and `agent-roles.md` (role-vs-session model). The heartbeat is the runtime signal layer; role contracts are the durable identity layer; this doc is the worktree-isolation layer.

## Why multi-session, why worktrees

This project may run several agent CLI sessions in parallel — a strategist session, a commit/build agent, recon agents, an IDE-integrated agent, and ad-hoc spawns for ideation, testing, QA, or other focused work. When all sessions operate in the same working directory, they collide on git internals (`index.lock`, `HEAD.lock`, staging area). One agent's mid-flight WIP can be auto-captured by another agent's commit. Concurrent staging is fragile.

**Worktrees solve this.** A git worktree is a separate working-directory checkout sharing the same `.git/` object store. Each worktree has its own working files, its own staging index, and its own HEAD. Modern git (>=2.5) tracks index per worktree; concurrent staging in different worktrees does not contend.

Default layout (adapt per project):

```text
~/Projects/
  cadence/                    # main worktree — design / strategist session
  cadence-session1/           # commit/build agent
  cadence-session2/           # recon agent (sandbox)
  cadence-ide/                # IDE-integrated CLI session
  cadence-<role>/             # ad-hoc role spawns (QA, testing, etc.)
```

All worktrees point to the same `.git/` (single object store on disk); each agent edits files only in its own directory.

## Canonical session IDs and roles

| Session ID | Role | Worktree | Default branch |
|---|---|---|---|
| `design` | Strategist / decision-author session | main (`cadence/`) | `main` |
| `session-1` | Commit/build agent | `cadence-session1/` | `session-1-commit-build` |
| `session-2` | Recon agent (sandbox-mode) | `cadence-session2/` | `session-2-recon-sandbox` |
| `ide` | IDE-integrated CLI session | `cadence-ide/` | `ide-session` |

**Adding a new role:**

1. Append a row to the table above with the canonical session ID, role description, worktree path, and default branch.
2. Append the same session ID to `../../memory/HEARTBEAT_SPEC.md` "Session IDs" table.
3. Document the new role in `agent-roles.md` if it warrants a durable role contract.
4. Run `wb-spawn <session-id> --role="<role-description>"` (see Helper script below).

## Helper script (`wb-session.sh`)

The helper script lives at `scripts/wb-session.sh` (committed) and is symlinked into `~/bin/wb-session.sh` (host-side, sourced from shell rc). It provides:

- `wb-spawn <name> [--role=<role>] [--branch=<branch>] [--label=<label>]` — create worktree if missing, open labeled iTerm2 tab, cd into worktree
- `wb-list` — list all active worktrees
- `wb-path <name>` — print the absolute path of a named worktree
- `wb-remove <name>` — remove a worktree (after work merged)
- `wb-task <slug>` — create a task-specific worktree (most common path for per-anchor work)
- `wb-relabel-current "<label>"` — relabel current tab + persist
- `wb-restore-label` — auto-restore label on shell startup
- `wb-restore-all` — re-spawn standing tabs after iTerm2 launches

Setup:

```bash
# One-time symlink (after the script is committed in repo):
ln -s $WB_REPO/design/process/scripts/wb-session.sh ~/bin/wb-session.sh
chmod +x $WB_REPO/design/process/scripts/wb-session.sh

# One-time shell-rc source (in ~/.zshrc or ~/.bashrc):
echo 'source ~/bin/wb-session.sh' >> ~/.zshrc
echo 'wb-restore-label' >> ~/.zshrc   # auto-restore tab label on shell startup
source ~/.zshrc
```

The script parameterizes via env vars:

- `WB_REPO` — absolute path to your main worktree (default: `$HOME/Projects/cadence`)
- `WB_WORKTREE_BASE` — parent directory for task worktrees (default: `$HOME/Projects`)
- `WB_LABEL_DIR` — where per-worktree labels are persisted (default: `$HOME/.config/wb/labels`)
- `WB_SESSION_ID` — stable session identifier for `.wb-owner` canary (recommended set per-task; falls back to `$HOSTNAME-$$`)

> **Source project specifics.** The script ships with worktree-name prefix `cadence-` baked in (see the source line that constructs `worktree_basename="cadence-$name"`). When instantiating this starter kit, edit `scripts/wb-session.sh` to substitute your `cadence` for the framework throughout, then re-symlink.

## Spawning a new session

For a known canonical role (e.g., session-1):

```bash
wb-spawn session1 --role="Session 1 (commit/build)"
```

For an ad-hoc role:

```bash
wb-spawn qa-1 --role="QA / Testing"
wb-spawn explore-feature-x --role="Ad-hoc"
```

For a per-task Codex / Claude Code worktree:

```bash
export WB_SESSION_ID=codex-YYYY-MM-DD-some-task
wb-task some-task --desc "Some task description"
```

Each call creates a worktree on a new branch (named the same as the session ID by default), opens a fresh iTerm2 tab labeled with the role, cd's into the worktree, and prints the worktree path + branch. The user then launches their CLI of choice (codex, claude-code, etc.) in the new tab.

## Worktree ownership canary

`wb-spawn` writes a `.wb-owner` canary file into every task worktree. The file prevents two sessions from silently sharing the same worktree when `wb-spawn` is called twice with the same name.

The canary records:

```text
session_id: <WB_SESSION_ID or host-pid fallback>
claimed_at: <timestamp with UTC offset>
worktree: <name>
branch: <branch>
created_via: <wb-spawn or raw-git-add>
```

Set `WB_SESSION_ID` before spawning when possible:

```bash
export WB_SESSION_ID=codex-YYYY-MM-DD-feature-x
wb-task feature-x --desc "Feature X build"
```

If `WB_SESSION_ID` is not set, `wb-spawn` falls back to `HOSTNAME-$$` so same-shell restarts can continue but different shells are treated as different sessions.

`wb-spawn` handles three ownership states:

- **NEW** — worktree directory does not exist. `wb-spawn` creates it, writes `.wb-owner`, writes the tab label, and continues.
- **OWNED-BY-ME** — worktree exists and `.wb-owner` has the same `session_id`. This is a restart or same-session continuation. `wb-spawn` refreshes `claimed_at` and continues.
- **OWNED-BY-OTHER** — worktree exists and `.wb-owner` has a different `session_id`. `wb-spawn` exits non-zero with recovery instructions. Do not enter the worktree or force the canary.

If a worktree exists but `.wb-owner` is missing, `wb-spawn` assumes it was created by raw `git worktree add`, writes a canary with `created_via: raw-git-add`, warns, and continues.

Recovery procedure for abandoned ownership:

1. Verify in `memory/heartbeat.md` that the owner session has a `closed` event for that worktree, or get explicit coordination from the maintainer.
2. Remove only the canary file: `rm <worktree-path>/.wb-owner`.
3. Re-run `wb-spawn` or `wb-task`.

This pairs with `AGENTS.md` §0 Step 0.5, the pre-action heartbeat conflict check. The canary prevents directory-level collisions; the heartbeat check prevents claim-level collisions before an agent emits a `started` event.

## Per-session bootstrap (mandatory)

Every spawned session must perform this bootstrap before doing task work:

1. **Confirm worktree** — verify `pwd` matches the session's expected worktree path. If not, `cd` to the correct path before any other action.
2. **AGENTS.md §0** — follow the bootstrap reading order, including Step 0.5 pre-action conflict + context check.
3. **Create chronicle** — `memory/sessions/<session-id>-<date>-<topic>.md` per chronicle convention.
4. **Tail heartbeat** — `tail -n 20 $WB_REPO/memory/heartbeat.md` to see recent cross-session state.
5. **Append `started` event** to heartbeat only after Step 0.5 finds no active conflicting claim.
6. Continue with task-specific bootstrap (read brief, etc.).

Spawn prompts produced by the strategist session bake these steps in.

## Workflow patterns for moving work between worktrees

**Pattern A — Branch merge.** Session's commits land on the project's integration branch via merge:

```bash
cd $WB_REPO   # main worktree
git merge --no-ff <task-branch>
```

**Pattern B — Cherry-pick.** Selective commit pulls:

```bash
git cherry-pick <hash>
```

**Pattern C — File copy (read-only outputs, no commits in source session).** Common for recon flow:

```bash
cp ../cadence-session2/handoff/notes/recon_*.md handoff/notes/
# Then commit from the main worktree
```

## Cleanup when a session is done

```bash
wb-remove <name>
git branch -d <branch>   # if merged
```

## iTerm2 tab labeling — visual identification + durable persistence

The helper script uses three layered mechanisms to label tabs reliably:

1. **AppleScript `set name to`** — sets iTerm2's user-defined title at tab creation.
2. **OSC escape `\e]1;LABEL\a`** emitted by the shell after `cd` — survives the shell's own title-management.
3. **Per-worktree label config + auto-restore on shell startup** — the durable layer. `wb-spawn` writes the label to `~/.config/wb/labels/cadence-<name>.label`. The `wb-restore-label` function (called from `~/.zshrc`) reads this on every shell startup and re-emits the OSC escape. Labels persist across iTerm2 restarts, system reboots, and tab close/reopen.

This labeling layer is iTerm2-specific. If your team uses a different terminal, replace the `osascript` block in `wb-spawn` with the equivalent for your terminal.

## What this does NOT do

- **Does not auto-launch agent CLI binaries.** You launch `codex` / `claude-code` / etc. yourself in each tab. This is intentional — keeps the convention CLI-agnostic.
- **Does not enforce session ID uniqueness across people.** If two operators were to use the same machine concurrently with the same session IDs, worktrees would collide. Single-operator assumption holds at small-team scale.
- **Does not handle session persistence across machine reboots.** iTerm2 layouts can be saved manually (Window → Save Window Arrangement); worktrees survive reboots automatically.

## Cross-references

- `../../memory/HEARTBEAT_SPEC.md` — cross-session awareness ledger format
- `../../memory/INDEX.md` — project state
- `../../AGENTS.md` §0 — agent bootstrap reading order
- `agent-roles.md` — role-vs-session model (durable role contracts)
- `operational-patterns.md` §6 — worktree lifecycle
- `drift-classes.md` — Class 1 (worktree-claim) and Class 4 (runtime-resource) drift this layer mitigates
