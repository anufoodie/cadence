#!/usr/bin/env bash
# cadence.sh — Onboard and manage a Cadence instance as a pluggable engine.
#
# Cadence ships every subsystem on by default; this script lets a new project
# activate/inactivate features from a single manifest (cadence.config.yml) and
# fill in project identity placeholders in one pass.
#
# Usage:
#   ./scripts-infra/cadence.sh status                 Show feature on/off state
#   ./scripts-infra/cadence.sh enable  <feature>      Turn a feature on
#   ./scripts-infra/cadence.sh disable <feature> [--apply]
#                                                     Turn off + prune its files
#   ./scripts-infra/cadence.sh init [--apply]         Onboard: fill placeholders +
#                                                     prune all disabled features
#   ./scripts-infra/cadence.sh doctor                 Report config vs filesystem drift
#   ./scripts-infra/cadence.sh help
#
# Destructive actions (file removal, placeholder rewrites) are DRY-RUN by default.
# Re-run with --apply to execute. See FEATURES.md for the feature catalog.

set -euo pipefail

# ── Locate repo root (parent of scripts-infra/) ───────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$REPO_ROOT/cadence.config.yml"

# ── Feature → owned paths map ─────────────────────────────────────────────────
# Space-separated paths (relative to repo root) that a feature owns. Disabling a
# feature prunes these; CORE features have no prune paths (their removal would
# break the engine, so disabling them is refused).
feature_paths() {
  case "$1" in
    operating_contract) echo "" ;;   # core — refuse disable
    memory_index)       echo "" ;;   # core
    design_corpus)      echo "" ;;   # core
    handoff_notes)      echo "" ;;   # core
    heartbeat)          echo "memory/heartbeat.md memory/HEARTBEAT_SPEC.md" ;;
    session_chronicles) echo "memory/sessions" ;;
    worktrees)          echo "design/process/scripts/wb-session.sh design/process/multi-session-workflow.md" ;;
    roles_full)         echo "" ;;   # doc-level toggle, not a file prune (see FEATURES.md)
    memory_steward)     echo "design/process/scheduled-tasks memory/MEMORY_STEWARD_LAST_RUN.md" ;;
    drift_taxonomy)     echo "design/process/drift-classes.md memory/drift-reports" ;;
    autonomy_framework) echo "design/process/autonomy-gap-framework.md" ;;
    observer_loop)      echo "scripts-infra/spawn-agent.sh memory/last-shutdown-snapshot.md" ;;
    sync_engine)        echo "sync-reports .cadence-sync-last-run.md" ;;
    gpg_signing)        echo "" ;;   # git-config toggle, not a file
    work_units)         echo "design/process/work-units.md" ;;
    goal_runner)        echo "design/process/autonomy-goal-runner.md handoff/notes/goals" ;;
    cr_authoring_contract) echo "design/process/cr-authoring-contract.md" ;;
    runtime_binding)    echo "design/process/runtime-binding.md" ;;
    runtime_route)      echo "design/process/runtime-route.md" ;;
    reconciled_truth)   echo "design/process/reconciled-truth.md" ;;
    resident_autonomy)  echo "design/process/resident-autonomy.md" ;;
    visual_qa_catalog)  echo "design/process/visual-qa-catalog.md" ;;
    layered_overture)   echo "LAYERED.md examples/overture" ;;
    *)                  return 1 ;;
  esac
}

CORE_FEATURES="operating_contract memory_index design_corpus handoff_notes"
ALL_FEATURES="operating_contract memory_index design_corpus handoff_notes \
heartbeat session_chronicles worktrees roles_full memory_steward drift_taxonomy \
autonomy_framework observer_loop sync_engine gpg_signing \
work_units goal_runner cr_authoring_contract runtime_binding runtime_route \
reconciled_truth resident_autonomy visual_qa_catalog layered_overture"

# ── Config helpers ────────────────────────────────────────────────────────────
require_config() {
  [[ -f "$CONFIG" ]] || { echo "error: $CONFIG not found" >&2; exit 1; }
}

# Normalize a truthy/falsy token to on|off.
norm_bool() {
  case "$(echo "$1" | tr '[:upper:]' '[:lower:]')" in
    on|true|yes|1)  echo "on" ;;
    off|false|no|0) echo "off" ;;
    *)              echo "$1" ;;
  esac
}

# Read a feature's state from the manifest (under the `features:` block).
feature_state() {
  local key="$1" raw
  raw="$(awk -v k="$key" '
    /^features:/ { inblk=1; next }
    inblk && /^[^[:space:]]/ { inblk=0 }
    inblk && $0 ~ "^[[:space:]]+" k ":" {
      sub(/^[^:]*:[[:space:]]*/, ""); sub(/[[:space:]]*#.*/, ""); gsub(/[[:space:]]/, "");
      print; exit
    }
  ' "$CONFIG")"
  [[ -z "$raw" ]] && { echo "unset"; return; }
  norm_bool "$raw"
}

# Read a project: field.
project_field() {
  awk -v k="$1" '
    /^project:/ { inblk=1; next }
    inblk && /^[^[:space:]]/ { inblk=0 }
    inblk && $0 ~ "^[[:space:]]+" k ":" {
      sub(/^[^:]*:[[:space:]]*/, ""); sub(/[[:space:]]*#.*/, ""); print; exit
    }
  ' "$CONFIG"
}

# Set a feature's value in the manifest in place.
set_feature() {
  local key="$1" val="$2" tmp
  tmp="$(mktemp)"
  awk -v k="$key" -v v="$val" '
    /^features:/ { inblk=1 }
    inblk && /^[^[:space:]]/ && !/^features:/ { inblk=0 }
    {
      if (inblk && $0 ~ "^([[:space:]]+)" k ":") {
        match($0, /^[[:space:]]+/); indent=substr($0, 1, RLENGTH)
        rest=$0; sub(/^[[:space:]]+[^:]+:[[:space:]]*[^[:space:]]+/, "", rest)
        print indent k ": " v rest
        next
      }
      print
    }
  ' "$CONFIG" > "$tmp"
  mv "$tmp" "$CONFIG"
}

is_core() { case " $CORE_FEATURES " in *" $1 "*) return 0 ;; *) return 1 ;; esac; }

# ── Commands ──────────────────────────────────────────────────────────────────
cmd_status() {
  require_config
  echo "Cadence features ($CONFIG)"
  echo
  printf "  %-20s %-5s %s\n" "FEATURE" "STATE" "KIND"
  printf "  %-20s %-5s %s\n" "-------" "-----" "----"
  for f in $ALL_FEATURES; do
    local st kind
    st="$(feature_state "$f")"
    if is_core "$f"; then kind="core"; else kind="optional"; fi
    printf "  %-20s %-5s %s\n" "$f" "$st" "$kind"
  done
  echo
  echo "Disable a feature:  ./scripts-infra/cadence.sh disable <feature> --apply"
}

cmd_enable() {
  require_config
  local f="$1"
  feature_paths "$f" >/dev/null 2>&1 || { echo "error: unknown feature '$f'" >&2; exit 1; }
  set_feature "$f" "on"
  echo "enabled: $f"
  local paths; paths="$(feature_paths "$f")"
  if [[ -n "$paths" ]]; then
    for p in $paths; do
      [[ -e "$REPO_ROOT/$p" ]] || echo "  note: $p is missing — restore it from the Cadence starter to fully re-activate."
    done
  fi
}

cmd_disable() {
  require_config
  local f="$1" apply="${2:-}"
  feature_paths "$f" >/dev/null 2>&1 || { echo "error: unknown feature '$f'" >&2; exit 1; }
  if is_core "$f"; then
    echo "refused: '$f' is a CORE feature — disabling it would break the engine." >&2
    exit 1
  fi
  set_feature "$f" "off"
  echo "disabled: $f"
  prune_feature "$f" "$apply"
}

# Remove the files a disabled feature owns (dry-run unless --apply).
prune_feature() {
  local f="$1" apply="$2" paths
  paths="$(feature_paths "$f")"
  [[ -z "$paths" ]] && { echo "  (no files to prune — this is a doc/config-level toggle; see FEATURES.md)"; return; }
  for p in $paths; do
    local full="$REPO_ROOT/$p"
    [[ -e "$full" ]] || continue
    if [[ "$apply" == "--apply" ]]; then
      rm -rf "$full"
      echo "  removed: $p"
    else
      echo "  would remove: $p   (dry-run; pass --apply to execute)"
    fi
  done
}

cmd_init() {
  require_config
  local apply="${1:-}"
  echo "== Cadence init =="
  echo "Project:   $(project_field name)"
  echo "Developer: $(project_field developer)"
  echo "Host:      $(project_field host_url)"
  echo
  if [[ "$apply" != "--apply" ]]; then
    echo "DRY RUN — nothing will be changed. Re-run with --apply to execute."
    echo
  fi

  echo "1) Pruning disabled features:"
  local any=0
  for f in $ALL_FEATURES; do
    is_core "$f" && continue
    if [[ "$(feature_state "$f")" == "off" ]]; then
      echo "  - $f"
      prune_feature "$f" "$apply"
      any=1
    fi
  done
  [[ "$any" == 0 ]] && echo "  (none — all optional features are on)"

  echo
  echo "2) GPG signing: $(feature_state gpg_signing)"
  if [[ "$(feature_state gpg_signing)" == "on" && "$apply" == "--apply" ]]; then
    git -C "$REPO_ROOT" config commit.gpgsign true && echo "  set git commit.gpgsign=true"
  fi

  echo
  echo "3) Placeholders: run a search to confirm none remain in your instance:"
  echo "   grep -rn '<PROJECT_NAME>\\|<DEVELOPER>\\|<GIT_HOST_URL>' --include='*.md' ."
  echo
  echo "Done. See FEATURES.md for per-feature detail."
}

cmd_doctor() {
  require_config
  echo "Cadence doctor — config vs filesystem"
  echo
  local issues=0
  for f in $ALL_FEATURES; do
    local st paths; st="$(feature_state "$f")"; paths="$(feature_paths "$f")"
    [[ -z "$paths" ]] && continue
    for p in $paths; do
      if [[ "$st" == "on" && ! -e "$REPO_ROOT/$p" ]]; then
        echo "  WARN  $f is ON but $p is missing"; issues=$((issues+1))
      elif [[ "$st" == "off" && -e "$REPO_ROOT/$p" ]]; then
        echo "  WARN  $f is OFF but $p still present (run: disable $f --apply)"; issues=$((issues+1))
      fi
    done
  done
  [[ "$issues" == 0 ]] && echo "  OK — config and filesystem agree."
}

cmd_help() { sed -n '2,25p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

# ── Dispatch ──────────────────────────────────────────────────────────────────
main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    status)  cmd_status ;;
    enable)  [[ $# -ge 1 ]] || { echo "usage: enable <feature>" >&2; exit 1; }; cmd_enable "$1" ;;
    disable) [[ $# -ge 1 ]] || { echo "usage: disable <feature> [--apply]" >&2; exit 1; }; cmd_disable "$1" "${2:-}" ;;
    init)    cmd_init "${1:-}" ;;
    doctor)  cmd_doctor ;;
    help|-h|--help) cmd_help ;;
    *) echo "unknown command: $cmd" >&2; cmd_help; exit 1 ;;
  esac
}

main "$@"
