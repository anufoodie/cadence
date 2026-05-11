# References — <feature>

Citations into canonical/ + flagged drifts. **Audience:** anyone reconciling this feature with the canonical foundation, or maintaining cross-reference integrity.

---

## Canonical citations

### Product model

- `../../canonical/product-model.md` §<section> — <what's referenced and why>

### Decisions

- `../../canonical/decisions.md` D-<DECISION-ID> — <relevance>

### Shell rules (if your project has them)

- `../../canonical/shell-rules.md` §1.<NN> — <relevance>

### Anchor patterns / surface patterns

- `../../canonical/anchor-patterns/<NN-anchor>.md` — <relevance>

### Reference renders / visual specs

- `../../canonical/reference-renders/<NN-anchor>.png` — supreme fidelity authority for this feature's visual treatment

### Entity model

- `../../canonical/entity-model.md` §<section> — entities used / extended

### Rules catalog

- `../../canonical/rules-catalog.md` §<NN> — hard-wired rules in play

### LLM wiring (if applicable)

- `../../canonical/llm-wiring.md` §<surface> — AI integration

### API contracts

- `../../canonical/api-contracts.md` §<surface> — operations called

### Component library

- `../../canonical/component-library.md` §<wrapper> — components used / built

### Implementation plan

- `../../canonical/implementation-plan.md` <slice-id> — slice this feature contributes to

---

## Flagged drifts (need canonical reconciliation)

If this feature requires changes to canonical content, flag them here. Each drift becomes a candidate for canonical update before this feature can fully land.

| Drift | What this feature needs | Canonical doc affected | Resolution path |
|---|---|---|---|
| <one-line summary> | <new entity / new rule / new pattern / etc> | `../../canonical/<doc>.md` | <update canonical first / open decision-log entry / etc> |

If no drifts: write "None — this feature aligns to canonical as-is."

---

## Out-of-canonical references (optional)

External material consulted (research, prior art, third-party APIs, etc.). Not authoritative — informational only.
