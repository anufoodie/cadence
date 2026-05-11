# features/

Vertical deep-dives — one folder per feature topic. Each topic carries its own build spec, agent handoff, user stories, and references back to canonical docs.

**Status:** Empty. Populate one topic per feature as the project takes shape.

---

## How features relate to canonical/

`canonical/` holds horizontal foundation: durable nouns, decisions, surface patterns, rules, APIs. `features/` holds vertical deep-dives: how a specific feature works end-to-end, what user stories it satisfies, what the build sequence is for a coding agent.

**Cross-reference flow is one-way:** features reference canonical; canonical doesn't reference features. If you're tempted to cite a feature from a canonical doc, that's a sign the content should be lifted into canonical.

---

## Per-feature folder structure

Each feature folder has 5 files (template at `_template/`):

```
NN-<feature-slug>/
├── README.md           ← purpose, scope, status, owner, target surfaces
├── build-spec.md       ← end-to-end design
├── agent-handoff.md    ← coding-agent prep
├── user-stories.md     ← JTBDs + acceptance criteria
└── references.md       ← citations into canonical/ + flagged drifts
```

---

## Topic index

| # | Folder | Title |
|---|---|---|
| _(none yet)_ | _(none yet)_ | _(none yet)_ |

(Add rows as features are added.)

---

## How to add a new feature

1. Copy `_template/` to `NN-<feature-slug>/` where NN = next available number.
2. Fill `README.md` with purpose, scope, owner, target personas, and target surfaces.
3. Fill `user-stories.md` with the JTBDs and acceptance criteria.
4. Draft `build-spec.md` referencing canonical docs.
5. Identify drifts — places where this feature requires changes to canonical content. Flag in `references.md` for canonical reconciliation pass.
6. Once canonical is updated to absorb new entities / rules / surfaces, draft `agent-handoff.md` with slice plan.
7. Run `../process/consistency-checks.md` before submitting for review.

Full workflow at `../process/workflow.md`.

---

## See also

- `../canonical/` — horizontal foundation that features reference.
- `../process/workflow.md` — 5-stage workflow for incorporating new feature areas.
- `../process/conventions.md` — naming + Markdown style for feature docs.
- `_template/` — scaffold to copy when starting a new feature.
