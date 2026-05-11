# memory/drift-reports/

Daily drift reports from the memory steward.

**Convention:** one file per steward run, named `YYYY-MM-DD-drift.md` (and `-r2.md`, `-r3.md` etc. for multiple runs the same day).

## What's in a drift report

The memory steward writes a structured drift report each run per `../../design/process/scheduled-tasks/memory-steward-prompt.md` §7. Categories include:

- `MISSING_DECISION` — decision-shaped commit message without a `D-*` entry in `decisions.md`
- `EMPTY_CHRONICLE` — chronicle file with no log entries
- `CONTRADICTORY_STATUS` — chronicle Status field contradicts observable activity
- `MALFORMED_CHRONICLE` — chronicle missing required sections / broken markdown
- `MISSING_HANDOFF_OUTCOMES` — handoff brief references shipped slice with no Outcomes section
- `DRIFT_RETIREMENT_CANDIDATE` — drift ID's source path no longer exists or a commit claims to resolve it
- `INDEX_STALE_ON_ENTRY` — INDEX.md "Last updated" lagged the newest commit by >24h
- `STATUS_MISMATCH` — INDEX.md slice status disagrees with canonical implementation-status.md

## Update discipline

- **Append-only.** Reports are written once per run; never edited after the fact. If a drift gets resolved, that's captured in the NEXT day's report (drift-ID disappears from the open list).
- **Detect, don't resolve.** The steward surfaces drift; working agents and the user resolve it.
- **Archival:** old reports stay in this directory. The steward may roll them up into a yearly archive when this directory exceeds ~90 entries (deferred enhancement).

## See also

- `../README.md` — memory architecture overview.
- `../../design/process/scheduled-tasks/memory-steward-prompt.md` — full steward contract.
- `../../design/process/drift-classes.md` — taxonomy of drift classes (broader than the steward's daily categories).
