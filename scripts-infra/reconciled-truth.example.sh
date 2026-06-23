#!/usr/bin/env bash
# reconciled-truth.example.sh — Reference stub for a reconciled-truth surface.
#
# CONTRACT (see design/process/reconciled-truth.md):
#
# - Read heartbeat tail, worktree list, CR metadata, role state, optional
#   autonomy-loop state, optional goal manifests.
# - Apply deterministic reconciliation rules (no LLM judgment).
# - Emit a single snapshot with stable structure.
#
# Invocations the contract requires:
#   <tool> --snapshot          # full reconciled state
#   <tool> --print             # human-readable summary
#   <tool> --dashboard-feed    # JSON for downstream tooling
#   <tool> --owner-needed      # only items needing orchestrator attention
#
# This stub documents the interface; a project's implementation lives
# in scripts-infra/<project-prefix>-reconciled-truth (typically a Python
# worker behind a shell launcher).
#
# See examples/overture/scripts/reconciled-truth for a worked obfuscated example.

set -euo pipefail

MODE="${1:-}"

usage() {
  cat <<EOF
usage: reconciled-truth <mode>

Modes (per reconciled-truth.md §2):
  --snapshot          Full reconciled state as JSON
  --print             Human-readable summary
  --dashboard-feed    JSON shaped for downstream tooling
  --owner-needed      Only items needing orchestrator attention

Contract: design/process/reconciled-truth.md
EOF
}

if [[ -z "$MODE" ]]; then
  usage
  exit 2
fi

case "$MODE" in
  --snapshot|--print|--dashboard-feed|--owner-needed)
    cat <<EOF
This is a stub. A working reconciled-truth implementation must apply the
deterministic rules from reconciled-truth.md §3 to produce a snapshot with
the structure in §4:

  {
    "generated_at": "<ISO-timestamp>",
    "active": [...],
    "claimable": [...],
    "blocked": [...],
    "stale": [...],
    "awaiting_orchestrator": [...],
    "acceptance_pending": [...],
    "warnings": [...]
  }

Authorities (§5):
  - Authoritative for: what is the current state
  - Not authoritative for: approval, priority, route emission, closeout
EOF
    ;;
  *)
    usage
    exit 2
    ;;
esac
