# Implementation Plan — Vertical Slices + Dependency Graph

**Status:** Template — populate as the project's slice taxonomy solidifies.

Slices the project into multi-agent-executable units with explicit dependencies. Each slice declares what it touches, what it depends on, and what proves it complete.

---

## How to read

A **slice** is a coherent unit of implementation work that delivers a meaningful product capability. Slices are designed for **multi-agent parallel execution** — each slice is small enough for one agent to complete, but big enough to deliver demonstrable value.

Per slice (template — adapt per project):

- **Slice ID** — short identifier (`F-1`, `A-3`, `X-2`, etc.)
- **Name + scope** — what this slice delivers
- **Entities touched** — references your canonical entity model (if applicable)
- **Components built** — references your component library (if applicable)
- **APIs implemented** — references your API contracts (if applicable)
- **LLM integration** — references your LLM wiring spec (if any)
- **Hard-wired rules adopted** — references your rules catalog (if applicable)
- **Reference render / visual spec** — references your locked visual (if applicable)
- **Depends on** — other slice IDs that must complete first
- **Effort tier** — `S` (small, < 3 days) · `M` (medium, 3-7 days) · `L` (large, 1-2 weeks) · `XL` (extra large, 2+ weeks)
- **Acceptance criteria** — what proves the slice complete

### Slice ID prefixes (template — adapt per project)

Suggested defaults:

- **F-*** Foundation (must exist before surface-level work)
- **A-*** Anchor / surface (one per locked anchor pattern or module)
- **X-*** Cross-cutting (real-time, auth, audit, integration)
- **M-*** Migration

Rename / extend per your project's taxonomy.

---

## Slices

### Foundation tier (F-*)

| ID | Name | Effort | Depends on | Status |
|---|---|---|---|---|
| F-1 | _(populate)_ | _S/M/L_ | _(none)_ | _PENDING_ |

### Anchor / surface tier (A-*)

| ID | Name | Effort | Depends on | Status |
|---|---|---|---|---|
| A-1 | _(populate)_ | _S/M/L_ | _F-1, F-2_ | _PENDING_ |

### Cross-cutting tier (X-*)

| ID | Name | Effort | Depends on | Status |
|---|---|---|---|---|
| X-1 | _(populate)_ | _S/M/L_ | _F-*_ | _PENDING_ |

### Migration tier (M-*)

| ID | Name | Effort | Depends on | Status |
|---|---|---|---|---|
| M-1 | _(populate)_ | _S/M/L_ | _F-1_ | _PENDING_ |

---

## Per-slice detail template

Use this shape inside each slice's section:

```markdown
### F-1 — <slice name>

**Scope:** <what this slice delivers in concrete terms>

**Entities touched:** (cite `entity-model.md` §<sections>)
- ...

**Components built:** (cite `component-library.md` §<sections>)
- ...

**APIs implemented:** (cite `api-contracts.md` §<sections>)
- ...

**Hard-wired rules adopted:** (cite `rules-catalog.md` §<NN>)
- ...

**LLM integration:** (cite `llm-wiring.md` §<surface>) — N/A if no LLM
- ...

**Reference render / visual spec:** (cite `reference-renders/<filename>`)
- ...

**Depends on:** F-0, ...

**Effort tier:** S / M / L / XL

**Acceptance criteria:**
- ...
- ...

**Out of scope:**
- ...
```

---

## Dependency graph

(Generate a visual / ASCII graph as slices populate. ASCII example shape:)

```
F-1 ──┬─→ A-1 ──→ A-3
      ├─→ A-2 ──→ A-4
F-2 ──┴─→ A-5
X-1 (cross-cuts A-1 through A-5)
```

---

## See also

- `implementation-status.md` — per-slice status tracker (this plan is what to build; the status doc is what's built).
- `decisions.md` — decision log; slices reference D-* entries for binding rationale.
- `../process/handoff-checklist.md` — quality gates before merge.
- `../process/operational-patterns.md` — RUNBOOK conventions for executing a slice.
