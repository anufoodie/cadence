#!/usr/bin/env bash
# spawn-agent.sh — Spawn the CLI-bootable session set in iTerm2 tabs.
#
# What it does:
#   - Opens iTerm2 tabs for the CLI-bootable session set per agent-roles.md §7:
#       * Observer            (long-lived polling + synthesis loop)
#       * Async Architect     (bounded infrastructure framework amendments)
#       * Build Executor      (executes commit-requests against main worktree; optional)
#   - Each tab cd's into the project repo, displays the role's kickoff
#     prompt (verbatim from design/process/agent-roles.md §5 + the §7.1
#     PREREQUISITE notice), then launches `codex --dangerously-bypass-approvals-and-sandbox`
#     so the autonomous polling loop doesn't stall on approval prompts.
#
# What it DOES NOT do:
#   - Run git operations.
#   - Touch task worktrees or `.wb-owner` canaries.
#   - Spawn Cowork roles (Orchestrator / Sync Architect) — those live in
#     the chat sandbox, not iTerm.
#   - Start the Memory Steward (cron-driven; see design/process/scheduled-tasks/).
#
# Conventions:
#   - agent-roles.md §5 spawn-prompt templates are the source of truth for the
#     role kickoffs. If those change, regenerate the kickoff files via this
#     script (they're rewritten on every run).
#   - agent-roles.md §7.1 mandates full-access permissions for ALL Codex CLI
#     roles. The script enforces this by passing
#     --dangerously-bypass-approvals-and-sandbox (codex CLI's full-access flag;
#     not to be confused with Claude Code's --dangerously-skip-permissions).
#
# Usage:
#   ./scripts-infra/spawn-agent.sh                # spawn Observer + Async Architect
#   ./scripts-infra/spawn-agent.sh --with-build   # also spawn Build Executor
#   ./scripts-infra/spawn-agent.sh --dry-run      # print what would happen, no tabs
#   ./scripts-infra/spawn-agent.sh --help
#
# After tabs open: each tab shows its kickoff prompt and launches codex.
# Copy the kickoff (it's already echoed to the tab) and paste as your first
# codex message.
#
# Convention: design/process/agent-roles.md  (roles + spawn prompts + §7.1)
#             design/process/operational-patterns.md  (RUNBOOK)

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────────────────────────────────────

REPO="${WB_REPO:-$HOME/Projects/cadence}"
KICKOFF_DIR="${WB_KICKOFF_DIR:-$HOME/.cache/cadence/kickoffs}"
CODEX_BIN="${CODEX_BIN:-codex}"
CODEX_FLAG="${CODEX_FULL_ACCESS_FLAG:---dangerously-bypass-approvals-and-sandbox}"

WITH_BUILD=0
DRY_RUN=0

# ─────────────────────────────────────────────────────────────────────────────
# Arg parsing
# ─────────────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-build)
      WITH_BUILD=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      sed -n '2,40p' "$0"
      exit 0
      ;;
    *)
      echo "spawn-agent: unknown flag: $1" >&2
      echo "usage: $0 [--with-build] [--dry-run] [--help]" >&2
      exit 2
      ;;
  esac
done

# ─────────────────────────────────────────────────────────────────────────────
# Preflight
# ─────────────────────────────────────────────────────────────────────────────

if [[ ! -d "$REPO" ]]; then
  echo "spawn-agent: repo not found at $REPO" >&2
  echo "  (override with WB_REPO=/path/to/repo, or edit the script default)" >&2
  exit 1
fi

if [[ "$DRY_RUN" != "1" ]]; then
  if ! command -v osascript >/dev/null 2>&1; then
    echo "spawn-agent: osascript not found (macOS only)" >&2
    echo "  Replace the osascript block with your terminal's equivalent if not on macOS." >&2
    exit 1
  fi

  if [[ ! -d "/Applications/iTerm.app" ]] && ! osascript -e 'exists application "iTerm"' >/dev/null 2>&1; then
    echo "spawn-agent: iTerm2 not installed (https://iterm2.com)" >&2
    exit 1
  fi

  if ! command -v "$CODEX_BIN" >/dev/null 2>&1; then
    echo "spawn-agent: WARNING — \`$CODEX_BIN\` not on PATH for THIS shell." >&2
    echo "  Tabs will still open; codex must be on PATH inside the new iTerm shells." >&2
  fi
fi

mkdir -p "$KICKOFF_DIR"

# ─────────────────────────────────────────────────────────────────────────────
# Kickoff prompts
#
# Verbatim transcription of agent-roles.md §5 spawn-prompt templates, with
# the §7.1 PREREQUISITE notice prepended. If §5 changes, edit here too
# (or regenerate from doc).
# ─────────────────────────────────────────────────────────────────────────────

PREREQUISITE_NOTE='PREREQUISITE: this session must be started with Codex CLI full-access
permissions (see agent-roles.md §7.1). If you encounter approval prompts
on basic operations, your session was started incorrectly — heartbeat-block
+ page the user before proceeding.'

# Observer ───────────────────────────────────────────────────────────────────
cat > "$KICKOFF_DIR/observer.txt" <<EOF
You are taking the Observer role for this project.

$PREREQUISITE_NOTE

Your FIRST action: tail -n 200 memory/heartbeat.md; read
memory/last-shutdown-snapshot.md if exists; identify currently-active
sessions, worktrees, pending queue items.

Then read in order:
1. AGENTS.md §0 (Step 0.5)
2. design/process/agent-roles.md (Observer section)
3. design/process/operational-patterns.md (Entry 13 port allocation +
   Entry 14 pulse-check contract + Entry 10 heartbeat-tail discipline)

Then emit \`started\` event for observer-codex session-id; begin polling
cycle at 5-10min cadence.

Hourly: synthesis pass. Scan last hour's heartbeat + recent chronicles
for patterns; emit synthesis-proposals to Async Architect.

Garden-tender rules: propose ADDITION only after pattern observed 3+
times; propose CONSOLIDATION every synthesis cycle; propose DEPRECATION
for patterns not firing in 7+ days; net change in RUNBOOK lines per
cycle approaches zero.

Authority: this kickoff IS authorization per RUNBOOK Entry 11. Continue
polling until shutdown-request OR window expires.

If absent for >1 hour (no recent observer-codex events): a fresh Observer
instance does a longer sync pass on the absence window, not just routine
polling.
EOF

# Async Architect ────────────────────────────────────────────────────────────
cat > "$KICKOFF_DIR/async-architect.txt" <<EOF
You are taking the Async Architect role for this project.

$PREREQUISITE_NOTE

Your FIRST action: tail -n 200 memory/heartbeat.md; read
memory/last-shutdown-snapshot.md if exists; identify Observer's recent
synthesis-proposals + any pending architecture asks.

Then read in order:
1. AGENTS.md §0
2. design/process/agent-roles.md (Async Architect section)
3. design/process/operational-patterns.md (RUNBOOK — your
   most-frequently-amended doc)

Begin polling at 30-60min cadence. Each cycle: tail heartbeat last 50
events; process any new Observer synthesis-proposals; if proposal meets
garden-tender threshold (3+ observations, no consolidation candidate,
infrastructure scope) author commit-request + route to Build Executor;
otherwise decline or escalate.

Emit \`note\` event at least every 90 minutes even if "no action this
cycle."

Authority: this kickoff IS authorization per RUNBOOK Entry 11. Operate
within bounded class only; escalate ambiguous items to Sync Architect
(Cowork-Opus) or the user.

Continue polling until shutdown-request received or session window
expires.
EOF

# Build Executor ─────────────────────────────────────────────────────────────
# Adapted from §5 Executor template — Build flavor operates in main worktree
# on docs/scripts and doesn't run wb-task.
cat > "$KICKOFF_DIR/build-executor.txt" <<EOF
You are taking the Executor role (Build flavor) for this project.

$PREREQUISITE_NOTE

Your FIRST action: tail -n 100 memory/heartbeat.md; scan
handoff/notes/commit-requests/ for any pending requests targeted at
codex-build-session or generic Build Executor; identify which to pick up
(or wait for routing).

Then read in order:
1. AGENTS.md §0
2. design/process/operational-patterns.md (RUNBOOK)
3. design/process/agent-roles.md (Executor section — Build flavor)
4. The commit-request you've been routed to

Execute against the commit-request in main worktree. Use path-restricted
commit form (\`git add -- <paths>\` + \`git commit -S ... -- <paths>\`).
Validation gates per RUNBOOK Entry 9. Signed commits only — NEVER bypass
GPG signing (AGENTS.md Forbidden Action #4). NO PUSH (Forbidden Action #1).
Heartbeat at each gate. Self-resolve Tier 0/1 questions via RUNBOOK;
escalate only Tier 3 real blockers.

Authority: this kickoff IS authorization per RUNBOOK Entry 11.
EOF

# ─────────────────────────────────────────────────────────────────────────────
# Tab launcher fragment
#
# Built once per role and run inside the new iTerm tab. It cd's into the
# repo, displays the kickoff with clear delimiters (so the operator can
# triple-click + Cmd+C), then launches codex with the full-access flag.
# ─────────────────────────────────────────────────────────────────────────────

build_tab_command() {
  local role_label="$1"
  local kickoff_file="$2"
  # Single-line command suitable for AppleScript `write text`.
  cat <<EOF
cd $REPO && clear && printf '\n\033[1;36m▶ Role: %s\033[0m\n' '$role_label' && printf '\033[1;33m▶ Kickoff prompt at:\033[0m %s\n\n' '$kickoff_file' && printf -- '──── BEGIN KICKOFF (paste this as your first message to codex) ────\n' && cat '$kickoff_file' && printf -- '\n──── END KICKOFF ────\n\n' && printf '\033[1;32m▶ Launching codex with %s per agent-roles.md §7.1...\033[0m\n\n' '$CODEX_FLAG' && $CODEX_BIN $CODEX_FLAG
EOF
}

# ─────────────────────────────────────────────────────────────────────────────
# iTerm orchestration
#
# Uses osascript to:
#   1. Activate iTerm.
#   2. Ensure a window exists.
#   3. For each role: create a tab, name it, run the launcher command.
#
# Replace this block with your terminal's equivalent if not on macOS/iTerm.
# ─────────────────────────────────────────────────────────────────────────────

open_tab() {
  local tab_name="$1"
  local tab_cmd="$2"

  if [[ "$DRY_RUN" == "1" ]]; then
    echo "── dry-run ── would open iTerm tab: $tab_name"
    echo "── dry-run ── would run: $tab_cmd"
    echo
    return 0
  fi

  # Escape double quotes for AppleScript embedding.
  local escaped_cmd
  escaped_cmd=${tab_cmd//\\/\\\\}
  escaped_cmd=${escaped_cmd//\"/\\\"}

  osascript <<APPLESCRIPT
tell application "iTerm"
  activate
  if (count of windows) is 0 then
    create window with default profile
  end if
  tell current window
    create tab with default profile
    tell current session
      set name to "$tab_name"
      write text "$escaped_cmd"
    end tell
  end tell
end tell
APPLESCRIPT
}

# ─────────────────────────────────────────────────────────────────────────────
# Spawn
# ─────────────────────────────────────────────────────────────────────────────

echo "spawn-agent: repo = $REPO"
echo "spawn-agent: kickoffs written to $KICKOFF_DIR/"
echo "spawn-agent: codex flag = $CODEX_FLAG (agent-roles.md §7.1)"
if [[ "$DRY_RUN" == "1" ]]; then
  echo "spawn-agent: --dry-run — no tabs will be opened"
fi
echo

open_tab "observer" "$(build_tab_command 'Observer' "$KICKOFF_DIR/observer.txt")"
sleep 0.4  # let iTerm settle between tab creations
open_tab "async-architect" "$(build_tab_command 'Async Architect' "$KICKOFF_DIR/async-architect.txt")"

if [[ "$WITH_BUILD" == "1" ]]; then
  sleep 0.4
  open_tab "build-executor" "$(build_tab_command 'Build Executor' "$KICKOFF_DIR/build-executor.txt")"
fi

echo
echo "spawn-agent: done."
echo
echo "Next steps (per agent-roles.md §7 cold-start protocol):"
echo "  1. In each tab, the kickoff prompt is printed above the codex launch."
echo "     Triple-click + Cmd+C the kickoff text, paste into codex as first message."
echo "  2. Watch memory/heartbeat.md for \`started\` events from each role:"
echo "       cd $REPO && tail -f memory/heartbeat.md"
echo "  3. If any tab shows codex asking for an approval prompt on its first"
echo "     action, the full-access flag didn't take. Exit that codex session,"
echo "     re-launch with the correct flag for your codex version, and re-paste"
echo "     the kickoff."
