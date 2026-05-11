# Conventions

Naming + Markdown style + cross-reference rules for the design corpus. **Binding** — these conventions govern how files are named, where they live, how they reference each other.

**Authority status:** CANONICAL (process).

---

## §1. Folder structure

Five top-level folders under `design/`. **No new top-level folders without an explicit decision.**

- `canonical/` — horizontal foundation (decisions, ADRs, project-specific spec content — anchor patterns, entity model, rules catalog, etc. as your project requires).
- `features/` — vertical deep-dives (per-feature build specs, agent handoffs, user stories, references back to canonical).
- `process/` — operating manual (this folder).
- `archive/` — historical artifacts, read-only.
- `references/` — supporting material (idea registers, glossary).

Subfolders inside the five top-level follow the same kebab-case + content-named conventions.

## §2. File naming

1. **Lowercase kebab-case.** `entity-model.md`, not `EntityModel.md` or `entity_model.md`.
2. **Content-named, not process-named.** `entity-model.md` — not `phase-5a-entity-model.md`. Phase numbers describe how something was made, not what it is.
3. **No phase numbers in filenames.** Anywhere. Phases are process metadata, not content metadata.
4. **No dates in filenames.** Exception: `archive/bridge-docs/` where dates serve as historical anchors (`YYYY-MM-DD-<short-name>.md`).
5. **Numbered series for ordered sets.** `NN-<slug>.md` — e.g., features `01-<feature>/` through `NN-<feature>/`.
6. **Skip a number** when a position was reserved but never authored. Don't renumber to close the gap — preserves original taxonomy lineage.
7. **READMEs everywhere.** Every folder has a `README.md` that indexes contents, describes purpose, and links to siblings.

## §3. Cross-references

1. **Reference by path, never by description.** Write `canonical/anchor-patterns/01-<anchor>.md`, not "the X pattern doc".
2. **Use relative paths from the citing file's location.**
   - Inside `canonical/`: refer to peer files by leading `./` (e.g., `./decisions.md`) or omitted prefix (`decisions.md`).
   - Inside `canonical/<subfolder>/<file>.md`: parent refs use `../<sibling>.md`, etc.
   - Inside `features/<topic>/<file>.md`: refs into canonical use `../../canonical/...`.
3. **One direction only.** `features/` references `canonical/`; `canonical/` does NOT reference `features/`. If a canonical doc is tempted to cite a feature, the content should be lifted into canonical.
4. **External material is informational, not authoritative.** `references/` is supporting; `archive/` is historical. Citations into either are fine but do not bind decisions.

## §4. Authority hierarchy

Decisions land in this order of authority (adapt per project):

1. **Locked visual specs** (if your project has them — e.g., `canonical/reference-renders/`) — supreme fidelity authority for visual decisions. When prose conflicts with locked visual, locked visual wins.
2. **Cross-cutting rules** (e.g., `canonical/shell-rules.md` — rules every surface obeys).
3. **Surface patterns** (e.g., `canonical/anchor-patterns/` — per-screen / per-module patterns).
4. **Entity + rule + API + component canonical docs** — implementation-grade specs.
5. **Decision log** (`canonical/decisions.md`) — append-only record of decisions with rationale.
6. **ADRs** (`canonical/adrs/`) — architecture decision records (longer-form than decision-log entries).
7. **Feature build specs** (`features/<topic>/build-spec.md`) — vertical deep-dives, depend on canonical.

When two canonical docs conflict, the more specific one wins.

## §5. Decision logging

1. **Append-only.** Never delete or rewrite a decision-log entry. Revisions append a new entry that supersedes.
2. **Format:** `D-<TOPIC>-<NN>` identifier, status (`PROPOSED` / `LOCKED` / `SUPERSEDED` / `DEFERRED`), rationale, next actions.
3. **Date stamp.** Every locked entry carries a "Locked at:" date.
4. **No retroactive rule application.** A new rule applies to surfaces locked after the rule's lock date, not before.

## §6. Feature folders

Each feature folder has 5 files (template at `features/_template/`):

```
NN-<feature-slug>/
├── README.md           ← purpose, scope, status, owner, target surfaces
├── build-spec.md       ← end-to-end design
├── agent-handoff.md    ← coding-agent prep
├── user-stories.md     ← JTBDs + acceptance criteria
└── references.md       ← citations into canonical/ + flagged drifts
```

Topics may carry additional artifacts as needed but not required.

## §7. Markdown style

1. **Headers cascade naturally.** `# Title` for file title; `## Section` for major sections; `### Subsection` for sub. Avoid going deeper than `####` unless content demands.
2. **Tables for structured comparisons**, prose for narrative. Don't force-fit narrative into tables.
3. **Code blocks** for path references, command examples, schema snippets. Always specify language for syntax highlighting.
4. **Bullet lists** for parallel items; numbered lists for ordered steps. Don't mix bullet styles within a list.
5. **Inline code** (single backticks) for file paths, identifiers, short literal strings.
6. **Block quotes** (`>`) for callouts: status notes, warnings, key principles. Open with bold label: `> **Status:** ...`, `> **Note:** ...`.
7. **Horizontal rules** (`---`) separate distinct sections. Don't sprinkle decoratively.
8. **Trailing newline** at end of every file.

## §8. Updating canonical docs

Canonical docs evolve. When updating:

1. **Read the current version first.** Don't rewrite from memory.
2. **Append, don't restructure.** Existing content stays in place to preserve cross-references.
3. **If restructuring is necessary**, capture it as a decision-log entry first, then execute as a deliberate stage with its own commit.
4. **Verify cross-references** after any move or rename. Run a grep for the old path/name.
5. **Locked visual specs supersede** when prose conflicts. Update the prose, not the spec.

## §9. Conventions for `process/` itself

- This folder's docs are operating manual, not source of truth for product decisions. Product decisions live in `canonical/`.
- Process docs evolve as we learn what works.
- Disagreement between process and canonical: process loses. Canonical is binding.
