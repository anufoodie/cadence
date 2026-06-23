#!/usr/bin/env bash
# cr-lint.example.sh — Reference stub for a CR-lint tool.
#
# CONTRACT this tool must satisfy (see design/process/cr-authoring-contract.md):
#
# - Read a CR markdown file (YAML frontmatter + body).
# - Parse the frontmatter against the required schema.
# - Emit per-field status (PRESENT / MISSING / WRONG_VALUE / SUSPECT).
# - Final verdict: ROUTEABLE | NOT_ROUTEABLE_<reason>.
# - Exit code: 0 if ROUTEABLE; nonzero with descriptive message otherwise.
#
# CR-lint is the gate that prevents un-routable CRs from reaching the
# orchestrator approval queue. Build it into the orchestrator's approval
# workflow so a CR can't progress to `approved_for_spawn` until lint passes.
#
# This stub is NOT a working implementation — it documents the interface.
# A project's real implementation typically lives at:
#   scripts-infra/<project-prefix>-cr-lint
#   scripts-infra/<project-prefix>-cr-lint.py     (the worker)
#
# See examples/overture/scripts/cr-lint for a worked obfuscated example.

set -euo pipefail

CR_PATH="${1:-}"

if [[ -z "$CR_PATH" ]]; then
  echo "usage: cr-lint <cr-file>"
  echo ""
  echo "Contract: see design/process/cr-authoring-contract.md"
  exit 2
fi

if [[ ! -f "$CR_PATH" ]]; then
  echo "error: CR file not found: $CR_PATH" >&2
  exit 1
fi

cat <<EOF
This is a stub. A working CR-lint implementation must verify (per
cr-authoring-contract.md §2):

  REQUIRED FIELDS:
  - title: human-readable
  - scope: ux-patch | frontend | backend | infrastructure-autonomous | project-HITL
  - status: lifecycle field, author sets proposed_for_so_review
  - target_role: build-ux | build-backend | build-infra | ...
  - change_paths: at least one under authorized path (THE most-forgotten field)
  - strategic_orchestrator_approval: orchestrator sets at approval
  - no_push: true

  OPTIONAL BUT WELL-DEFINED:
  - walk_before_merge, walk_packet_required, mergeback_disposition
  - composition_require, composition_pages, composition_anchor_stories
  - visual_match_required, visual_baseline, declared_visual_deltas

  TERMINAL VERDICTS:
  - ROUTEABLE: structurally clean except approval-only fields
  - NOT_ROUTEABLE_MISSING_<field>: required field absent
  - NOT_ROUTEABLE_WRONG_<field>: required field has invalid value
  - NOT_ROUTEABLE_SUSPECT_<field>: heuristic flag (e.g. change_paths look unrelated to scope)

Implement against this contract. Cadence ships the contract doc; the
worker is project-specific.
EOF

exit 0
