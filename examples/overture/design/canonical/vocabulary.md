# Atlas — vocabulary glossary (overture reference)

> **Overture reference instance — obfuscated.** Fictional product terms; the *discipline* of vocabulary canonicalization is the framework pattern this demonstrates.

A glossary is **load-bearing** when its terms shape product copy. Atlas treats vocabulary as canonical: defined terms appear consistently in UI, anchor patterns, decision logs, and persona contracts. Drift in vocabulary = drift in product mental model.

## How to use this glossary

- Terms defined here are the **canonical** form. Synonyms are listed but not used in shipped copy.
- New terms join the glossary via decision-log entry, then propagate to all surfaces (per `OV-D-IA-PROPAGATE`).
- Polysemy is called out explicitly. If a word means two things in Atlas, the glossary disambiguates and provides a single canonical phrase for each meaning.

---

## Engagement

The unit of customer work. One engagement = one statement of work = one bounded delivery. Multiple engagements per customer comprise a *customer portfolio*.

- Synonyms NOT used: "project", "job", "deal", "matter".
- See: `OV-D-JOB-PER-SOW`.

## Plan

The sequenced delivery commitment for an engagement. Created at Plan Lock (step 2 of `OV-D-OPMODEL`); revised only via formal change request.

- Synonyms NOT used: "schedule", "roadmap", "timeline" (timeline is a *visualization* of the plan, not the plan itself).

## Outline

A pre-Plan-Lock proposal of what the plan will be. Draft, negotiable.

- Synonyms NOT used: "proposal", "estimate".

## Health

The current state of the engagement against its plan. Always one of: **on-track** · **at-risk** · **off-track** · **paused**.

- Synonyms NOT used: "status" (status is the *report*; health is the *state*).

## Status report

A periodic deliverable summarizing health, blockers, decisions, and next-period plan. Shared with the customer.

- See: `OV-anchor-05-status-report`.

## Anchor

A canonical screen-level specification. Each anchor describes one workspace surface with structured sections: Job · Entry · Key Interactions · Decisions · Locks · Exit.

- Atlas has 10 primary anchors. Each is one file in `anchor-patterns/`.

## Lock

A decision or constraint that has been formalized and propagated. Locked = enforced; draft = proposed.

- See: `OV-D-OPMODEL` step (2) Plan Lock.

## T-gate

A countdown checkpoint in the engagement lifecycle. The five T-gates are T-10, T-7, T-3, T-0, T+3 (`OV-D-T10-LIFECYCLE`).

## Persona

A named human role using Atlas. The four are Engagement Lead, Delivery Manager, Field Specialist, Practice Lead. See `role-registry.md`.

- Note: in Cadence framework documents, "role" refers to *agent* coordination roles (Orchestrator, Executor, etc.). In Atlas product documents, "persona" refers to *human* product users. Don't conflate.

## Borrow

Engagement Lead pattern: requesting a Field Specialist already committed to another engagement, with Delivery Manager approval. Distinct from staffing (which is initial assignment) and replacement (which is one Field Specialist swapping for another).

- See: anchor patterns 06-people, 09-customer-preview.

## Reject

Engagement Lead pattern: declining a customer-requested change to a locked plan. Triggers formal change-request workflow.

- See: borrow-vs-reject contract in `OV-D-OPMODEL`.

## Walk

The user (Engagement Lead, in this product) experiencing a built surface live. Used as a verb: "walk the Plan Workspace before mergeback."

- Synonyms NOT used: "review", "QA" (those happen *before* a walk).
- See: walk-readiness gate in core Cadence `cr-authoring-contract.md` §8.

## Catalog

The Storybook component reference holding canonical baseline renders (per `visual-qa-catalog.md`).

## Composition manifest

A declaration emitted by the build worker stating which catalog components a rendered page composes. The visual-QA pass validates against this manifest, not against the rendered pixels alone.

- See: core Cadence `visual-qa-catalog.md` for the architecture.

---

## Polysemy resolutions

| Word | Atlas meaning | Other meaning | Resolution |
|---|---|---|---|
| "status" | The periodic report | Health state | Use "status report" for the document, "health" for the state |
| "plan" | Locked delivery commitment | Earlier proposal | Use "plan" for locked, "outline" for proposal |
| "review" | Internal QA pre-walk | Customer feedback session | Use "review" for internal, "session" for customer-facing |
| "lock" | Decision formalized | UI lock state | Always qualify: "plan lock", "input locked-for-edit" |

---

## How this shape demonstrates the Cadence pattern

A canonical glossary is what makes product copy consistent across many surfaces, many sessions, many agents. Without one, every CR re-derives terminology from context and surfaces drift apart. With one, every CR cites the glossary and stays aligned.

The discipline transfers to any project: identify your load-bearing terms, define them once, treat their drift as a coherence violation. The specific terms (Engagement / Field Specialist / Anchor / Walk) are Atlas's; the *practice* of having a load-bearing glossary is the framework pattern.
