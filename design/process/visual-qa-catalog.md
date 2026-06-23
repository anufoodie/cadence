# Visual-QA Canonical Catalog Architecture

**Status:** CANONICAL (process). Build↔QA validation architecture for projects with a visible UI surface.

**Owner pattern:** the project's QA-Agent or equivalent visual-QA role.

**When to use this.** When your project ships a UI and you want token-efficient, deterministic QA passes against a canonical reference (instead of open-ended multimodal vision reasoning every time). If your project doesn't ship UI, skip this whole pattern.

**Source.** This contract is the abstracted form of `handoff/notes/claude-code_to_async_2026-06-15-visual-qa-canonical-validation.md`, a design proposal that surfaced from a working session on how the resident QA role should validate UX output.

---

## §1. The core thesis

A canonical catalog turns QA from open-ended judgment into **reference comparison**. When known-good renders exist, validation is mostly "does this match the reference" — deterministic and cheap. Expensive multimodal vision reasoning becomes a *last resort*, not the default.

Two load-bearing moves make this real:

### Move 1 — The catalog is a baseline oracle

Each catalog story is a frozen canonical reference: **image + DOM + the tokens it consumes**. Snapshot the catalog **once** → baseline set for free; re-snapshot only when a story's hash changes.

- **Component fidelity** = "does this instance on the page match its story baseline?" → crop + pixel-diff. ~0 LLM tokens.
- **Page fidelity** = "is the composition legal — right components, right shell, right tokens, on grid?" → mostly structural / geometric.

### Move 2 — The build worker emits a composition manifest (verify, don't discover)

The single biggest token saver. The most expensive QA act is reverse-engineering a screen from pixels. Eliminate it: the build worker **declares** what it composed.

- **Manifest:** `page = Shell/AppFrame + [Card/elevated, Button/primary, DataTable/loading, …]` arranged per layout grid.
- **Provenance tags:** every rendered node carries `data-canonical-id` / `data-story` pointing at its catalog entry.

QA then *verifies a declared structure* instead of *discovering an unknown one* — far fewer tokens, and two checks become nearly free:

- **Off-catalog detection:** any node with no canonical tag = bespoke markup the build worker invented = coherence violation by definition (one DOM query).
- **Targeted comparison:** each tagged node maps directly to its baseline story.

## §2. Surface layout

```
catalog/                   ← the canonical reference (frozen baselines + tokens)
  components/
    <Component>.stories.tsx
    <Component>.baseline.png
    <Component>.tokens.json
  pages/
    <Page>.stories.tsx
    <Page>.baseline.png

build-output/              ← what the build worker emitted
  <page>.html
  <page>.composition-manifest.json
  <page>.render-screenshot.png

qa-output/                 ← what QA produced
  <date>-<scope>-qa-verdict.md
  diff-evidence/
```

## §3. Composition manifest shape

The build worker emits a manifest alongside each rendered page:

```json
{
  "page_id": "<canonical-page-name>",
  "rendered_at": "<ISO-timestamp>",
  "manifest_version": "1.0",
  "shell": "<canonical-shell-component>",
  "composition": [
    {
      "canonical_id": "<catalog-entry-id>",
      "story": "<storybook-path>",
      "instance_props": {...},
      "data_attrs": {"data-canonical-id": "...", "data-story": "..."}
    }
  ],
  "tokens_used": ["--ds-color-...", "--ds-spacing-..."],
  "net_new_components": [],
  "build_session_id": "<session>"
}
```

The manifest is **declared at build time**, not extracted post-render. The QA pass cross-references the declared manifest against the rendered output.

## §4. Validation cascade (deterministic-first)

QA runs the checks in this order, stopping at first failure or producing a layered verdict:

### Step 1 — Manifest presence (mandatory)

Manifest exists, well-formed, `page_id` matches the routed scope. **No manifest → reject the closeout, route back to build.**

### Step 2 — Off-catalog detection (DOM query)

Walk the rendered DOM. Every visible node must have `data-canonical-id` OR be inside a node that does. Bespoke markup without canonical provenance = coherence violation.

```
nodes_without_canonical = DOM_nodes − nodes_with_data_canonical_id
violations = filter nodes_without_canonical where not within_canonical_ancestor
```

### Step 3 — Per-component pixel diff (deterministic)

For each manifest entry:

1. Crop the rendered instance from the page screenshot.
2. Compare against `catalog/components/<Component>.baseline.png`.
3. Pixel-diff threshold: 95% match (configurable per component).

Fails route to "component-fidelity-failure" in the verdict.

### Step 4 — Token lint (deterministic)

Walk the page's computed-style for every visible node:

- Every `color`, `background`, `border-color` resolves to a `--ds-*` token defined in `tokens_used` OR a documented fallback.
- No bare hex outside fallback slots.
- No invented tokens.

### Step 5 — Geometry check (deterministic)

Compose against the declared layout grid. Verify each manifest entry is positioned at the declared grid coordinate. Off-grid placement = composition violation.

### Step 6 — Manifest-primed vision pass (one shot, optional)

Only if Steps 1-5 all pass and project policy requires a holistic check: one LLM vision call with the manifest as priming context. "Given the manifest below, does this rendered output satisfy it?" Single pass, fixed token budget, no follow-up calls.

This is the **last resort**, not the default. If your project's deterministic gates (Steps 1-5) are strong, skip this step entirely.

## §5. Transient artifact exclusion

Animations, cursor/focus indicators, transient hover states, in-flight transitions — these can cause false-positive pixel diffs. Document them as an opt-in dimension:

```yaml
# project's QA config
transient_dimensions:
  - cursor_position
  - focus_outline
  - hover_state
  - in_flight_animation_frame
```

By default, the cascade ignores these. A QA pass that wants to specifically validate transient behavior opts in.

## §6. Baseline invalidation

A story's baseline becomes stale when the story's source changes. The catalog tooling:

1. Hashes each `.stories.tsx` source on every build.
2. Compares against the stored hash for that baseline.
3. If hash changed → flag baseline as needing re-snapshot.

A baseline-needing-re-snapshot is the catalog steward's signal that the baseline must be re-blessed by orchestrator/user before the next QA pass uses it. Catalog evolution is **deliberate**, not silent.

## §7. Authority boundary

The visual-QA catalog system:

- **CAN** validate rendered output against declared manifests + frozen baselines.
- **CAN** emit verdicts (`pass` / `needs-work` / `fail`) with per-component evidence.
- **CAN** flag missing manifests, off-catalog nodes, token violations.
- **CANNOT** modify the catalog (steward authority).
- **CANNOT** approve graduation (orchestrator authority).
- **CANNOT** rewrite the manifest (build authority).

QA-Agent verdicts are inputs alongside baseline-to-delta evidence, finding traceability, repeat probes, and runtime proof. The orchestrator retains the graduation call.

## §8. Project-specific configuration

A project adopting this pattern needs:

1. A canonical catalog (Storybook or equivalent) holding frozen reference renders.
2. A build-side composition manifest emitter (project-specific build hook).
3. A QA-side validation cascade tool (project-specific QA agent).
4. A token system that the build composes from (no hand-rolled CSS values).
5. A baseline hash + invalidation pipeline.

All are project-specific. This doc defines the *architecture*; implementations live downstream.

## §9. See also

- `cr-authoring-contract.md` §2.3 — composition manifest CR fields.
- `agent-roles.md` — QA-Agent role contract.
- `runtime-binding.md` — QA-Agent runtime binding.
- `operational-patterns.md` — visual-match-by-screenshot discipline.
- The 2026-06-15 source brief at `handoff/notes/claude-code_to_async_2026-06-15-visual-qa-canonical-validation.md` (for design rationale).
