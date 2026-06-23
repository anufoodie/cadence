# Overture — Cadence reference instance

This subtree is a **worked example** of a real product running on the Cadence engine. It shows how the abstract contracts in `cadence/design/process/` and the feature toggles in `cadence/cadence.config.yml` get wired up with product-specific DNA — persona contracts, anchor patterns, vocabulary discipline, Storybook catalog, an Operator Brain implementation, a wave/goal/slice backlog in flight.

It is **not a dependency**. Downstream projects don't import overture. They read it like a textbook: "ah, that's what a fully-instantiated Cadence looks like; here's how I'd shape my own."

## What's in here

| Directory | Mirrors core file | What overture shows |
|---|---|---|
| `design/canonical/` | `cadence/design/canonical/` | A fully populated canonical corpus — anchor patterns, vocabulary, role-registry, persona contracts |
| `design/catalog/storybook/` | (no core equivalent) | The canonical Storybook catalog — design tokens + components used as the visual-QA baseline oracle |
| `design/process/` | `cadence/design/process/` | Process docs that wire the core contracts to the fictional product (build-cadence, design-bar, etc.) |
| `frontend/` | (no core equivalent) | Storybook tool config + built static — what the visual-QA-catalog feature consumes |
| `scripts/operator_brain/` | (no core equivalent) | A working implementation of the `goal_runner` + `resident_autonomy` core contracts |
| `scripts/infra/` | `cadence/scripts-infra/` | Product-specific infra scripts (knowledge-layer bridge, operator-brain CLI, lane resolver) — fictionalized |
| `memory/sessions/` | `cadence/memory/sessions/` | A handful of illustrative chronicle excerpts (fictional, not real session data) |
| `handoff/notes/` | `cadence/handoff/notes/` | Illustrative handoff and commit-request examples |

## Obfuscation

Everything in here has been scrubbed per [`OBFUSCATION_POLICY.md`](OBFUSCATION_POLICY.md). Identifiers replaced with fictional analogs:

| Originating instance | Overture analog |
|---|---|
| Product name | **Atlas** (fictional professional-services automation platform) |
| Owner / sponsor | Anu Singh (preserved — Cadence's own developer, not an obfuscation target) |
| Customer name | **Globex Corp** (fictional enterprise customer) |
| PM persona | **Engagement Lead** |
| DL persona | **Delivery Manager** |
| Consultant persona | **Field Specialist** |
| Lead Consultant persona | **Practice Lead** |
| Internal canonical IDs (`D-FOO-NN`) | `OV-D-FOO-NN` prefix (overture-namespaced) |
| Real session IDs | `cw-YYYY-MM-DD-fictional-topic` shape |
| Real commit SHAs | Stylized placeholder hashes (`ovsha-abc123`) or omitted |

No real heartbeat data, no real chronicles, no real commit-request content carries over. Only the *shape*.

## How to read this

Three useful entry points depending on what you're studying:

1. **"What does a fully-instantiated Cadence canonical corpus look like?"**
   Start: `design/canonical/README.md`, `design/canonical/role-registry.md`, `design/canonical/vocabulary.md`, walk through one anchor in `design/canonical/anchor-patterns/`.

2. **"How does a visual-QA canonical catalog actually work?"**
   Start: `design/catalog/storybook/README.md`, then `frontend/.storybook/`, then `design/process/visual-qa-catalog.md` in core for the abstract contract, then come back here for the concrete catalog.

3. **"How does the Resident Autonomy Agent execute against a goal-runner manifest?"**
   Start: `scripts/operator_brain/README.md` (overture-side), then `design/process/autonomy-goal-runner.md` (core), then trace a fictional goal at `handoff/notes/goals/` through child CRs.

## Constraints

- **No live state.** Don't run any script in here expecting it to do real work — paths, identifiers, and references are obfuscated; integration points (Ollama, Codex CLI, external APIs) are pointed at placeholder hosts.
- **No upstream dependencies.** Overture references only itself + Cadence core. If a doc here points at something outside `examples/overture/` or `cadence/<core-paths>`, that's a leak — file a sync-engine drift note.
- **Don't propose changes to overture from sync.** Overture is frozen at the time it was authored; sync proposes core changes only. Refreshing overture is a deliberate authoring action, not a drift signal.

See `LAYERED.md` (Cadence root) for the broader two-layer model and which discipline applies where.
