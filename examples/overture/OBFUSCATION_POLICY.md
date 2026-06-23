# Obfuscation policy — examples/overture/

Overture is a derived reference instance. The originating product is real, and its operational corpus contains identifiers (project name, customer names, persona names, internal canonical IDs, session IDs, commit SHAs, file paths, env-var prefixes) that we don't want to leak in Cadence's public surface.

This policy codifies the scrub rules. Anyone adding or refreshing content in `examples/overture/` follows this contract. Reviewers reject contributions that ship unscrubbed identifiers.

---

## Rule 1 — No real product names

| Real | Overture |
|---|---|
| Originating product name | **Atlas** |
| Product CLI / tool prefix (`wb-*`) | `atlas-*` or `ov-*` (overture-namespaced) |
| Env-var prefix (`WB_*`, `KNOWLEDGE_LAYER_*`) | `ATLAS_*` |
| Cache dir (`~/.cache/<product>/`) | `~/.cache/atlas/` |
| Git repo slug | `atlas-psa-workbench` (fictional) |
| Originating MCP server name | `atlas-knowledge` (fictional) |

Atlas is framed as a *fictional Professional Services Automation (PSA) platform*. The framing is generic enough to demonstrate the patterns without revealing the actual product domain.

## Rule 2 — No real customer names

| Real | Overture |
|---|---|
| Customer name in engagement scripts | **Globex Corp** |
| Customer fictional product name | **Globex Cloud Subscription** |
| Customer engagement model | "30-day onboarding" (generic) |

Globex is the canonical fictional enterprise in obfuscated materials — borrowed from the Globex Corporation trope, which is widely understood as a placeholder enterprise and clearly fictional.

## Rule 3 — Personas get fictional analogs

The originating instance has named personas (PM / DL / Consultant / Lead Consultant / IL / CS Admin). Overture replaces them with fictional analogs that demonstrate the *pattern* of multi-persona role-registry without surfacing the originating product's actual persona names.

| Real persona | Overture persona | Role-type analog (in core agent-roles.md) |
|---|---|---|
| PM (Project Manager) | **Engagement Lead** | Orchestrator |
| DL (Delivery Lead) | **Delivery Manager** | Architect (Sync) |
| Consultant | **Field Specialist** | Executor |
| Lead Consultant | **Practice Lead** | Architect (Async) |
| IL (Implementation Lead) | **Implementation Director** | Architect (Sync, senior) |
| CS Admin | **Operations Administrator** | Memory Steward |

When citing a persona in an overture doc, use the overture name. Avoid using both ("PM / Engagement Lead") — the dual citation would defeat the obfuscation.

## Rule 4 — Canonical IDs get a prefix

The originating instance has canonical decision IDs (`D-IA-PROPAGATE`, `D-T10-LIFECYCLE`, `D-JOB-PER-SOW`, `D-OPMODEL`, etc.) and lock IDs (`R1.5`, `S7`, `W1`, etc.). Overture prefixes them so they don't collide with the real corpus and are clearly fictional.

| Real | Overture |
|---|---|
| `D-FOO-BAR` | `OV-D-FOO-BAR` |
| `R1.5`, `S7` | `OV-R-1.5`, `OV-S-7` |
| Shell rule `§1.33` | `§1.X` (renumber to break specific cross-reference) |
| Anchor numbers (`A4`, `A5`) | `OV-A-N` |

If a doc references multiple IDs, they all get prefixed. No partial-prefix leakage.

## Rule 5 — No real session IDs, chronicles, or heartbeat data

The originating instance has session IDs like `cowork-2026-05-13-design-orchestrator-pm-architect` and chronicles + heartbeat data spanning hundreds of real entries. None of this carries over.

**For session IDs:** use a fictional shape — `cw-2026-MM-DD-<fictional-topic>`. Pick dates inside a fictional window (e.g., `2026-02-`) that doesn't overlap the originating instance's real timeline.

**For chronicles:** if you need to demonstrate a chronicle, write one fresh — fictional events, fictional sessions, the structural shape only. Do not copy a real chronicle and find-replace identifiers.

**For heartbeat:** same — illustrative excerpts only, freshly authored, fictional. The pattern of pipe-delimited events is what's shown; no real event data carries.

## Rule 6 — No real file paths from outside `examples/overture/` or `cadence/`

References to absolute paths (`~/Projects/grove-cs-workbench/...`) or to other host-side files leak. Inside overture, paths refer only to:

- Other paths inside `examples/overture/`
- Cadence core paths (relative, from repo root)
- Fictional host paths (`~/Projects/atlas/...`)

External integrations get fictional endpoints (`http://atlas.internal/api/...`) and fictional credentials (`ATLAS_API_KEY=<your-key>`).

## Rule 7 — No real commit SHAs, real PR/MR numbers, real ticket IDs

| Real | Overture |
|---|---|
| Real SHA `f45251a` | `ovsha-abc123` (stylized placeholder) or omitted |
| Real PR number `#1234` | `ov-PR-001` |
| Real ticket ID (Jira / Linear / etc.) | `OV-TICKET-001` |

When in doubt, omit. The narrative shape rarely requires real-looking SHAs.

## Rule 8 — Top-banner every overture file

Every file in `examples/overture/` carries this banner near the top (after H1 if present):

```markdown
> **Overture reference instance — obfuscated.** This is a worked example illustrating Cadence patterns. Identifiers (project name, customers, personas, IDs, paths, hashes) are fictional per `examples/overture/OBFUSCATION_POLICY.md`. Do not treat this as canonical for any real project; do not import as a dependency.
```

For code files use the comment-style equivalent. For YAML/JSON, use a comment block at top.

## Rule 9 — Reviewing for leaks

Before adding an overture file to git:

```bash
# Search for known leak markers from the originating instance
grep -i -E "(grove|workbench|cowork|wb-|D-IA-PROPAGATE|cowork-2026)" examples/overture/<new-file>
```

If this returns matches, the file isn't clean yet. Apply Rules 1–7 until it returns empty.

Add a CI gate later (`scripts-infra/cadence.sh check-overture-leaks`) when the catalog of forbidden tokens stabilizes.

## Rule 10 — Refreshing overture is deliberate

Overture is not on the sync engine's automatic-proposal path. To refresh overture:

1. Open a session marked `purpose: overture-refresh`.
2. Identify what shape needs updating (a new feature, a new pattern that's worth demonstrating).
3. Author the overture additions in a worktree.
4. Run the leak check from Rule 9 on every changed file.
5. Land in a path-restricted commit scoped to `examples/overture/`.

Sync-engine reports do not generate overture proposals. If a sync proposal needs an overture illustration to be useful, that's two separate commits — one to core, one to overture, both intentional.
