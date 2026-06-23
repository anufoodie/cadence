# Atlas — Storybook canonical catalog (overture reference)

> **Overture reference instance — obfuscated.** Fictional component catalog illustrating the canonical-catalog pattern from core `visual-qa-catalog.md`.

This is the **canonical catalog** Atlas's visual-QA pass validates against. Every component and page has a frozen baseline render here; rendered output from build workers is verified against these baselines.

## What's here

```
storybook/
├── tokens/
│   ├── colors.json          # canonical design tokens (--ds-color-*)
│   ├── spacing.json         # canonical spacing scale
│   └── typography.json      # canonical type scale
├── components/
│   ├── Button/
│   │   ├── Button.stories.tsx
│   │   ├── Button.baseline.png      # frozen reference render
│   │   └── Button.tokens.json        # tokens this component consumes
│   ├── Card/
│   │   └── ...
│   ├── DataTable/
│   ├── Badge/
│   ├── Stack/
│   ├── Surface/
│   ├── HealthPill/                  # Atlas-specific composed
│   ├── TgateChip/                   # Atlas-specific composed
│   └── ...
├── pages/
│   ├── EngagementOverview/
│   │   ├── EngagementOverview.stories.tsx
│   │   ├── EngagementOverview.baseline.png   # frozen reference render
│   │   └── EngagementOverview.composition.json
│   └── ...
└── catalog-hash.json          # source hash per story for baseline invalidation
```

## How Atlas uses the catalog

Per the pipeline from core `visual-qa-catalog.md`:

1. **Build worker** composes a page from catalog components:

   ```tsx
   import { Stack, Surface, Card } from '@atlas-ds/react';
   import { HealthPill, TgateChip } from '@atlas/catalog/components';

   <Surface>
     <Stack>
       <HealthPill state="on-track" />
       <TgateChip nextGate="T-3" />
       <Card variant="elevated">...</Card>
     </Stack>
   </Surface>
   ```

   …and emits a composition manifest declaring exactly that shape.

2. **QA-Agent** runs the deterministic-first cascade:

   - Step 1: composition manifest present? ✓
   - Step 2: every visible DOM node has `data-canonical-id` or is within one? ✓
   - Step 3: pixel-diff each instance vs its baseline? ✓
   - Step 4: token lint — only `--ds-*` tokens? ✓
   - Step 5: geometry check — composition on the grid? ✓
   - Step 6 (rarely): manifest-primed vision pass.

3. **Verdict:** `pass | needs-work | fail` with per-component evidence.

## Baseline invalidation

Each story has a hash entry in `catalog-hash.json`. When a `.stories.tsx` source changes:

1. Catalog tooling re-hashes the story.
2. If hash differs from stored value → baseline flagged as needing re-snapshot.
3. Engagement Lead / Practice Lead approves the re-snapshot (catalog evolution is deliberate, not silent).
4. New baseline replaces old; QA passes use the new baseline going forward.

## Atlas-specific components

The catalog includes both Atlas DS primitives (Button, Card, Stack, Surface, Badge, Heading, Text, Icon) and Atlas-composed components built from them:

- **HealthPill** — engagement health state visual (on-track / at-risk / off-track / paused).
- **TgateChip** — T-gate countdown indicator.
- **EngagementCard** — engagement summary card used in portfolio + drawer surfaces.
- **PlanGrid** — engagement plan visualization.
- **BlockerStrip** — top-3 blockers display.
- **StatusReportPreview** — Status Report rendered preview surface.
- **CustomerPreviewFrame** — wrapper for customer-facing surfaces.

Each demonstrates the pattern: *one composed component, named in the catalog, with a frozen baseline, used by anchor patterns.*

## How this shape demonstrates the Cadence pattern

The catalog is what makes the visual-QA canonical-catalog architecture (core `visual-qa-catalog.md`) operational. Without the catalog, "is this rendered output good" is open-ended visual judgment. With the catalog, "is this rendered output good" becomes "does it compose from declared catalog components with declared tokens at declared positions" — deterministic.

A downstream project's catalog has different components, different tokens, different baselines. But the *shape* (Storybook stories + frozen baselines + composition manifests + deterministic validation cascade) is the framework pattern.
