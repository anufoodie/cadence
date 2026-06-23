# Atlas — canonical corpus (overture reference)

> **Overture reference instance — obfuscated.** This is a worked example illustrating Cadence patterns. Identifiers (project name, customers, personas, IDs, paths, hashes) are fictional per `examples/overture/OBFUSCATION_POLICY.md`. Do not treat this as canonical for any real project; do not import as a dependency.

This subtree shows what a fully populated `design/canonical/` looks like for a real product running on the Cadence engine. The fictional project is **Atlas** — a Professional Services Automation platform serving fictional enterprise customers like Globex Corp.

## What's here

| File | Demonstrates |
|---|---|
| `decisions.md` | Append-only decision log with `OV-D-*` prefixed entries |
| `role-registry.md` | Multi-persona registry (Engagement Lead, Delivery Manager, Field Specialist, Practice Lead) |
| `vocabulary.md` | Glossary discipline — load-bearing terms with definitions |
| `anchor-patterns/` | Page-level canonical specs (one anchor pattern per screen) |
| `component-library.md` | Catalog of UI components composed by anchor patterns |
| `shell-rules.md` | App-shell-level rules (navigation discipline, state-survival, etc.) |
| `pm-workbench-contract.md` | The Engagement Lead's primary workspace contract |
| `rules-catalog.md` | Compiled rules across the canonical corpus |
| `coherence-design-rubric.md` | The 8-check coherence rubric QA runs against |

## How to read this

If you're studying how to wire your own product onto Cadence:

1. Skim `role-registry.md` first — see how personas inherit from Cadence core role contracts.
2. Look at `decisions.md` — see how `OV-D-*` entries shape product evolution.
3. Open one anchor pattern (`anchor-patterns/01-engagement-overview.md`) — see how page-level canonical specs combine vocabulary, components, and rules.
4. Cross-reference back to Cadence core: `design/process/` (contracts), `cadence.config.yml` (which subsystems Atlas turned on).

If you're implementing your own canonical corpus:

- Don't copy `decisions.md` content — your decisions are different. But do copy the *shape* (frontmatter convention, append-only discipline, locked-status markers).
- Don't copy persona names — Engagement Lead / Delivery Manager / Field Specialist are Atlas-specific. But do copy the *pattern* (multi-persona registry that maps to abstract Cadence roles).
- Don't copy anchor numbers — your screens are different. But do copy the *shape* (one file per anchor, structured sections for Job / Entry / Interactions / Decisions / Locks / Exit).

## Obfuscation notes

This subtree was created on 2026-06-22 by sanitizing the canonical corpus of a real product. Per `OBFUSCATION_POLICY.md`:

- Product name **Atlas** replaces the real product name throughout.
- Customer name **Globex Corp** replaces real customers in engagement scripts.
- Personas: Engagement Lead / Delivery Manager / Field Specialist / Practice Lead replace the real personas.
- Canonical IDs: `OV-D-FOO-001` prefix replaces real `D-FOO-001` IDs.
- All dates within fictional window (2026-02-* range) to break specific cross-reference to the real instance's timeline.
- No real chronicles, no real heartbeat events, no real commit SHAs.

If you spot a leak (an unsanitized real identifier), open an issue against `examples/overture/`.
