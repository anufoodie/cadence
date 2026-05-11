#!/usr/bin/env bash
# wb-session.sh — Multi-session worktree manager.
#
# Provides: wb-spawn, wb-list, wb-path, wb-remove, wb-relabel-current, wb-restore-label, wb-task
# Convention: design/process/multi-session-workflow.md
# Cross-session signal: memory/HEARTBEAT_SPEC.md
#
# One-time setup:
#   ln -s $WB_REPO/design/process/scripts/wb-session.sh ~/bin/wb-session.sh
#   chmod +x $WB_REPO/design/process/scripts/wb-session.sh
#   echo 'export WB_REPO=$HOME/Projects/cadence' >> ~/.zshrc
#   echo 'source ~/bin/wb-session.sh' >> ~/.zshrc
#   echo 'wb-restore-label' >> ~/.zshrc   # auto-restore tab label on shell startup
#   source ~/.zshrc

# Environment overrides. WB_REPO must point to your main worktree.
WB_REPO="${WB_REPO:-$HOME/Projects/cadence}"
WB_WORKTREE_BASE="${WB_WORKTREE_BASE:-$HOME/Projects}"
WB_LABEL_DIR="${WB_LABEL_DIR:-$HOME/.config/wb/labels}"

# Worktree-directory prefix. Derived from WB_REPO basename so worktrees
# sit as siblings of the main repo (e.g., cadence-<task-slug>).
WB_PROJECT_BASENAME="${WB_PROJECT_BASENAME:-$(basename "$WB_REPO")}"

_wb_timestamp() {
  TZ=America/Los_Angeles date '+%Y-%m-%dT%H:%M:%S%z'
}

_wb_session_id() {
  if [[ -n "${WB_SESSION_ID:-}" ]]; then
    echo "$WB_SESSION_ID"
    return 0
  fi

  local host="${HOSTNAME:-}"
  if [[ -z "$host" ]]; then
    host=$(hostname 2>/dev/null || true)
  fi

  if [[ -n "$host" ]]; then
    echo "$host-$$"
  else
    echo "unknown-$(_wb_timestamp)"
  fi
}

_wb_owner_field() {
  local owner_file="$1" key="$2"
  sed -n "s/^$key: //p" "$owner_file" 2>/dev/null | head -n 1
}

_wb_write_owner() {
  local owner_file="$1" name="$2" branch="$3" session_id="$4" created_via="${5:-wb-spawn}"
  {
    echo "session_id: $session_id"
    echo "claimed_at: $(_wb_timestamp)"
    echo "worktree: $name"
    echo "branch: $branch"
    echo "created_via: $created_via"
  } > "$owner_file"
}

_wb_enforce_owner() {
  local worktree_path="$1" name="$2" branch="$3" created_now="$4"
  local owner_file="$worktree_path/.wb-owner"
  local session_id
  session_id=$(_wb_session_id)

  if [[ "$session_id" == unknown-* ]]; then
    echo "wb-spawn: warning: could not infer stable session id; using $session_id" >&2
  fi

  if [[ "$created_now" == "1" ]]; then
    _wb_write_owner "$owner_file" "$name" "$branch" "$session_id"
    return 0
  fi

  if [[ ! -f "$owner_file" ]]; then
    echo "wb-spawn: warning: existing worktree has no .wb-owner; claiming for this session." >&2
    _wb_write_owner "$owner_file" "$name" "$branch" "$session_id" "raw-git-add"
    return 0
  fi

  local owner claimed owner_branch
  owner=$(_wb_owner_field "$owner_file" "session_id")
  claimed=$(_wb_owner_field "$owner_file" "claimed_at")
  owner_branch=$(_wb_owner_field "$owner_file" "branch")

  if [[ "$owner" == "$session_id" ]]; then
    _wb_write_owner "$owner_file" "$name" "$branch" "$session_id" "$(_wb_owner_field "$owner_file" "created_via")"
    return 0
  fi

  cat >&2 <<EOF
wb-spawn: WORKTREE OWNED BY ANOTHER SESSION

  worktree: $worktree_path/
  owner:    ${owner:-unknown}
  claimed:  ${claimed:-unknown}
  branch:   ${owner_branch:-unknown}

This worktree is currently owned by a different session. Do NOT enter.
If you believe the owner has finished and abandoned the worktree:
  1. Verify via heartbeat that the owner session has a closed event for this worktree.
  2. If yes, manually remove .wb-owner: rm $owner_file
  3. Then re-run wb-spawn.
If the owner is still active, coordinate via heartbeat — do NOT force.
EOF
  return 1
}

# Internal: write a label file for a worktree by basename.
_wb_write_label() {
  local basename="$1" label="$2"
  mkdir -p "$WB_LABEL_DIR"
  echo "$label" > "$WB_LABEL_DIR/$basename.label"
}

# Internal: read the label file for the current worktree (basename of git toplevel).
_wb_read_label() {
  local dir basename label_file
  dir=$(git rev-parse --show-toplevel 2>/dev/null) || return 1
  basename="${dir##*/}"
  label_file="$WB_LABEL_DIR/$basename.label"
  if [[ -f "$label_file" ]]; then
    cat "$label_file"
  fi
}

# Spawn a new session: create worktree if missing, open labeled iTerm2 tab,
# write label config for durability across shell restarts.
# Usage: wb-spawn <name> [--role <role>] [--branch <branch>] [--label <label>]
wb-spawn() {
  local name="$1"; shift
  if [[ -z "$name" ]]; then
    echo "Usage: wb-spawn <name> [--role=<role>] [--branch=<branch>] [--label=<label>]"
    return 1
  fi

  local role="" branch="" label=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role)     role="$2"; shift 2 ;;
      --role=*)   role="${1#--role=}"; shift ;;
      --branch)   branch="$2"; shift 2 ;;
      --branch=*) branch="${1#--branch=}"; shift ;;
      --label)    label="$2"; shift 2 ;;
      --label=*)  label="${1#--label=}"; shift ;;
      *) echo "Unknown arg: $1"; return 1 ;;
    esac
  done

  [[ -z "$branch" ]] && branch="$name"
  [[ -z "$label" ]]  && label="${role:+$role — }$name"
  local worktree_basename="${WB_PROJECT_BASENAME}-$name"
  local worktree_path="$WB_WORKTREE_BASE/$worktree_basename"
  local created_now="0"

  # Create worktree if missing.
  if [[ ! -d "$worktree_path" ]]; then
    ( cd "$WB_REPO" && git worktree add "$worktree_path" -b "$branch" ) || {
      echo "Failed to create worktree at $worktree_path"
      return 1
    }
    created_now="1"
  fi

  _wb_enforce_owner "$worktree_path" "$name" "$branch" "$created_now" || return 1

  # Persist the label for shell-startup restoration.
  _wb_write_label "$worktree_basename" "$label"

  # Spawn labeled iTerm2 tab via AppleScript.
  # Three-layer label setting:
  #   1. AppleScript `set name to` — sets iTerm2 user-defined title at tab creation.
  #   2. OSC escape `\e]1;LABEL\a` from shell after cd — survives shell init.
  #   3. wb-restore-label in ~/.zshrc — re-emits OSC escape on every future shell start
  #      in this worktree (after iTerm2 restart, reboot, or manual relaunch).
  # Replace this block with the equivalent for your terminal if you don't use iTerm2.
  /usr/bin/osascript <<APPLESCRIPT
tell application "iTerm"
  activate
  tell current window
    create tab with default profile
    tell current session
      set name to "$label"
      write text "cd '$worktree_path'"
      write text "printf '\\\\e]1;%s\\\\a' '$label'"
      write text "echo '── $label ──' && echo 'Worktree: $worktree_path' && echo 'Branch: $branch' && git status -sb"
    end tell
  end tell
end tell
APPLESCRIPT
}

# List all active worktrees.
wb-list() {
  ( cd "$WB_REPO" && git worktree list )
}

# Print the absolute path of a named worktree.
wb-path() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: wb-path <name>"
    return 1
  fi
  echo "$WB_WORKTREE_BASE/${WB_PROJECT_BASENAME}-$name"
}

# Remove a worktree (after work merged) and its label config.
wb-remove() {
  local name="$1"
  if [[ -z "$name" ]]; then
    echo "Usage: wb-remove <name>"
    return 1
  fi
  local _wt_path="$WB_WORKTREE_BASE/${WB_PROJECT_BASENAME}-$name"
  ( cd "$WB_REPO" && git worktree remove "$_wt_path" )
  rm -f "$WB_LABEL_DIR/${WB_PROJECT_BASENAME}-$name.label"
}

# Relabel the current iTerm2 tab + persist the label for future shells.
wb-relabel-current() {
  local new_label="$1"
  if [[ -z "$new_label" ]]; then
    echo "Usage: wb-relabel-current \"<new label>\""
    return 1
  fi
  printf '\e]1;%s\a' "$new_label"

  # Persist for shell-startup restoration.
  local dir basename
  dir=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Note: not in a git worktree; label set for current tab only (not persisted)."
    return 0
  }
  basename="${dir##*/}"
  _wb_write_label "$basename" "$new_label"
}

# Auto-restore tab label from per-worktree config on shell startup.
# Add `wb-restore-label` to ~/.zshrc (after sourcing this script) for automatic recovery.
wb-restore-label() {
  local label
  label=$(_wb_read_label) || return 0
  [[ -n "$label" ]] && printf '\e]1;%s\a' "$label"
}

# Spawn standing worktree tabs in one call. Customize the list for your project.
wb-restore-all() {
  wb-spawn session2 --role "Session 2 recon"
  wb-spawn ide --role "IDE-CLI"
}

# Create a task-specific worktree for a CLI session, spawn a labeled tab,
# and print the pre-flight lines to paste into the agent brief.
# Usage: wb-task <slug> [--task-id <id>] [--desc "<description>"]
wb-task() {
  local name="$1"; shift
  if [[ -z "$name" ]]; then
    echo "Usage: wb-task <slug> [--task-id <id>] [--desc <desc>]"
    return 1
  fi

  local task_id="" desc=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --task-id)   task_id="$2"; shift 2 ;;
      --task-id=*) task_id="${1#--task-id=}"; shift ;;
      --desc)      desc="$2"; shift 2 ;;
      --desc=*)    desc="${1#--desc=}"; shift ;;
      *) echo "Unknown arg: $1"; return 1 ;;
    esac
  done

  local role_label="${task_id:+T#$task_id — }${desc:-$name}"
  wb-spawn "$name" --role "Task: $role_label" || return 1

  local worktree_path="$WB_WORKTREE_BASE/${WB_PROJECT_BASENAME}-$name"
  echo ""
  echo "── wb-task: $name ready ──"
  echo ""
  echo "Paste into agent brief (pre-flight block):"
  echo "  Worktree: $worktree_path"
  echo "  Branch:   $name"
  echo "  Step 0: cd $worktree_path && git branch --show-current  # expect: $name"
  echo ""
  echo "Merge-back (after task work is done + signed):"
  echo "  git -C $WB_REPO merge $name --no-ff"
  echo "  wb-remove $name"
  echo "  git -C $WB_REPO branch -d $name"
}
