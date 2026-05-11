# Agent handoff — <feature>

Coding-agent prep. **Audience:** the agent picking up this feature for implementation. Assume they've read `../../canonical/` foundation and the sibling `build-spec.md`, but nothing else feature-specific.

---

## What you're building

One paragraph: the deliverable in concrete terms.

## Slice plan

Which slices from `../../canonical/implementation-plan.md` cover this feature. If a new slice is needed, draft it here for incorporation upstream.

| Slice | Scope | Effort tier | Depends on |
|---|---|---|---|
| ... | ... | ... | ... |

## Entities to migrate / extend

Cite into `../../canonical/entity-model.md` (when authored). List exact entity families and field additions needed.

## Components to build / reuse

Cite into `../../canonical/component-library.md` (when authored). Note which are already built and which are new for this feature.

## APIs to implement

Cite into `../../canonical/api-contracts.md` (when authored). List queries and mutations needed for the slice.

## LLM surfaces (if any)

Cite into `../../canonical/llm-wiring.md` (when authored). Note prompt templates, signal inputs, output schemas, and budget allocations.

## Hard-wired rules to honor

Cite into `../../canonical/rules-catalog.md` (when authored). List exact rule numbers with values.

## Reference renders / visual specs

Cite into `../../canonical/reference-renders/` (when authored). List the canonical visual specs for surfaces this feature touches. Honor supreme-fidelity-authority per `../../process/conventions.md` §4.

## Quality gates

Before merging, confirm all of:
- [ ] All entities exist or are migrated
- [ ] All APIs return shapes match canonical contracts
- [ ] All hard-wired rules honored at exact values
- [ ] Visual fidelity matches reference renders (if applicable)
- [ ] User stories pass acceptance criteria
- [ ] Run `../../process/consistency-checks.md` before submitting for review
- [ ] Validation gate sequence from `../../process/operational-patterns.md` §9 passes in order

## Out of scope for this slice

Track explicitly to prevent scope creep.
