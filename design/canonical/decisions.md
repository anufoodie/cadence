# Decision Log

This log captures product/UX/process decisions made during the project lifecycle. **Append-only**; corrections happen via new entries that supersede prior ones.

> **ADRs (Architecture Decision Records) are a separate format that complements this log:** longer-form, narrower scope (architecture / stack / infra), with explicit Context / Decision / Consequences sections. ADRs live at `adrs/`. Use a `D-*` entry here for product/UX/process decisions; use an ADR for architecture/stack decisions that need fuller treatment. Cross-reference between the two when a product decision has architecture implications.

---

## Entry format

```
- [YYYY-MM-DD] D-<TOPIC>-<NN> — <decision title>
  Status: PROPOSED | LOCKED | SUPERSEDED | DEFERRED
  Locked at: <YYYY-MM-DD>            (only when status is LOCKED)
  Decision: <what was decided>
  Affects: <docs/sections/topics impacted>
  Rationale: <one or two sentences>
  Source synthesis: <pointer into the synthesizing artifact>
  Next action: <execution pass description>
  Supersedes: <prior D-* entry, if any>
```

### Conventions

- **`D-<TOPIC>-<NN>`** identifier. Topic is short and stable (`D-ENTITY-NAMING`, `D-TRACK-MODEL`, `D-PERSONA-NAMES`). `NN` is a sequence number only if you have multiple decisions on the same topic; usually omitted.
- **Append-only.** Never delete or rewrite a locked entry. Revisions append a new entry that supersedes (use the `Supersedes:` field).
- **Date stamp.** Every locked entry carries a `Locked at:` date.
- **No retroactive rule application.** A new rule applies to surfaces locked after the rule, not before.

---

## YYYY-MM-DD (initial population — empty)

_No decisions logged yet. Append the first decision below as work begins._

---

## See also

- `adrs/` — Architecture Decision Records.
- `../process/workflow.md` — 5-stage workflow; Stage 2 (Reconcile) produces decision-log entries.
- `../process/conventions.md` §5 — decision-logging conventions.
- `../../memory/INDEX.md` — decision-log summary (1-line each) for quick reference; full entries live here.
