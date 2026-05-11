# canonical/

Horizontal foundation for `cadence` design. Every feature, every surface, every coding-agent slice references content here. **Single source of truth.**

**Status:** Stub. Populate with project-specific spec content as the project takes shape.

---

## What lives here (target shape)

This starter kit ships with framework-level slots only. The list below is the structure the framework filled in — keep what fits your project, drop what doesn't, and add project-specific docs as needed.

| File / folder | Purpose | Notes |
|---|---|---|
| `decisions.md` | Append-only decision log with rationale + next actions | Framework-provided format |
| `implementation-plan.md` | Vertical slices with dependency graph + effort tiers | Template provided |
| `implementation-status.md` | Per-slice status tracker (BUILT / PARTIAL / PENDING / BLOCKED) with evidence citations | Template provided |
| `adrs/` | Architecture Decision Records — load-bearing decisions with Context / Decision / Consequences format | Empty subfolder; populate as ADRs land |
| `product-model.md` | Canonical product model — durable nouns, shapes, personas | Project-specific; add when your product model solidifies |
| `entity-model.md` | Implementation-grade entity catalog | Project-specific |
| `rules-catalog.md` | Hard-wired rules with classification | Project-specific |
| `api-contracts.md` | Query / mutation surface | Project-specific |
| `component-library.md` | UI components aligned to your design system | Project-specific |
| `anchor-patterns/` | Per-screen / per-module patterns | Project-specific |
| `reference-renders/` | Locked visual specs — supreme fidelity authority | Project-specific |
| `shell-rules.md` | Cross-cutting rules every surface obeys | Project-specific |
| `code-audit.md` | Code-to-canonical drift audit with drift IDs | Project-specific |
| `llm-wiring.md` | LLM / AI surface integration specs | Project-specific |
| `telemetry/` | Metric definitions + observation decks | Project-specific |
| `operating-model/` | Org-operation foundation (if applicable) | Project-specific |

> **Pick a subset.** These docs accumulate over a multi-month design phase. A new project may only need `decisions.md`, `adrs/`, `implementation-plan.md`, `implementation-status.md`, and `product-model.md` at day one — extend as your design matures.

---

## Reading order

For a new collaborator getting up to speed: `decisions.md` → `adrs/` → `product-model.md` (when authored) → other canonical docs as the project shape determines.

For a coding agent picking up implementation: **start with `implementation-status.md`** to know which slices are built / partial / pending. Then jump to the specific canonical surfaces your slice touches.

---

## Cross-reference contract

- Files in `canonical/` reference each other by relative path: `./decisions.md`, `./adrs/<adr>.md`.
- Files outside `canonical/` (e.g. in `features/`) reference into `canonical/` via path from design root: `canonical/decisions.md`.
- `canonical/` itself never cites `features/`. Features depend on canonical, not vice versa.

---

## What does NOT live here

- Feature-specific build specs → `features/`
- Operating manual / workflows → `process/`
- Historical / superseded docs → `archive/`
- Idea registers and glossary → `references/`
