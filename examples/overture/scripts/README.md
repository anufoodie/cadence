# Atlas — autonomy + tooling scripts (overture reference)

> **Overture reference instance — obfuscated.** Fictional implementations of Cadence contract stubs. Atlas-specific paths, env-vars, and identifiers throughout — illustrative only.

This subtree shows what working implementations of the Cadence stub contracts look like in a real product. Each implementation pairs with a contract doc in core Cadence (`design/process/*.md`).

## What's here

### Operator Brain (the resident autonomy LLM advisory)

```
operator_brain/
├── brain.py                    # main worker — reads heartbeat, queues, manifests; emits advisory packets
├── reconciled_truth.py         # Atlas's reconciled-truth implementation (contract: reconciled-truth.md)
├── goal_runner.py              # Atlas's goal-runner implementation (contract: autonomy-goal-runner.md)
├── decide_stack.py             # specific advisory: stack-choice analysis
└── README.md
```

Atlas's Operator Brain is a Python worker that runs in the runtime binding (one tmux session, `atlas-operator-brain`). It reads heartbeat tail + queue state + goal manifests every poll cycle and emits **advisory packets** to heartbeat. The advisory packets are recommendations only; the resident autonomy loop honors them only when deterministic gates pass.

The brain implements the LLM-assisted advisory layer; the deterministic control plane lives in the autonomy loop (`autonomy_loop.py` below).

### Resident autonomy loop

```
autonomy/
├── autonomy_loop.py            # deterministic control plane (contract: resident-autonomy.md)
├── route_writer.py             # route delivery (contract: runtime-route.md)
└── state.json                  # last-tick state for restart recovery
```

The autonomy loop is what gets routes into executors without a human in the chair. It reads reconciled-truth, applies the admission gate, emits one route per tick (60s default), respects backoff and duplicate suppression.

### Runtime binding

```
runtime/
├── runtime_launch.sh           # cold-boot the tmux runtime (contract: runtime-binding.md)
├── role_health.py              # per-role health probes
├── route.py                    # send a route to a bound session
└── runtime.json                # role registry
```

The runtime registry (`runtime.json`) names the 12 persistent Atlas roles + their tmux session bindings + colors + cwd + launch commands. Cold boot creates each session per the registry.

### Per-tool implementations

```
tools/
├── cr_lint.py                  # CR-lint worker (contract: cr-authoring-contract.md)
├── composition_check.py        # composition manifest validator (contract: visual-qa-catalog.md)
├── lane_digest.py              # lane reconciliation digest
├── loop_doctor.py              # autonomy loop repair (wake-check + restoration)
└── chronicle_closeout.py       # chronicle closeout guard (RUNBOOK Entry 29)
```

Each pairs with a Cadence core contract.

### Visual-QA implementation

```
qa/
├── canonical_validator.py      # visual-QA validation cascade (contract: visual-qa-catalog.md)
├── pixel_diff.py               # deterministic pixel-diff worker
├── token_lint.py               # token-lint worker
├── geometry_check.py           # composition geometry validator
└── manifest_primed_vision.py   # last-resort manifest-primed vision pass
```

Atlas's QA-Agent invokes the validator on each routed scope. The validator runs Steps 1-5 deterministically; Step 6 (vision pass) only when explicitly required.

## How Atlas wires these

Atlas's `cadence.config.yml` (in its real repo, not in this overture) has these features ON:

```yaml
features:
  # CORE
  operating_contract: on
  memory_index: on
  design_corpus: on
  handoff_notes: on

  # OPTIONAL
  heartbeat: on
  session_chronicles: on
  worktrees: on
  roles_full: on
  memory_steward: on
  drift_taxonomy: on
  autonomy_framework: on
  observer_loop: off       # Atlas uses resident_autonomy instead
  sync_engine: on          # Atlas pulls Cadence framework changes
  gpg_signing: on

  # EXTENDED
  work_units: on
  goal_runner: on
  cr_authoring_contract: on
  runtime_binding: on
  runtime_route: on
  reconciled_truth: on
  resident_autonomy: on
  visual_qa_catalog: on
  layered_overture: off    # Atlas doesn't ship its own overture
```

This is the maximalist instance — every advanced subsystem on because Atlas runs multi-agent autonomy at scale. A smaller project would have far fewer features on.

## How this shape demonstrates the Cadence pattern

This subtree shows what implementing the Cadence contracts looks like at full scale. A downstream project building its own thing on Cadence reads core contracts (in `cadence/design/process/`) and writes its own implementations against them. The Atlas implementations here are reference — not imports.

The implementations are also where the abstraction shows its limits: the contracts are clean and portable; the implementations are specific to Atlas's Python stack, tmux runtime, Voyage AI embeddings, and product personas. A project on a different stack writes different implementations against the same contracts.
