# CR Authoring Contract — routable + issue-free by construction

**Status:** CANONICAL (process). Binding standard for every session (any agent, any runtime) that authors a commit request.

**Principle:** *build quality in, don't inspect it in.* A CR is the authoring session's responsibility to make routable and issue-free **before** it is submitted for orchestrator approval. The CR-lint tool and the orchestrator approval gate are **backstops that should rarely fire** — not the mechanism that makes CRs correct.

**One-line rule:** *No CR is submitted for orchestrator approval until `<cr-lint-tool> <cr>` reports ROUTEABLE except for the approval-only fields the orchestrator sets (`status`, approval token). Everything structural must already be clean.*

---

## §1. Why this exists

The lane resolver routes from the CR **file frontmatter**, not from the heartbeat. A CR that is missing fields is silently unroutable even when approved in chat — historically a top failure mode. This contract makes the frontmatter correct at the source so routing just works.

A CR-lint tool (project-specific shell script that reads the frontmatter and reports per-field status) is the prevention surface. Build it for your project; treat its ROUTEABLE verdict as the gate.

---

## §2. Required frontmatter (every CR)

| Field | Rule |
|---|---|
| `title` | Human-readable. |
| `scope` | One of `ux-patch` · `frontend` · `backend` · `infrastructure-autonomous` · `project-HITL`. Anything else will NOT route through the orchestrator product-execution lane. |
| `status` | Lifecycle field. Author sets `proposed_for_so_review`. **Only the orchestrator sets `approved_for_spawn`** at approval. Routeable statuses: `approved_for_spawn`, `ready_for_build`, `accepted_for_promotion`. |
| `target_role` | The runtime role that should execute. Required so the resolver can route. |
| `change_paths` | **Required for product scopes.** A YAML list of files the CR touches. At least one must sit under an authorized path or `approved_product_execution()` silently rejects. **Most-often-forgotten field — never omit it.** |
| `strategic_orchestrator_approval` | Author leaves unset / `pending`; orchestrator sets `approved` at approval. |
| `no_push: true` | Always. |

### §2.1 Finished-branch landing CRs

Finished implementation branches use a dedicated route kind instead of fake product `change_paths`:

```yaml
route_kind: land_finished_branch
target_role: <observer-or-equivalent>
source_branch: <finished-branch>
source_commit: <commit-to-land>
base_branch: main
qa_evidence:
  - <exact command / evidence>
dirty_tree_policy: clean_required # or scoped_nonoverlap / dedicated_landing_worktree
land_strategy: signed_merge        # or signed_cherry_pick
no_push: true
```

The landing role verifies source commit, QA evidence, signing, scope, dirty-tree safety, and NO PUSH before landing. The CR-lint tool treats this route as routeable without product `change_paths`; missing safety fields block routing.

### §2.2 Additional for product / visual CRs

- `walk_before_merge: required` when the user must walk before mergeback.
- `walk_packet_required: true` — closeout emits a walk packet. Interactive features need a **live preview URL**, not stills.
- `mergeback_disposition:` (e.g. `hold_until_rewalk`) when applicable.
- Visual CRs additionally follow the project's visual-CR schema (oracle, render_contract, ready_for_walk artifacts).

### §2.3 Composition manifest for page-build CRs (optional, when project ships visible UI)

Visible page/surface work declares the manifest that the composition-check tool enforces before walk or land:

| Field | Rule |
|---|---|
| `composition_require` | Approved catalog/DS components that must be imported or composed. |
| `composition_pages` | Canonical page files the checker inspects. |
| `composition_anchor_stories` | Storybook/catalog anchor story paths. |
| `composition_new_components` | Net-new component budget. Default `0`; positive only with explicit approval. |
| `composition_new_components_allow` | Optional approved allowlist of new component paths. |
| `composition_forbid_markers` | Optional literals or `re:<regex>` markers for rejected hand-rolled drift. |
| `new_page_forbidden` | Set `true` when the CR must extend an existing page rather than create another surface. |

Non-page CRs are not burdened by this manifest. See `visual-qa-catalog.md` for the broader catalog-baseline visual-QA architecture.

### §2.4 Visual-match fields for walk packets

When visual fidelity must be proven:

| Field | Rule |
|---|---|
| `visual_match_required` | Set `true` for page-build work that must prove baseline/new fidelity. |
| `visual_baseline` | Route, Storybook story, oracle image, or artifact path that is the baseline. |
| `declared_visual_deltas` | The only allowed visible differences. |
| `side_by_side_required` | Set `true` when the walk packet must show baseline-vs-new evidence. |
| `themes_required` | List themes (e.g. `[light, dark]`) when both must be proven. |

---

## §3. Status lifecycle

```
author: status: proposed_for_so_review   (frontmatter otherwise routeable-complete)
   │
   └─ orchestrator approval gate: CR-lint must pass
        → orchestrator sets status: approved_for_spawn
          + strategic_orchestrator_approval: approved
        │
        └─ resolver routes → executor STARTED → … → closed
```

The author's job is everything **except** the two approval fields. If the only thing standing between a CR and ROUTEABLE is `status` / approval token, it is well-authored. If CR-lint reports a missing `change_paths`, wrong `scope`, or no `target_role`, the CR is **not** ready to submit.

---

## §4. Self-check before submit (mandatory)

```bash
<cr-lint-tool> handoff/notes/commit-requests/<your-cr>.md
```

Allowed remaining blockers at submit: `status is proposed_for_so_review` + `approval token`. **Any structural blocker — fix it before submitting.** Use the template at `handoff/notes/commit-requests/_TEMPLATE.md` if your project ships one.

---

## §5. Disposition vocabulary (binding)

When closing / cancelling / superseding a CR or directive, use only:

```
closed | merged | superseded | absorbed | parked
```

**Never** "withdrawn" / "cancelled" — the autonomy-loop classifier (where one runs) does not admit them and may wedge.

---

## §6. Routing rules for surfaces under additive-only convention

When a project designates a surface as additive-only (e.g. a primary navigation, a canonical workspace mount), every CR touching that surface follows:

- **Additive only.** A new section/view is added as an *optional* route/tab. It must never replace, hijack, alias-over, or redirect an existing primary surface.
- **Links resolve to the LIVE canonical mount**, never a legacy/older/redirected route.
- A CR touching routing must name the live target route+component, state it is additive, and confirm no existing mount is displaced.

Configure the additive-only paths in your project's CR-lint tool.

---

## §7. Anti-patterns this prevents

- **Missing `change_paths`** → CR looks approved, silently won't route.
- **Wrong `scope`** (`catalog-enrichment` on build-ux work, etc.) → ignored by the orchestrator lane.
- **Relying on a heartbeat approval** to carry a file that says `proposed_for_so_review` → the resolver reads the file, not the heartbeat.
- **`withdrawn` / `cancelled` disposition** → loop wedge.

---

## §8. Walk-readiness gate (binding for visible work)

A build **MUST NOT** emit `READY_FOR_WALK`, and the orchestrator **MUST NOT** surface a walk to the user, unless BOTH hold:

1. **Proven.** The closeout cites real evidence: for visual CRs the four ready-for-walk artifacts (`mockup_png`, `render_png`, `side_by_side_png`, `deviations_md`) *plus* the `render_contract`; for interactive/functional surfaces a functional test pass *plus* light + dark screenshot pair; and a self-check against the project's coherence rubric.
2. **Reachable.** The walk URL resolves on the **persistent runtime** (the integrated branch's running surface), never an ephemeral per-task preview port that dies with its worktree.

The lane-digest tool surfaces walks missing proof or on an ephemeral port under "NOT WALK-READY" rather than presenting them to the user.

---

## §9. See also

- `work-units.md` — where slices fit in the Goal → Wave → Slice hierarchy.
- `autonomy-goal-runner.md` — how goal children reference these CRs.
- `runtime-route.md` — route-delivery contract for approved CRs.
- `operational-patterns.md` §4 — commit discipline.
- `agent-roles.md` — who has authority to author / approve / route CRs.
