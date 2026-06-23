# LAYERED.md — Cadence's two-layer model

Cadence ships in two complementary layers. Knowing which layer you're touching tells you what discipline applies.

```
cadence/                    ← Core engine (topology-agnostic)
├── AGENTS.md               ← binding contract
├── cadence.config.yml      ← feature manifest
├── FEATURES.md             ← feature catalog
├── design/                 ← canonical + features + process docs
├── memory/                 ← memory architecture + heartbeat
├── handoff/                ← session-to-session continuity
├── scripts-infra/          ← framework tooling (cadence.sh + role spawner)
└── examples/
    └── overture/           ← Reference instance layer (obfuscated worked example)
        ├── README.md
        ├── OBFUSCATION_POLICY.md
        ├── design/canonical/   ← what a fully-instantiated canonical/ looks like
        ├── design/catalog/     ← Storybook catalog as canonical baseline
        ├── frontend/           ← .storybook config + built static
        ├── scripts/            ← autonomy + operator brain implementations
        └── ...
```

---

## Layer 1 — Core engine

**What it is.** The pluggable framework. Every subsystem in `cadence.config.yml` (CORE + OPTIONAL features) lives here, abstracted, project-agnostic, ready to wire up against any product. Downstream projects depend on this layer; they import it, fork it, or copy it as their starting point.

**Discipline.**

- **Topology-agnostic.** No project names, no product personas, no domain-specific identifiers in core files. Use placeholders (`<PROJECT_NAME>`, `<DEVELOPER>`, `<GIT_HOST_URL>`) and generic role names (Orchestrator, Architect, Executor, Observer).
- **Every doc is portable.** If a Cadence doc only makes sense in the context of one specific product, it doesn't belong in core — it belongs in `examples/overture/` (or a downstream project's own corpus).
- **Feature-pluggable.** Subsystems get a `cadence.config.yml` flag, a `FEATURES.md` entry, and `scripts-infra/cadence.sh` path registration so they can be activated or pruned per-project.
- **Sync-engine maintained.** Drift between a real instance (workbench) and Cadence core surfaces as proposals in `sync-reports/`. Land them deliberately — don't let core drift on autopilot.

**Examples of what belongs in core.**

- Role contracts (Orchestrator, Architect, Executor, Observer, Memory Steward, Coordinator, QA-Agent, Resident Autonomy Agent — all named abstractly).
- The heartbeat ledger spec.
- Drift-class taxonomy and autonomy-gap framework.
- The CR authoring contract (CR shape, frontmatter schema, validation gates).
- The goal-runner contract (manifest shape, acceptance criteria pattern).
- The work-units hierarchy (Goal → Wave → Slice).
- The runtime-binding contract (tmux-backed role binding pattern).
- The route-delivery contract (canary ACK pattern).
- The reconciled-truth surface pattern.
- The visual-QA canonical-catalog architecture.

---

## Layer 2 — `examples/overture/`

**What it is.** A worked reference example of a fully-instantiated Cadence engine — what a real product running on Cadence looks like at scale. Storybook component catalog, persona contracts, anchor patterns, vocabulary discipline, an actual resident-autonomy implementation. It demonstrates how the core engine's abstract contracts get wired with product-specific DNA.

**Discipline.**

- **Study, don't depend.** Downstream projects read overture to learn the shape, not to import code. Treat it like a reference textbook, not a library.
- **Obfuscated.** Overture is derived from a real instance, but identifiers (project name, customer name, persona names, internal IDs, session IDs) have been scrubbed per `examples/overture/OBFUSCATION_POLICY.md`. Nothing in overture should leak the originating product.
- **No live state.** No real chronicles, no real heartbeat data, no actual session IDs. The shape of `memory/sessions/<agent>-<date>-<topic>.md` is shown via fictional examples; the patterns of heartbeat events are shown via illustrative excerpts.
- **Not on the sync engine's path.** Overture is a frozen artifact, not a live mirror. Updates to overture happen deliberately, not from automated drift detection.

**Examples of what belongs in overture.**

- A canonical-catalog Storybook + token system as a baseline-oracle exemplar for visual-QA validation.
- A multi-persona role-registry with persona-shaped contracts (showing how named personas inherit from abstract role contracts in core).
- Anchor-pattern docs (showing what page/screen-level canonical specs look like).
- Vocabulary discipline (showing how a glossary becomes load-bearing for in-product copy).
- An Operator Brain Python implementation (showing how the goal-runner contract gets executed in practice).
- A wave/goal/slice taxonomy in action across a real-shaped product backlog.

---

## When you're contributing

| You're touching... | Layer | Discipline applies |
|---|---|---|
| `AGENTS.md`, `cadence.config.yml`, `FEATURES.md`, `design/process/`, `memory/`, `scripts-infra/` | Core | Abstracted, portable, topology-agnostic |
| `design/canonical/decisions.md`, `design/canonical/implementation-*.md` | Core (project metadata) | Project-specific to Cadence itself; ok to reference Cadence by name |
| `design/canonical/<anything-else>` | Core | Patterns and contracts — keep portable |
| `design/features/` | Core | Feature-deep-dive template + actual features Cadence ships |
| `examples/overture/<anything>` | Overture | Obfuscated; no leakage from originating instance |
| `handoff/notes/`, `memory/heartbeat.md`, `memory/sessions/` | Core (Cadence's own state) | Cadence's actual operational state — not a layer artifact |
| `sync-reports/`, `.cadence-sync-last-run.md` | Core (gitignored per-instance) | Sync-engine output, scoped to this Cadence instance |

---

## Why this structure

Pure topology-agnostic frameworks are hard to learn from — abstraction without exemplars makes downstream projects guess at how to wire things. Pure operating-system forks bake too much product DNA into the framework, forcing downstream projects to strip rather than layer.

The two-layer model gets both: the engine stays portable (so new projects layer on); the overture stays vivid (so new projects can study a worked example). The obfuscation policy is what makes them coexist without leaking product internals.

See:
- `cadence.config.yml` + `FEATURES.md` — the feature manifest and catalog
- `examples/overture/README.md` — overture's contract with the reader
- `examples/overture/OBFUSCATION_POLICY.md` — the scrub rules
