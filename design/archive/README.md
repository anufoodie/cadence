# archive/

Historical design artifacts. **Read-only reference** — superseded by `canonical/` but preserved for context, audit, and decision-history reconstruction.

**Status:** Empty. Populate as the project accumulates superseded artifacts.

---

## What goes here

- **Superseded specs** — earlier versions of canonical docs that were significantly rewritten. Preserved for archaeology rather than reference.
- **Bridge docs** — point-in-time migration plans, restructure logs, gap analyses (typically date-named: `YYYY-MM-DD-<short-name>.md`).
- **Phase artifacts** — phase-numbered files from early design phases (e.g., `phase-5a-*.md`) that have been content-renamed and re-homed into canonical.

## Cross-reference contract

Archive content is **informational only**. Citations from canonical/ or features/ into archive/ are acceptable for historical context but **must not bind current decisions**. If you find yourself wanting to cite archive/ to justify current behavior, the source content needs to be re-homed into canonical first.

## File naming

- Date-anchored for bridge docs: `YYYY-MM-DD-<short-name>.md`.
- Content-named for superseded specs: same as `canonical/` naming, optionally with `-v1` suffix if multiple versions existed.

## Subfolders

These two subfolders are worth replicating as your project grows:

| Folder | Purpose |
|---|---|
| `bridge-docs/` | Point-in-time migration plans and restructure logs (date-named) |
| `<topic>-amendments/` | Per-topic amendment files that superseded into canonical |

Create them on first use.
