# Atlas — role registry (overture reference)

> **Overture reference instance — obfuscated.** Fictional personas; Cadence core role contracts in `design/process/agent-roles.md` are the abstract layer this instantiates.

Atlas (the fictional Professional Services Automation platform) has four product personas. Each is a *named* persona (the people who use Atlas) that inherits from one or more abstract Cadence roles (the framework's coordination machinery).

## The four product personas

| Persona | Atlas role | Cadence abstract role analog |
|---|---|---|
| **Engagement Lead** | Owns customer engagements end-to-end; coordinates Delivery Manager + Field Specialists for staffing, schedule, financials | Orchestrator (Sync) |
| **Delivery Manager** | Owns delivery of the work for one engagement; manages day-to-day Field Specialist activity, blockers, customer relationship | Architect (Sync) |
| **Field Specialist** | Executes engagement work directly with customers; reports status, surfaces blockers, captures notes | Executor |
| **Practice Lead** | Cross-engagement quality + people development; reviews work, escalations, capacity decisions | Architect (Async, senior) |

These are **product personas**, not Cadence framework roles. The framework roles (Orchestrator, Architect, Executor, Observer, Memory Steward, Coordinator, QA-Agent, Resident Autonomy Agent) live in Cadence core and define how *agents* coordinate. The personas above are who actually uses the Atlas product.

## How personas map to coordination

When Atlas runs on Cadence with `roles_full: on` + `runtime_binding: on`, the runtime binds *agents* to do work *for* personas:

```
Engagement Lead (product persona, human user)
   ↓ approves work
[Strategic Orchestrator — Cadence role, agent embodiment]
   ↓ routes via
[Coordinator — Cadence role, autonomy-loop embodiment]
   ↓ delivers route to
[Build-UX / Build-Backend / Build-Infra executors — Cadence roles, CLI session embodiments]
   ↓ work product reaches
Delivery Manager / Field Specialist (product personas, human users)
   ↓ provide feedback
[QA-Agent — Cadence role, CLI session embodiment]
   ↓ verdict to
Strategic Orchestrator → Engagement Lead → walk
```

The **Cadence roles** are the coordination layer. The **product personas** are the people the product is for.

## Engagement Lead (Atlas PM equivalent)

**Purpose:** Owns customer engagements. Single point of accountability for the Globex Corp engagement from kick-off through close-out.

**Key surfaces (anchor patterns in this corpus):**

- Engagement Overview — landing surface for one engagement
- Plan Workspace — sequenced delivery plan
- Health Workspace — status + blockers + risk
- People — staffing + capacity
- Customer Preview — what the customer sees

**Decisions Engagement Lead owns** (locked, see `decisions.md`):

- `OV-D-OPMODEL` — the 5-step engagement methodology lifecycle
- `OV-D-JOB-PER-SOW` — one engagement = one statement of work
- `OV-D-T10-LIFECYCLE` — T-10 / T-7 / T-3 / T-0 / T+3 cadence

**Coordination role analog** (Cadence framework): Orchestrator (Sync) — Engagement Lead approves work, sets priority, decides what walks.

## Delivery Manager (Atlas DL equivalent)

**Purpose:** Day-to-day delivery management for one engagement. Reports up to Engagement Lead.

**Key surfaces:**

- Delivery Workspace — execution view of the plan
- Field Activity — what Field Specialists are doing right now
- Blocker Inbox — surfaced issues needing decisions

**Coordination role analog:** Architect (Sync) — Delivery Manager doesn't drive scope (Engagement Lead does), but does drive execution architecture for one engagement.

## Field Specialist (Atlas Consultant equivalent)

**Purpose:** Executes engagement work directly with the customer. Captures field notes, status, blockers. Multiple Field Specialists per engagement.

**Key surfaces:**

- My Schedule — assigned work for the week
- Session Prep — pre-customer-meeting context
- Field Notes — running journal of observations

**Coordination role analog:** Executor — does the work; reports outcomes.

## Practice Lead (Atlas Lead Consultant equivalent)

**Purpose:** Cross-engagement quality + people. Reviews work across engagements; weighs in on tough escalations; develops Field Specialists; advises Engagement Leads.

**Key surfaces:**

- Quality Lens — cross-engagement quality dashboard
- Mentorship Threads — coaching conversations with Field Specialists
- Escalation Inbox — issues that need senior judgment

**Coordination role analog:** Architect (Async, senior) — Practice Lead doesn't run any one engagement but shapes how engagements are run.

## Locked vs draft personas

| Persona | Status | Locked decision |
|---|---|---|
| Engagement Lead | LOCKED | `OV-D-ENGAGEMENT-LEAD-CONTRACT` |
| Delivery Manager | LOCKED | `OV-D-DELIVERY-MANAGER-CONTRACT` |
| Field Specialist | LOCKED | `OV-D-FIELD-SPEC-CONTRACT` |
| Practice Lead | DRAFT | (proposal at `OV-handoff-2026-02-15-practice-lead-shape.md`) |

## How this shape demonstrates the Cadence pattern

The thing to take away: **Cadence's core role contracts (agent-roles.md) are about how the *coordination layer* works**. They're agent-shaped — Orchestrator, Executor, Observer. **Product personas (this file) are about who uses the product**. They're human-shaped — Engagement Lead, Field Specialist.

The two layers map onto each other through agency: when Engagement Lead asks for something to be built, the Strategic Orchestrator (Cadence role, embodied by a Cowork session) approves and routes, the Coordinator (Cadence role, embodied by the autonomy loop) delivers to Build executors (Cadence roles, embodied by CLI sessions), the work ships, and Engagement Lead's customer (Globex Corp) sees the result.

A downstream project building its own thing on Cadence has its own product personas (you might have "Account Manager" and "Specialist"; or "Researcher" and "Reviewer"; or "Patient" and "Clinician"). Those personas slot into the same coordination layer. The Cadence roles don't change; the personas do.
