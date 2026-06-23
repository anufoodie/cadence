# OV-anchor-01 — Engagement Overview

> **Overture reference instance — obfuscated.** Fictional anchor spec illustrating the anchor-pattern shape.

**Status:** LOCKED
**Primary persona:** Engagement Lead
**Secondary personas:** Delivery Manager (read-only view)
**Lifecycle steps touched:** 1 (Discovery), 2 (Plan Lock), 3 (Active Delivery), 4 (Validation), 5 (Closeout)

## Job

The Engagement Lead's landing surface for one engagement. Answers in one screen: *what is this engagement, where is it in lifecycle, what is its current health, what does the Engagement Lead need to do next*. The single highest-traffic Engagement Lead surface — touched many times per day per active engagement.

## Entry

- From **Engagement Portfolio** (cross-engagement list), selecting one engagement.
- From **notifications** referencing this engagement.
- Direct URL: `/engagements/<engagement-id>`.

Pre-conditions: user is signed-in Engagement Lead; engagement exists; engagement is assigned to this Engagement Lead (or shared via portfolio access).

## Key interactions

### View health

- **User does:** lands on the surface.
- **What changes:** the Health Pill at top shows current state (on-track / at-risk / off-track / paused) with the current T-gate countdown.
- **Surface follows:** if `at-risk` or `off-track`, the Blocker Strip shows the top 3 issues. Clicking a blocker opens **OV-anchor-04 (Health Workspace)**.

### Open Plan

- **User does:** clicks "Plan" tab.
- **What changes:** the Plan Workspace renders in-place.
- **Surface follows:** opens **OV-anchor-02 (Plan Workspace)**. State preserved on tab switch.

### Open Status

- **User does:** clicks "Status Report" tab.
- **What changes:** Status Report editor + preview renders.
- **Surface follows:** opens **OV-anchor-05 (Status Report)**.

### Open People

- **User does:** clicks "People" tab.
- **What changes:** People surface renders.
- **Surface follows:** opens **OV-anchor-06 (People)**.

### Send to Customer Preview

- **User does:** clicks "Send to Customer" on a Status Report.
- **What changes:** confirmation dialog. On confirm, Customer Preview surface generates and notifies customer.
- **Surface follows:** the Engagement Lead returns to Engagement Overview; the customer's view opens **OV-anchor-08 (Customer Preview)**.

## Decisions made here

- **Health classification:** Engagement Lead can override the system-computed health (e.g. system says `at-risk`, Engagement Lead knows it's actually `on-track` because a fix already shipped). Override is captured with reason; Practice Lead sees the override.
  - Cites: `OV-D-OPMODEL` step 3.

- **Plan revisions:** any sub-step of Plan changes (date slip, staffing change, scope adjustment) starts here. Engagement Lead clicks "Revise Plan" and follows the revision workflow.
  - Cites: `OV-D-JOB-PER-SOW`, `OV-D-OPMODEL` step 2.

- **Customer Status frequency:** Engagement Lead decides Status Report cadence (weekly / bi-weekly / per-T-gate) at engagement start; can revise.

## Locks integrated

- `OV-D-OPMODEL` — the 5 steps drive the lifecycle progress bar at the top of the surface.
- `OV-D-JOB-PER-SOW` — one Engagement Overview per engagement (not multi-SOW aggregation).
- `OV-D-T10-LIFECYCLE` — the T-gate countdown chip is computed from this lifecycle.
- `OV-D-IA-PROPAGATE` — any IA change to surface tabs (Plan / Status / People / Health) propagates uniformly.
- `OV-D-SITUATIONAL-AWARENESS-CONTRACT` — surface scores 5/5 on the SA scorecard (Orientation / Change / Why / Trust / Continuation).

## Exit

**Success exits:**

- Tab switch to Plan / Status / People / Health — staying within the engagement.
- "Done for now" — returns to Engagement Portfolio.

**Abandon exits:**

- Browser back / direct nav — state preserved per `OV-shell-rule-1.X-return-path-breadcrumb`.

## Cross-references

- Related anchors: `OV-anchor-02` (Plan Workspace), `OV-anchor-04` (Health Workspace), `OV-anchor-05` (Status Report), `OV-anchor-06` (People), `OV-anchor-08` (Customer Preview).
- Cited decisions: `OV-D-OPMODEL`, `OV-D-JOB-PER-SOW`, `OV-D-T10-LIFECYCLE`, `OV-D-IA-PROPAGATE`, `OV-D-SITUATIONAL-AWARENESS-CONTRACT`.
- Cited vocabulary: Engagement, Plan, Outline, Health, Status Report, T-gate, Walk.
- Persona contract: `role-registry.md` — Engagement Lead.

---

*This anchor demonstrates the structure. The other 9 Atlas anchors follow the same shape — Job / Entry / Key Interactions / Decisions / Locks / Exit / Cross-references.*
