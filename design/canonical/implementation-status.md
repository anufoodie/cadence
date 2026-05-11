# Implementation Status

Tracker for the slices defined in `implementation-plan.md`. **Where we are right now** in code vs. canonical foundation.

**Authority status:** CANONICAL. Update after each slice flips status (typically by the memory steward or the working agent on merge-back).

**Designed for cold reading by agents** — every status row should cite verifiable evidence so future contributors don't need conversation context to confirm state.

---

## §1. How to read

Each slice gets a status from this set:

| Status | Meaning |
|---|---|
| **BUILT** | Code fully reflects current canonical spec. Demo-ready against canonical visual specs (if applicable). |
| **PARTIAL** | Code exists but predates current canonical foundation. Has known gaps vs current spec. Drift reconciliation pending. |
| **PENDING** | No code yet. Slice spec is locked but build hasn't started. |
| **BLOCKED** | Specific blocker captured in "Notes" column. |

> **Build-state authority:** for live per-slice status against feature-level slice IDs (your project's per-topic taxonomy, e.g., `1A`, `1B`, `MP-GRID`), the **rolling source of truth is `../../memory/INDEX.md` §"Build Progress"**. That doc reflects what's actually shipped per topic-slice using the implementation team's taxonomy. **This `implementation-status.md` is the complementary canonical-alignment view** — it tracks the design slices (`F-*` / `A-*` / `X-*` / `M-*`) against canonical specs, not against per-topic build state. The two views answer different questions:
>
> - `memory/INDEX.md`: "what's shipped right now?" (rolling, per-topic-slice)
> - `canonical/implementation-status.md`: "what's the design-slice status against canonical?" (snapshot, per-design-slice)

---

## §2. Status table

### Foundation tier (F-*)

| Slice | Status | Evidence | Notes |
|---|---|---|---|
| F-1 | PENDING | — | — |

### Anchor / surface tier (A-*)

| Slice | Status | Evidence | Notes |
|---|---|---|---|
| A-1 | PENDING | — | — |

### Cross-cutting tier (X-*)

| Slice | Status | Evidence | Notes |
|---|---|---|---|
| X-1 | PENDING | — | — |

### Migration tier (M-*)

| Slice | Status | Evidence | Notes |
|---|---|---|---|
| M-1 | PENDING | — | — |

---

## §3. Evidence requirements

For a slice to flip from PENDING / PARTIAL to BUILT, the Evidence column should cite at least one of:

- A commit hash that lands the slice's canonical surfaces with passing quality gates.
- A file path that the agent verified exists and matches the canonical spec.
- A test run output (or test file path with passing run) demonstrating acceptance criteria.

Agents updating this file should attach evidence inline rather than asserting status without proof.

---

## §4. Drift cross-reference

When a slice is PARTIAL, link to the relevant drift IDs in `code-audit.md` (if your project tracks one) so the gap is enumerable rather than narrative.

| Slice | Drift IDs |
|---|---|
| — | — |

---

## §5. See also

- `implementation-plan.md` — slice definitions + dependency graph.
- `decisions.md` — decision log; status flips often reference D-* entries.
- `../../memory/INDEX.md` — per-topic build progress (complementary view).
- `code-audit.md` — drift inventory (if your project tracks one).
