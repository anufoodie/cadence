# Brief — Canonical-Catalog Visual QA: Build↔QA Validation Architecture

**Authored by:** Claude Code (Opus 4.8, 1M context) — maintenance/advisory session, 2026-06-15.
**Target:** Async Architect (Codex CLI) — for architectural consideration, not immediate build.
**Status:** brief / design proposal. Captures a discussion with Anu on how the resident QA session should validate UX output against the canonical Storybook catalog. No code authored; this is for async to evaluate, refine, or push back on before anything is specced into a slice.
**Working state at brief time:** Cadence repo on `anu-singh`; pluggable-engine feature toggles just landed (commit `bf3f6ef`). This brief proposes a *future* feature, not a change to what shipped.

---

## §1. Context — why this came up

Anu asked how to make the resident QA session "next level good" at testing UX thoroughly — every clickable state and its screen view, coherence, and no weird mouse/cursor/render artifacts — in a **token-efficient, dead-simple** way.

The key constraint Anu supplied: **there is a Storybook server holding a "canonical" catalog** — shell, design tokens, components. The intended division of labor:

- **Build worker sessions** compose a page/screen *from* canonical Storybook components.
- **QA session** validates the composed output *against* canonical, at two levels: **component-level fidelity** and **page/screen-level fidelity**.

The design goal is that **every QA pass is cheap and simple**. That goal is the thing to optimize for; everything below serves it.

---

## §2. Core thesis (the two load-bearing moves)

**A canonical catalog turns QA from open-ended judgment into reference comparison.** When known-good renders exist, validation is mostly "does this match the reference" — deterministic and cheap. Expensive multimodal vision reasoning becomes a *last resort*, not the default. Two moves make this real:

### Move 1 — The catalog is a baseline oracle
Each Storybook story is a frozen canonical reference: image + DOM + the tokens it consumes. Snapshot the catalog **once** → baseline set for free; re-snapshot only when a story's hash changes.
- **Component fidelity** = "does this instance on the page match its story baseline?" → crop + pixel-diff. ~0 LLM tokens.
- **Page fidelity** = "is the composition legal — right components, right shell, right tokens, on grid?" → mostly structural/geometric.

### Move 2 — The build worker emits a composition manifest (verify, don't discover)
The single biggest token saver. The most expensive QA act is reverse-engineering a screen from pixels. Eliminate it: the build worker **declares** what it composed.
- **Manifest:** `page = Shell/AppFrame + [Card/elevated, Button/primary, DataTable/loading, …]` arranged per layout grid Y.
- **Provenance tags:** every rendered node carries `data-canonical-id` / `data-story` pointing at its catalog entry.

QA then *verifies a declared structure* instead of *discovering an unknown one* — far fewer tokens, and two checks become nearly free:
- **Off-catalog detection:** any node with no canonical tag = bespoke markup the build worker invented = coherence violation by definition (one DOM query).
- **Targeted comparison:** each tagged node maps directly to its baseline story.

> **The real design is the build↔QA contract, not the QA logic.** A disciplined build worker (compose-only-from-canonical, tag everything, emit manifest + live preview URL) makes QA almost free. An undisciplined one forces QA into expensive pixel archaeology. **Highest-leverage spec target = that contract.**

---

## §3. The validation cascade (deterministic-first; vision is the last 10%)

Order checks cheapest-and-most-certain first; short-circuit on failure.

**Component level — deterministic, ~0 tokens**
1. For each tagged node: crop bounding box, pixel-diff vs its story baseline. Mismatch → component drift.
2. **Token lint:** scan computed styles for any color/spacing/type value not in the token set (catches hardcoded `#3a3a3a` instead of `--color-fg`). Pure CSS check.
3. **Off-catalog scan** (§2, Move 2).

**Page level — structural/geometric, still ~0 tokens**
4. **Shell conformance:** is the page built on the canonical `AppFrame`/nav/grid? DOM-structural diff vs shell story.
5. **Composition geometry:** section spacing on the token grid, no overlap, nothing clipped/off-canvas, breakpoints hold. Bounding-box math.

**Residual vision — the only LLM-heavy step, only if 1–5 pass**
6. One multimodal pass on the full screen for what only an eye catches (visual hierarchy, awkward whitespace, holistic coherence). **Feed the manifest as context** so it judges against declared intent — improves accuracy *and* cuts tokens.

Most passes never reach step 6; failing passes short-circuit before it.

### The transient-artifact class (cursor / hover / animation)
Stills miss ghost cursors, sticky `:hover`, orphaned focus rings, repaint flashes, animation jank. These need **time, not a snapshot**: record video / sample frames while scripting a pointer path (hover in-out, fast re-entry, pointer-leaves-window, focus→blur), then diff consecutive frames. Honest limit: this is where automation is weakest — realistic goal is to **surface candidate frames to a human**, not be the final eye. Recommend treating this as a *separate, opt-in* QA dimension, not part of the cheap default pass.

---

## §4. Token-efficiency levers (the explicit ask)

- **Deterministic-first:** diff + lint catch the large majority at zero LLM cost.
- **Manifest verification ≫ pixel discovery:** verifying structure is a fraction of inferring it.
- **Diff-only vision:** when the model is called, send changed/suspect **crops**, never full-page screenshots — images dominate token cost.
- **Baseline caching:** snapshot the catalog once; reuse across every page; invalidate by story hash.
- **QA the delta only:** validate what changed vs the last approved composition, not the whole app each pass.
- **Short-circuit:** cheapest failing check wins; skip downstream steps.

---

## §5. How this maps onto existing Cadence/grove concepts

- This is `visual-canonical-reconciliation` made concrete: **component drift** = reconcile instance vs its story; **page drift** = reconcile composition vs layout canon.
- The QA output unit is the existing **walk packet**: failing crop + the canonical baseline it diffed against + the manifest line that declared it + accept/reject + repro. Already contract-required per AGENTS.md §0.7(2) in grove.
- Recurring component-drift patterns should be **named as visual-drift classes** (observe → name → mitigate → codify), so QA stops re-finding known artifacts.
- If adopted into Cadence, this is a natural **toggleable feature** (`qa_visual` or similar) in `cadence.config.yml`, with a QA-session contract in `agent-roles.md` and a checklist in `design/process/`.

---

## §6. In scope for async to consider

- Whether the **manifest + provenance-tag contract** is the right build↔QA interface, and what its minimal schema should be (`data-canonical-id`, story ref, token usage — what else?).
- Where **baselines live** and how **story-hash invalidation** is triggered (Storybook build output? a committed snapshot dir? CI artifact?).
- The **cascade boundary**: exactly which checks are deterministic vs which legitimately need vision, and the short-circuit policy.
- Whether transient-artifact (cursor/animation) QA is in v1 or deferred.

## §7. Explicitly OUT of scope

- No code, no Storybook config, no MCP wiring authored here.
- No change to the shipped pluggable-engine toggles (`bf3f6ef`).
- Not proposing a specific visual-diff tool/library — async's call.

---

## §8. Open questions (flag, don't decide unilaterally)

1. **Build-worker discipline enforcement** — is "compose only from canonical, tag everything" a *lint gate* (CI rejects untagged nodes) or a *QA finding* (caught after the fact)? Gate is cheaper long-term but pushes cost onto build sessions.
2. **Baseline drift authority** — when a component instance legitimately differs from its story (intentional new variant), who approves promoting it into canonical, and how does QA tell "intended variant" from "drift"? This is the HITL boundary.
3. **Composed-page hosting** — does the build worker render the composed page *as a Storybook story/route* (so QA hits a stable preview URL), or as a separate app build? The former keeps the "everything is a story" symmetry and one capture path.
4. **Smallest-window constraint** — per the 2026-05-11 context-budget brief, Codex (~272k) is the binding constraint. Confirm the per-pass QA token budget holds for an async Codex session, not just Opus.

---

## §9. Cross-references

- `handoff/notes/claude-code_to_next_2026-05-11-context-budget-tightening.md` — token-budget discipline; §8 Q4 above depends on it.
- `cadence.config.yml` / `FEATURES.md` — where a `qa_visual` toggle would land if adopted.
- grove `design/process/visual-canonical-reconciliation.md` + AGENTS.md §0.7(2) walk-packet contract — the existing concepts this concretizes.
- Commit `bf3f6ef` — pluggable-engine feature toggles (the pattern a `qa_visual` feature would follow).

---

*Brief only — no authorization to build. Append an `## Outcomes` block here when async takes a position or this lands as a slice.*
