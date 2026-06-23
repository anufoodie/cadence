#!/usr/bin/env bash
# runtime-route.example.sh — Reference stub for the route-delivery contract.
#
# CONTRACT (see design/process/runtime-route.md):
#
# - Identify an eligible slice + target role.
# - Generate a stable route_id.
# - Check target session prompt_ready.
# - Deliver the kickoff prompt via tmux send-keys (or runtime equivalent).
# - Emit ROUTE_SENT heartbeat event with route_id.
# - Wait for CANARY-ACK referencing the route_id.
# - On ACK: emit ROUTE_ACKED, await STARTED.
# - On timeout: emit ROUTE_ACK_MISSED; one retry then escalate.
#
# This stub documents the interface; a project's real implementation
# lives in scripts-infra/<project-prefix>-runtime-route.
#
# See examples/overture/scripts/runtime-route for a worked obfuscated example.

set -euo pipefail

ACTION="${1:-}"

usage() {
  cat <<EOF
usage: runtime-route <action> [args...]

Actions:
  send <role> <cr-or-route-spec>    Prepare + deliver a route
  status <route-id>                  Show route lifecycle state
  retry <route-id>                   Retry delivery (once)
  escalate <route-id>                Escalate to orchestrator

Contract: design/process/runtime-route.md
EOF
}

case "$ACTION" in
  send|status|retry|escalate)
    cat <<EOF
This is a stub. A working route-delivery implementation must implement the
canary-ACK pattern in runtime-route.md §3:

  1. Check prompt_ready (per §4).
  2. Deliver via tmux send-keys (or runtime equivalent).
  3. Wait for CANARY-ACK heartbeat referencing route_id.
  4. Timeout default 120s; one retry then ROUTE_ACK_MISSED.

Route ID shape (§2):
  route-<purpose>-<UTC-timestamp>-<role-key>-<short-hash>

Purposes:
  autonomy | coordinator | reset | role-bootstrap
EOF
    ;;
  *)
    usage
    exit 2
    ;;
esac
