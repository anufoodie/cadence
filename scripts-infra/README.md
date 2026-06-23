# `scripts-infra/` — Cadence framework tooling

This directory holds tooling that the Cadence engine itself ships, plus reference stubs for project-specific implementations.

## What ships here

### Working tools

- **`cadence.sh`** — Feature toggle + onboarding tool. `status` / `enable` / `disable` / `init` / `doctor`. Drives `cadence.config.yml`. See [`FEATURES.md`](../FEATURES.md).
- **`spawn-agent.sh`** — Reference launcher for an Observer session (when `observer_loop` feature is on). Project-agnostic; symlinks/copies cleanly into a downstream project.

### Reference stubs (contract documentation)

Cadence ships the **contracts** for several subsystems (in `design/process/`); the actual workers are project-specific because they depend on your project's runtime, languages, and conventions. These stubs document the interface a project's worker must satisfy:

- **`cr-lint.example.sh`** — CR-lint tool stub. Contract: [`cr-authoring-contract.md`](../design/process/cr-authoring-contract.md).
- **`reconciled-truth.example.sh`** — Reconciled-truth surface stub. Contract: [`reconciled-truth.md`](../design/process/reconciled-truth.md).
- **`runtime-route.example.sh`** — Route-delivery stub. Contract: [`runtime-route.md`](../design/process/runtime-route.md).

To implement these in your project:

```bash
# Copy the stub
cp scripts-infra/cr-lint.example.sh scripts-infra/<your-prefix>-cr-lint

# Implement the contract (typically a Python worker behind a shell launcher)
# The worker reads inputs, applies deterministic rules, emits output per
# the contract doc.

# Register with the feature catalog
./scripts-infra/cadence.sh enable cr_authoring_contract
```

For a worked obfuscated example of full implementations, see [`examples/overture/scripts/`](../examples/overture/scripts/).

## Discipline

- **Scripts in core are topology-agnostic.** No project names, no product personas, no domain-specific paths. Use placeholders or environment variables.
- **Real implementations belong in your project's `scripts-infra/`**, named with your project prefix. Cadence ships the contract; you ship the worker.
- **`*.example.sh` files are stubs by convention.** They name the contract, show the interface, and exit cleanly without doing real work.

## See also

- [`FEATURES.md`](../FEATURES.md) — what each feature toggle owns.
- [`cadence.config.yml`](../cadence.config.yml) — live on/off state.
- [`design/process/`](../design/process/) — contracts the stubs reference.
- [`examples/overture/scripts/`](../examples/overture/scripts/) — worked obfuscated implementations.
