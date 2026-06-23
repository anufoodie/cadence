---
goal_id: e2e-simulation
title: End-to-end engagement simulation (Globex Corp)
status: active
objective: Prove the full engagement lifecycle (Discovery → Closeout) works end-to-end on Atlas with one fictional customer dataset.
no_push: true
allowed_child_roles:
  - build-infra
  - build-backend
  - build-ux
  - qa-agent
  - observer
allowed_surfaces:
  - process
  - backend_data_contract
  - root
child_crs:
  - handoff/notes/commit-requests/2026-02-14-e2e-e1-globex-fixture.md
  - handoff/notes/commit-requests/2026-02-15-e2e-e2a-fixture-augment.md
  - handoff/notes/commit-requests/2026-02-16-e2e-e2b-qa-scaffold.md
  - handoff/notes/commit-requests/2026-02-17-e2e-e2c-plan-workspace-walk.md
  - handoff/notes/commit-requests/2026-02-18-e2e-e3-status-report-flow.md
  - handoff/notes/commit-requests/2026-02-19-e2e-e4-closeout-walk.md
child_routes:
  - ovroute-autonomy-20260214T133133-build-infra-abc123
  - ovroute-autonomy-20260214T132803-qa-agent-def456
acceptance_criteria:
  - id: e2e.children.closed
    text: All child routes closed or intentionally parked with orchestrator evidence.
  - id: e2e.walk.proof
    text: Final walk packet exists with light + dark screenshots of the full Globex engagement journey.
  - id: e2e.validation.linked
    text: QA-Agent verdicts linked for each routed surface.
  - id: e2e.commit.evidence
    text: Commit evidence present where landing is approved.
  - id: e2e.blockers.zero
    text: Zero open blockers remain.
final_acceptance_required: true
source_plan: handoff/notes/2026-02-13-e2e-simulation-track.md
owner: strategic-orchestrator
hitl_owner: engagement-lead-or-strategic-orchestrator
landing_policy: observer_host_side_signed_no_push
waves:
  - wave_id: w1-foundation
    title: Foundation — fixtures + scaffolding
    phase_ids:
      - e1
      - e2a
      - e2b
    status: in_progress
  - wave_id: w2-integration
    title: Integration — surface walks
    phase_ids:
      - e2c
      - e3
    depends_on:
      - w1-foundation
    status: pending
  - wave_id: w3-closeout
    title: Closeout — end-to-end walk
    phase_ids:
      - e4
    depends_on:
      - w2-integration
    status: pending
---

# Goal: E2E Simulation (Globex Corp)

> **Overture reference instance — obfuscated.** Fictional goal manifest. Cadence contract: `design/process/autonomy-goal-runner.md`.

This goal manifest demonstrates the shape from core `autonomy-goal-runner.md`. A real goal manifest in a project on Cadence looks like this — frontmatter is machine-readable, body is human-readable.

## What this goal proves

Atlas can run the full engagement lifecycle (Discovery → Plan Lock → Active Delivery → Validation → Closeout) end-to-end with one fictional customer (Globex Corp). The simulation exercises every primary anchor pattern and every persona.

## Waves

### W1 — Foundation (in_progress)

Fixture data + scaffolding for the simulation:

- **E1:** Globex Corp customer fixture (account, contacts, history).
- **E2a:** Engagement fixture augmentation (plan template, Field Specialist assignments).
- **E2b:** QA scaffold for the simulation (test users, role bindings).

### W2 — Integration (pending W1)

Surface walks for each anchor in the simulated engagement:

- **E2c:** Plan Workspace walk on the simulated engagement.
- **E3:** Status Report flow walk.

### W3 — Closeout (pending W2)

End-to-end walk of the full simulation including closeout:

- **E4:** Closeout walk + retrospective capture.

## How the goal flows through the autonomy loop

The resident autonomy loop reads this manifest and projects `goal_next_actions`. Currently:

```json
{
  "goal_id": "e2e-simulation",
  "state": "in_progress",
  "active_wave": "w1-foundation",
  "next_actions": [
    {
      "kind": "routeable_child",
      "cr_path": "handoff/notes/commit-requests/2026-02-15-e2e-e2a-fixture-augment.md",
      "target_role": "build-backend",
      "blocker": null
    }
  ],
  "warnings": []
}
```

Once W1 closes terminally (every child CR has a CLOSED heartbeat line citing its route_id), W2 becomes claimable.

## Why this demonstrates the framework pattern

A goal manifest is how a *body of work* gets tracked as a single bounded surface while the autonomy loop still routes one child at a time. Without goal manifests, the orchestrator would have to track 6 CRs + 2 routes + cross-dependencies in their head (or in chat). With manifests, the goal runner projects state deterministically and the orchestrator can see "what's left to close this goal" at any moment.

A downstream project's goals have different content — different customers, different milestones, different waves — but the same shape (frontmatter contract + child slices + acceptance criteria).
