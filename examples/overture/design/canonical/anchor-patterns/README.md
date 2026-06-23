# Atlas — anchor patterns (overture reference)

> **Overture reference instance — obfuscated.** Fictional anchor specs; the *anchor-pattern shape* is the framework concept this demonstrates.

An **anchor pattern** is a canonical screen-level specification. One file per primary surface. Each anchor describes exactly what the surface does, who uses it, what state it shows, what interactions it supports, and what locks govern it.

Atlas has 10 primary anchors. This README lists them; one full example (`01-engagement-overview.md`) is included to demonstrate the structure. The other 9 would follow the same shape.

## The 10 anchors

| ID | Anchor | Primary persona | Status |
|---|---|---|---|
| `OV-anchor-01` | Engagement Overview | Engagement Lead | LOCKED |
| `OV-anchor-02` | Plan Workspace | Engagement Lead + Delivery Manager | LOCKED |
| `OV-anchor-03` | Masterplan Review | Engagement Lead + Practice Lead | LOCKED |
| `OV-anchor-04` | Health Workspace | Engagement Lead | LOCKED |
| `OV-anchor-05` | Status Report | Engagement Lead → Customer | LOCKED |
| `OV-anchor-06` | People | Engagement Lead | LOCKED |
| `OV-anchor-07` | Field Session Prep | Field Specialist | LOCKED |
| `OV-anchor-08` | Customer Preview | Customer | LOCKED |
| `OV-anchor-09` | Quality Lens | Practice Lead | DRAFT |
| `OV-anchor-10` | Field Notes | Field Specialist | LOCKED |

## Anchor pattern shape

Every anchor follows this structure:

```markdown
# OV-anchor-NN — <Anchor Name>

**Status:** LOCKED | DRAFT
**Primary persona:** <persona>
**Secondary personas:** <persona>, <persona>
**Lifecycle steps touched:** <numbers from OV-D-OPMODEL>

## Job
What this surface is FOR. One paragraph. The persona's job-to-be-done on this screen.

## Entry
How users get here. Routes from. Pre-conditions.

## Key interactions
Each interaction's:
- What user does
- What changes
- What surface follows

## Decisions made here
What the persona DECIDES on this surface. Each decision cites its locked OV-D-* if applicable.

## Locks integrated
Which OV-D-* locks shape this surface's behavior.

## Exit
Where users go from here. Success exit. Abandon exit.

## Cross-references
- Related anchors
- Cited decisions
- Cited vocabulary entries
- Related persona contracts
```

## How anchors interact with the visual-QA canonical catalog

When the project is on Cadence with `visual_qa_catalog` enabled, every anchor has a corresponding Storybook canonical baseline. The `composition_anchor_stories` field in build CRs (see core `cr-authoring-contract.md` §2.3) references the anchor stories that gate visual fidelity.

The pipeline:

```
Anchor pattern (this directory)  ──┐
                                   │
Storybook canonical baseline    ──┼──▶  composition manifest → visual-QA validation
                                   │
Build worker composition         ──┘
```

If the rendered build's composition doesn't match the anchor's locked structure, the visual-QA cascade catches it deterministically — no LLM judgment required.

## How this shape demonstrates the Cadence pattern

Anchor patterns make screen-level canonical spec **explicit**. Without them, "what is this screen supposed to do" lives in chat threads, persona conversations, and implicit shared context — which drifts. With them, every screen has one canonical spec that all surfaces (build CRs, visual-QA catalog, persona contracts, design rubric) reference.

A downstream project may not call them "anchors" — could be "screen specs," "page contracts," "surface canonicals" — but the load-bearing function (one canonical doc per primary surface) is the framework pattern.

See `01-engagement-overview.md` for a worked example.
