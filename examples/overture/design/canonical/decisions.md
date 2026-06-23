# Atlas — decisions log (overture reference)

> **Overture reference instance — obfuscated.** Fictional decisions illustrating a real decision-log shape. All `OV-D-*` IDs are fictional per `OBFUSCATION_POLICY.md`.

This file demonstrates a canonical decisions log running on Cadence. Append-only, append-newest-first, every decision identified by stable ID.

## Format

```markdown
## OV-D-FOO-NN — One-line decision title

**Status:** LOCKED | DRAFT | SUPERSEDED-BY-<id>
**Date:** YYYY-MM-DD
**Authored by:** <role>
**Context:** what motivated the decision

**Decision:** the actual call

**Rationale:** why this over alternatives

**Implications:** what this commits the project to

**Cross-references:** related decisions, anchor patterns, handoffs
```

---

## OV-D-STACK-01 — Atlas tech stack lock

**Status:** LOCKED
**Date:** 2026-02-03
**Authored by:** Practice Lead

**Context:** Multiple proofs-of-concept on different stacks slowed down early-stage architecture. Needed a lock to enable real engineering velocity.

**Decision:** Python ≥ 3.11 backend (FastAPI), React + TypeScript frontend, PostgreSQL primary store, Redis for cache/queue, S3-compatible blob store. Voyage AI for embeddings (OpenAI fallback), ChromaDB for vector index.

**Rationale:** Maximal team familiarity. Python ecosystem covers ML / data / web. React + TS covers the engagement-management UI cleanly. Voyage retrieval baseline outperformed alternatives on Atlas's corpus profile.

**Implications:** No language re-evaluation through M3. New components must compose existing primitives.

**Cross-references:** OV-D-MCP-NAME-01, OV-anchor-01.

---

## OV-D-OPMODEL — 5-step engagement methodology lifecycle

**Status:** LOCKED
**Date:** 2026-02-08
**Authored by:** Engagement Lead

**Context:** Field Specialists were running engagements differently per Field Specialist, making cross-engagement comparison + Practice Lead review impossible.

**Decision:** Every engagement follows the 5 steps in order: (1) Discovery, (2) Plan Lock, (3) Active Delivery, (4) Validation, (5) Closeout. Each step has explicit entry + exit criteria, captured in the anchor pattern set.

**Rationale:** Methodology consistency enables cross-engagement learning + quality lens at the Practice Lead level. Step-locked exit criteria prevent "this engagement skipped Plan Lock" failures.

**Implications:** Plan Workspace, Health Workspace, and Status Report anchors all reflect the 5-step lifecycle. Any new engagement-shaped feature lands against this lifecycle.

**Cross-references:** OV-D-T10-LIFECYCLE, OV-anchor-02-plan-workspace, OV-anchor-04-health-workspace, OV-anchor-05-status-report.

---

## OV-D-JOB-PER-SOW — One engagement = one statement of work

**Status:** LOCKED
**Date:** 2026-02-10
**Authored by:** Engagement Lead

**Context:** Some engagements were modeled as "one engagement, many SOWs"; others as "one SOW spans many engagements." The mixed model made revenue recognition + capacity planning incoherent.

**Decision:** One engagement = one SOW. Multi-SOW customer relationships become multi-engagement portfolios at the customer level.

**Rationale:** Simpler revenue model. Cleaner capacity planning. Forces the customer-level portfolio concept which Atlas needs anyway for cross-engagement health.

**Implications:** Plan Workspace is per-engagement. Customer Preview aggregates across engagements. Field Specialist staffing is per-engagement.

**Cross-references:** OV-D-OPMODEL, OV-anchor-01-engagement-overview, OV-anchor-08-customer-preview.

---

## OV-D-T10-LIFECYCLE — T-10 / T-7 / T-3 / T-0 / T+3 cadence

**Status:** LOCKED
**Date:** 2026-02-15
**Authored by:** Engagement Lead

**Context:** Customer kickoff prep was uneven — some engagements over-prepared, others under-prepared. Needed a uniform countdown.

**Decision:** Every engagement runs a T-10 / T-7 / T-3 / T-0 / T+3 cadence:

- **T-10:** customer-determined Go-Live date locked; staffing committed.
- **T-7:** Field Specialist roster confirmed; pre-engagement materials sent.
- **T-3:** dry-run with the assigned team.
- **T-0:** Go-Live; Field Specialists on customer site.
- **T+3:** retrospective; learnings captured.

**Rationale:** Predictable cadence reduces last-minute heroics. Practice Lead can audit any T-3 to gate quality.

**Implications:** Plan Workspace surface visualizes the countdown. Health Workspace alerts when any T-gate is at risk.

**Cross-references:** OV-D-OPMODEL, OV-anchor-04-health-workspace.

---

## OV-D-IA-PROPAGATE — Information-architecture changes propagate uniformly

**Status:** LOCKED
**Date:** 2026-02-20
**Authored by:** Practice Lead

**Context:** IA changes (new sections, renamed concepts, restructured menus) were landing on some surfaces but not others, producing inconsistent state across the product.

**Decision:** IA changes propagate uniformly. Any IA change must update: (a) navigation chrome, (b) vocabulary glossary, (c) anchor patterns it affects, (d) personas affected, (e) Storybook catalog entries, (f) decision log entry. No partial IA landings.

**Rationale:** Partial IA changes confuse personas mid-workflow. Uniform propagation is operationally annoying but is the only way to keep the IA coherent.

**Implications:** IA changes become explicit CRs with `composition_anchor_stories` covering every affected surface. The visual-QA catalog enforces baseline-update on every affected story.

**Cross-references:** OV-D-OPMODEL, OV-anchor-* (all).

---

## OV-D-SITUATIONAL-AWARENESS-CONTRACT — §1.X contract for every surface

**Status:** LOCKED
**Date:** 2026-02-22
**Authored by:** Practice Lead

**Context:** Some surfaces felt disorienting — users couldn't tell what they were looking at, where they were, what was happening, what to trust, or what to do next.

**Decision:** Every surface in Atlas satisfies the 5-dimensional situational-awareness contract: **Orientation** (where am I) · **Change** (what just happened) · **Why** (why is it this way) · **Trust** (is what I see reliable) · **Continuation** (what do I do next). The contract is load-bearing at the shell-rules level.

**Rationale:** Without explicit situational-awareness, every surface ends up with implicit assumptions about user context. The contract forces the assumptions explicit.

**Implications:** Anchor patterns include a SA scorecard. UX Analyst probes against this contract. Audits over the 17 primary anchors track SA compliance.

**Cross-references:** OV-D-OPMODEL, all anchor patterns, shell-rules.md §1.X.

---

## How to read this log

Newest-first append-only. Once an entry is `LOCKED`, it never moves — superseding a decision adds a new entry with `Status: LOCKED` and updates the superseded one's status to `SUPERSEDED-BY-<new-id>`.

`DRAFT` entries are decisions in flight; they're tracked here so they're discoverable but don't yet constrain implementation. A DRAFT becoming LOCKED is a CR-routable transition.

---

*This log demonstrates the Cadence decision-log shape: append-only, ID-stable, evidence-rich, and tied to anchor patterns + shell rules. A downstream project's decisions log has different content but the same shape.*
