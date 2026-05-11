# Cadence Framework — Context-Budget Tightening Brief

**Authored by:** Claude Code (Opus 4.7, 1M context) — session `claude-code-2026-05-11-bootstrap-session`.
**Date:** 2026-05-11.
**Target executor:** any Cowork / Codex / Claude Code session continuing this thread.
**Status:** brief — not a code-change plan. Captures the user's concerns, measured findings, and concrete framework-tightening proposals to pick up one-by-one through normal slice/PR flow.
**Promoted to handoff:** 2026-05-11 by Cowork session `cowork-2026-05-10-extract-workflow-architecture` per the brief's §11 recommendation.
**Session origin:** `memory/sessions/claude-code-2026-05-11-bootstrap-session.md`.
**Heartbeat event:** `2026-05-11T08:34:24-0700 | claude-code-2026-05-11-bootstrap-session | started`.

**Working state of repo at brief time:** fresh starter-kit instantiation of Cadence — `<PROJECT_NAME>` / `<DEVELOPER>` / `<DEVELOPER_BRANCH>` placeholders still present; zero commits; all docs template-shape.

---

## §1. Context — why this came up

User invoked Claude Code with "I want you to boot you by following instructions in claude.md". The session executed the §0 bootstrap sequence (read AGENTS.md, quick-reference, INDEX, memory/README, design/README; ran Step 0.5 heartbeat check; created chronicle; appended `started` heartbeat event). Then the user asked a series of progressively sharper calibration questions:

1. "How much token was used for you to bootstrap to this point?"
2. (After running `/context` and pasting actual numbers) "Is this good or requires tightening?"
3. "Because this framework is meant to work on large codebase monorepo projects."
4. "Well this mechanism needs to work with Codex and its context window as well."

The through-line: **does the framework's context-budget shape hold across both Opus 4.7 1M (Claude Code) and Codex's ~272k window, at monorepo scale, on a mature project?**

This brief captures the measured findings and tightening proposals worth taking up **before real project content starts landing** — because the cheapest moment to encode strict archival/rollup discipline is before there's anything to archive.

---

## §2. Measured findings (authoritative — from `/context` output)

**Bootstrap turn cost on Opus 4.7 (1M context): 47.4k tokens (5% of window).**

| Category | Tokens | Notes |
|---|---|---|
| Messages (bootstrap-attributable work: file reads, tool I/O, output) | 24.9k | The actual work cost |
| System prompt | 8.5k | Fixed harness overhead |
| System tools (always-loaded schemas) | 13.7k | Fixed harness overhead |
| Skills (headers only) | 721 | Bodies load on invocation |
| Memory files (project CLAUDE.md) | 238 | The redirect file |
| Free space | 952k (95.2%) | |

**Calibration note.** Initial pre-/context estimate (~12k bootstrap content + 20–30k system) was off — undercounted Messages by ~2× because tool-call/tool-result envelopes roughly double the raw file-byte footprint. File-on-disk bytes (40KB across the 5 §0 reads + chronicle) translated to ~10k tokens of content, but ~25k in Messages once wrapped. **Future estimation rule: 4× chars-to-tokens for wrapped-in-Messages content, not 4× for raw file bytes.**

**Deferred tool set kept overhead down.** 14 MCP `__authenticate` tool schemas (Gmail, Slack, Notion, etc.) live in a deferred set and only load if ToolSearch fetches them. Without that, the harness floor would be considerably higher.

---

## §3. Verdict, conditional on agent

| Agent | Window | Bootstrap as % today | Bootstrap as % at maturity (est.) | Verdict |
|---|---|---|---|---|
| Claude Code (Opus 4.7) | 1M | 5% | 7–10% | Comfortable |
| Codex CLI (GPT-5 class) | ~272k | ~11–15% | ~26–33% | Workable now; tight at maturity without archival discipline |
| Codex / 200k models | 200k | ~15–20% | 30–40%+ | Painful — compaction or mid-task context loss likely |

**The framework's smallest-supported context window sets the budget. Codex is the binding constraint, not Opus.**

---

## §4. The structural watch-out — three append-only growth files

These are loaded into every session's bootstrap and grow unboundedly with project age. Their growth control is what determines whether bootstrap stays healthy at maturity.

| File | Today (template) | Plausible at maturity | Current mitigation |
|---|---|---|---|
| `memory/INDEX.md` | ~1.1k tokens | 15–30k | Memory steward expected to trim "Recent commits" + "Slices shipped" sections; no hard caps documented |
| `memory/quick-reference.md` | ~1.1k | 5–10k | Framework notes "demote to glossary.md when >150 lines"; manual discipline only |
| `design/canonical/decisions.md` | empty | 20–50k | No rollup convention currently exists in the framework — biggest unmitigated growth source |

**Also relevant but lower-impact:**

- `AGENTS.md` itself (~3.5k tokens, 240 lines) is re-read every Codex spawn. Forbidden Actions and Step 0.5 logic are load-bearing; the placeholder/instantiation prose at the bottom (~500 tokens) could move to `design/process/instantiation-guide.md`.
- `memory/README.md` (~2.5k, 175 lines) — mixes terse pointer index with full chronicle-convention prose. Could split: pointer file stays universal-load; convention loads on demand.
- `memory/heartbeat.md` is bounded by `tail -n 100` reads — fine if event-line discipline holds (one-line summaries; details in chronicle). Worth re-validating once real events start landing.

---

## §5. What the framework already does right (don't change these)

These are the load-bearing pieces that keep monorepo work viable. The 5% bootstrap measurement is downstream of these working:

1. **Tiered §0 reading order.** Hot-cache `quick-reference.md` → `INDEX.md` → canonical/features on demand. Without this, mature bootstrap would be 300k+.
2. **Per-feature handoff briefs** (`design/features/<NN>/agent-handoff.md`). Load one feature, not all features.
3. **Sub-agent delegation** (Explore, general-purpose). Keeps grep/glob/file-read results out of the parent context — far more important for monorepo work than shaving 5k off bootstrap.
4. **Per-session chronicles** in `memory/sessions/` with weekly archival. Resume without re-reading everything.
5. **Heartbeat ledger** with bounded `tail -n 100` reads instead of full-file loads.
6. **Worktree isolation.** Each session's `git status` / `git diff` only sees its slice.
7. **Step 0.5 pre-action conflict + context check** before first action — keeps coordination overhead bounded.

**Recommendation: don't tighten the bootstrap content itself.** The §0 universal reads are already the minimum required for a session to operate correctly. The work is at the growth-control layer.

---

## §6. Concrete proposals to take up with future sessions

Five small, additive changes. None require waiting for project content. All are appropriate to land before the first real slice ships.

### Proposal 1 — Add decisions.md rollup convention (biggest single win)

- **Problem:** `design/canonical/decisions.md` is append-only with no archival. Largest unmitigated growth source.
- **Change:** Quarterly archival of locked decisions older than N quarters into `design/canonical/decisions-archive/YYYY-QN.md`. Live `decisions.md` retains a one-line stub per archived decision: `D-NNN | <title> | locked YYYY-MM-DD | → decisions-archive/YYYY-QN.md`. Full entry lives in archive.
- **Touches:** new section in `design/canonical/README.md`; new section in `design/process/scheduled-tasks/memory-steward-prompt.md` (steward owns archival); create empty `design/canonical/decisions-archive/` directory with a README explaining the format.
- **Why now:** zero decisions logged yet; format is free to define.

### Proposal 2 — Hard caps on INDEX.md rolling sections

- **Problem:** "Recent commits" and "Slices shipped (recent)" sections in `INDEX.md` will accrete without explicit limits.
- **Change:** Document hard caps in the "How to read" subsection of `INDEX.md` itself:
  - "Recent commits": last 10 commits; older → `git log` or `INDEX-archive-YYYY-QN.md`.
  - "Slices shipped (recent)": last quarter only; older → archive file.
  - Memory steward enforces caps during daily run.
- **Touches:** edit `memory/INDEX.md` section headers; add enforcement step to memory-steward prompt.

### Proposal 3 — quick-reference.md line-count check in memory steward

- **Problem:** Existing "demote to glossary.md when >150 lines" rule is documented but has no enforcement.
- **Change:** Memory steward daily routine adds a check: if `quick-reference.md` > 150 lines, emit a `note` heartbeat event proposing specific demotion candidates (entries not referenced in the last N steward runs).
- **Touches:** `design/process/scheduled-tasks/memory-steward-prompt.md`.

### Proposal 4 — Move placeholder/instantiation prose out of AGENTS.md

- **Problem:** AGENTS.md "Placeholders used in this file" (~500 tokens) is one-time-instantiation reference that Codex re-reads every spawn forever.
- **Change:** Move to `design/process/instantiation-guide.md`. Replace in AGENTS.md with a one-line pointer:
  > One-time instantiation: see `design/process/instantiation-guide.md`.
- **Touches:** AGENTS.md, new `design/process/instantiation-guide.md`.
- **Saving:** ~500 tokens per Codex spawn, every spawn, forever.

### Proposal 5 — Document the per-agent context-budget assumption

- **Problem:** Framework doesn't explicitly state the context-budget shape it's designed against. Future contributors may unwittingly add bootstrap reads or grow the universal set.
- **Change:** Add a section to `design/process/operational-patterns.md` (the RUNBOOK):
  > **Context-budget assumption.** This framework targets agents with ≥200k input context. The §0 universal reads are sized to stay under 30k tokens of file content at maturity. Growth in `memory/INDEX.md`, `memory/quick-reference.md`, and `design/canonical/decisions.md` is the memory steward's responsibility — see the steward prompt for archival/cap rules. Anyone proposing a new universal §0 read must demonstrate it doesn't push the floor above 30k.
- **Touches:** `design/process/operational-patterns.md`.

### Lower-priority — defer unless context pressure observed

- Split `memory/README.md` into `README.md` (pointer-only) + `memory/chronicle-convention.md` (full prose). Saves ~1k per session. Adds indirection — only worth it if Codex bootstrap creeps above ~80k.
- Revisit `memory/heartbeat.md` event-line discipline once 20–30 real events land; verify one-line-summary spec compliance.

---

## §7. Pre-existing housekeeping flagged this session (independent of context-budget work)

Surfaced during bootstrap; not directly part of the tightening proposals but worth landing alongside:

1. **Starter-kit placeholder pass.** `<PROJECT_NAME>`, `<DEVELOPER>`, `<DEVELOPER_BRANCH>`, `<GITLAB_OR_GIT_HOST_URL>`, `<GROUP>`, `<PROJECT>`, `<ARCHITECT_ROLE>` still present across AGENTS.md, memory/INDEX.md, memory/quick-reference.md, README.md. Per AGENTS.md "Placeholders used in this file", this is a one-time search-and-replace. Likely values: `<PROJECT_NAME>` → `cadence`, `<DEVELOPER>` → Anu Singh, `<DEVELOPER_BRANCH>` → `anu-singh` (or `main` per Anu's earlier course-correction — confirm before applying). Git host / group / project unknown — surface to user.
2. **Zero commits.** Confirm GPG signing config (`git config commit.gpgsign`) before the first commit. AGENTS.md non-negotiable rule.
3. **`design/canonical/` has no project-specific content.** Per `design/README.md`, this is the foundation everything else builds on. First real architectural work belongs here, not in features/.
4. **`main` branch existence + remote configuration not verified.** Currently on `anu-singh` with no commits. Confirm whether `main` exists locally and whether a remote is configured before any push.

---

## §8. What a future session would pick up

Recommended next steps in priority order, for a Cowork/Codex/Claude Code session continuing this thread:

1. Land the placeholder s/r pass (one-shot, low risk) — unblocks everything else by giving the repo a real identity.
2. Implement Proposal 1 (decisions.md rollup convention) — biggest win, no existing content to migrate.
3. Implement Proposal 5 (context-budget assumption documented in RUNBOOK) — encodes the design intent so future contributors don't drift.
4. Implement Proposals 2, 3, 4 as a single follow-up commit.
5. First architectural ADR logged into `design/canonical/adrs/` and `design/canonical/decisions.md` — exercises the new rollup format end-to-end before any pressure to ship features.

**Open questions for the user to resolve before #1:**

- Project name confirmed: `cadence`?
- Developer identity for `<DEVELOPER>`: Anu Singh?
- Branch convention: keep `anu-singh` as `<DEVELOPER_BRANCH>`, or use a different convention?
- Git host / group / project for the placeholder fields?

---

## §9. Verification (how to know these proposals work)

For each proposal at land-time:

- **Proposal 1:** create a dummy D-001 decision, run the steward's archival logic in dry-run mode, confirm stub-replacement format renders correctly in `decisions.md`.
- **Proposal 2:** seed `INDEX.md` with >10 fake commits and >1 quarter of fake slices; run steward; confirm caps enforced and archive file created.
- **Proposal 3:** seed `quick-reference.md` >150 lines; run steward; confirm `note` heartbeat event emitted with specific demotion candidates.
- **Proposal 4:** run `wc -c` before/after on AGENTS.md; confirm ~500-byte reduction. Re-bootstrap a session; confirm pointer is followed only when needed (not in universal load).
- **Proposal 5:** purely documentary — verify by reading. The "test" is whether the next contributor proposing a §0 addition references the budget rule.

**End-to-end framework verification (after all proposals land):**

- Re-run a Claude Code bootstrap; confirm `/context` shows similar or lower Messages footprint than today's 24.9k.
- Re-run a Codex bootstrap (if available); confirm Codex's equivalent context indicator stays under ~15% of its window.
- Project the maturity scenario: simulate `INDEX.md` at quarterly cap + `decisions.md` at quarterly cap + `quick-reference.md` at 150-line ceiling; recompute bootstrap; confirm projected mature bootstrap stays <30k of file content per Proposal 5's stated budget.

---

## §10. Critical files referenced (read-only context)

- `AGENTS.md` — operating contract (would be edited by Proposal 4)
- `CLAUDE.md` — redirect (no change)
- `memory/quick-reference.md` — hot-cache (no change to file; rule enforced by Proposal 3)
- `memory/INDEX.md` — project state (edited by Proposal 2)
- `memory/README.md` — memory architecture (potential split, deferred)
- `memory/HEARTBEAT_SPEC.md` — event format (not read this session; flagged for follow-up)
- `design/README.md` — design corpus index
- `design/canonical/README.md` — not read this session; would be edited by Proposal 1
- `design/process/operational-patterns.md` — RUNBOOK (would be edited by Proposal 5)
- `design/process/scheduled-tasks/memory-steward-prompt.md` — steward routine (edited by Proposals 1, 2, 3)
- New: `design/process/instantiation-guide.md` (created by Proposal 4)
- New: `design/canonical/decisions-archive/` (created by Proposal 1)
- This session's chronicle: `memory/sessions/claude-code-2026-05-11-bootstrap-session.md`

---

## §11. Suggested next action

Promote this brief into the repo as a proper handoff note at:

```
handoff/notes/claude-code_to_next_2026-05-11_context-budget-tightening.md
```

(✅ Done by Cowork session `cowork-2026-05-10-extract-workflow-architecture` on 2026-05-11.)

so the next session (Cowork/Codex/Claude Code) finds it through the project's own discovery path rather than the harness's plan directory. The proposals above are then picked up one-by-one through normal slice/PR flow.

---

## §12. Reviewer note (from promoting Cowork session)

This brief lands at exactly the right moment in Cadence's lifecycle — before the first real commit. The five proposals are all aligned with growth-control, not bootstrap-content reduction, which is the correct framing. A few observations worth carrying forward when proposals get picked up:

1. **Proposal 1 (decisions.md rollup) is genuinely the biggest single win** and should anchor the first follow-up commit. The format is free to define; quarterly windows match the existing weekly-archival cadence pattern from the memory steward at a coarser grain.
2. **Proposal 4 (instantiation-guide split) is the most surgical** and could ride alongside Proposal 1. It's also the most measurable — ~500 tokens × every Codex bootstrap × forever.
3. **Proposal 5 (budget assumption in RUNBOOK) is what protects the design from future drift.** Worth landing early so subsequent contributors inherit the constraint.
4. The brief's observation about **tool-call envelopes doubling raw file bytes (4× chars-to-tokens for wrapped content)** is a non-obvious empirical finding that should probably get codified somewhere — maybe in the new Proposal 5 budget-assumption section, or as its own one-liner in `operational-patterns.md`. Future contributors estimating bootstrap cost will undercount otherwise.
5. **The "Codex is binding, not Opus" verdict** matches the §7.1 permission-mode discipline already in agent-roles.md (all Codex CLI sessions full-access for performance reasons). Both reflect the same underlying reality: Codex is the throughput-critical embodiment for autonomous roles, so the framework should optimize for its constraints.

Cross-references that exist today and shouldn't be missed when implementing:

- `agent-roles.md` §7.1 — permission mode (same lineage of "treat Codex as the binding constraint").
- `operational-patterns.md` §14 — pulse-check contract (heartbeat-tail discipline already there; Proposal 5 budget rule complements).
- A weekly framework-sync scheduled task (runs Sundays at 10:08 AM Pacific) could pick up the budget-assumption section once added so it gets propagated to future Cadence instantiations.

---

*Original brief authored by Claude Code (Opus 4.7) on 2026-05-11. Promoted by Cowork session `cowork-2026-05-10-extract-workflow-architecture` on the same day with §12 reviewer notes appended.*
