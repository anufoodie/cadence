# adrs/

Architecture Decision Records. **Load-bearing decisions** that warrant fuller treatment than a one-line entry in `../decisions.md`.

## When to use an ADR vs. a `D-*` entry

| Use a `D-*` entry in `decisions.md` when | Use an ADR here when |
|---|---|
| The decision is product / UX / workflow scoped | The decision is architecture / stack / infra scoped |
| One or two sentences of rationale suffice | You need Context + Decision + Consequences sections |
| The decision is reversible at low cost | The decision binds infrastructure or shapes the system long-term |
| The audience is design + product | The audience includes engineering leadership |

Cross-reference between the two when a product decision has architecture implications.

## File naming

```
ADR-YYYY-MM-DD-<short-slug>.md
```

Example: `ADR-2026-05-07-architecture-pivot.md`, `ADR-2026-04-23-r2-stack.md`.

## Template

```markdown
# ADR-YYYY-MM-DD — <title>

**Status:** PROPOSED | LOCKED | SUPERSEDED
**Locked at:** YYYY-MM-DD            (only when status is LOCKED)
**Authors:** <names>
**Supersedes:** ADR-<prior>, if any
**Superseded by:** ADR-<successor>, if any

## Context

What's the situation that requires a decision? What forces are at play (technical, organizational, regulatory)? What constraints?

## Decision

What we're doing. Specific. Names the chosen path.

## Alternatives considered

What we evaluated and rejected. One paragraph each; brief rationale.

## Consequences

What follows from this decision — positive, negative, neutral. Be honest about tradeoffs. Note what becomes harder, not just what becomes easier.

## Implementation notes

(Optional) Concrete next steps, file changes, or migration sequence.

## References

- Related `D-*` entries in `../decisions.md`
- Related canonical docs
- External material consulted
```

## See also

- `../decisions.md` — append-only product/UX/process decision log.
- `../README.md` — canonical foundation index.
