# Build spec — <feature>

End-to-end design for this feature. **Audience:** designer / PM reviewing the feature; coding agent reading for implementation context.

---

## Problem statement

What user problem does this feature solve. Who feels the pain today. What does success look like.

## Personas + scope

Which canonical personas are in scope. What scope this feature does and does not cover.

## Surfaces involved

Which canonical surfaces (anchor patterns, modules, API endpoints) this feature lands on. Cite into `../../canonical/`. If this feature requires a new surface, surface that as a drift in `references.md` for canonical reconciliation.

## Flows

End-to-end flow diagrams or numbered sequences. Cover happy path + edge cases + failure modes.

## Data model

Entities involved. Cite into `../../canonical/entity-model.md` (when authored). If this feature requires new entities or field additions, surface in `references.md`.

## Rules + constraints

Hard-wired rules in play. Cite into `../../canonical/rules-catalog.md` (when authored). New rules go through canonical reconciliation.

## API surface

Queries and mutations needed. Cite into `../../canonical/api-contracts.md` (when authored). New operations go through canonical reconciliation.

## LLM integration (if any)

Which AI surfaces this feature uses. Cite into `../../canonical/llm-wiring.md` (when authored).

## Edge cases + open questions

What's not yet resolved. Track open questions in `references.md`.

## Acceptance criteria

How we know this feature is done. Connect to `user-stories.md` per-story criteria.
