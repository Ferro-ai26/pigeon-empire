# Current Handoff

State: READY_FOR_BUILD

Branch: `chucky-dev`
Planning base commit: `9e0728b49ca50733882452412323a105d1cf4f90`
Current roadmap phase: Phase 3 — Building System
Objective: Add an atomic multi-resource debit operation to `ResourceLedger`, verified against the authoritative Basic Nest construction-cost bundle, without creating construction, occupancy, UI, storage, or persistence behavior.

Repository evidence:
- The verified `BuildingDefinition` already exposes a copied `construction_costs` dictionary; authoritative `basic_nest` costs are `25 crumbs` and `10 twigs`.
- `ResourceLedger` currently supports guarded single-resource credit/debit only; it has no atomic bundle operation.
- The building placement validator is already verified and remains unchanged by this slice.
- Git entry state was clean; local `main`, local `chucky-dev`, `origin/main`, and `origin/chucky-dev` all pointed to `9e0728b` after fetch.
- Godot `4.6.2.stable.official.71f334935` is available at `/home/ubuntu/.local/bin/godot4`.

Required build outcome:
- Validate every bundle entry and every required balance before any mutation.
- Debit all valid costs exactly once on success; preserve the complete ledger snapshot on every rejection.
- Reject empty/malformed bundles, unknown IDs, non-positive or non-`int` amounts, and insufficient balances with stable semantic statuses.
- Preserve caller-owned data and all existing ledger APIs.
- Keep the ledger independent from building presentation and from `BuildingCatalog`; pass only a semantic cost dictionary.

Required validations:
- Godot headless import and startup with exactly one `PIGEON_EMPIRE_STARTUP_OK`.
- Baseline smoke, all four Phase 1 smokes, all six Phase 2 smokes, both existing Phase 3 smokes, and new `phase03_construction_cost_transaction_smoke.gd` with exactly one `PHASE03_CONSTRUCTION_COST_TRANSACTION_SMOKE PASS`.
- Combined-output scan rejects nonzero exits, `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, missing markers, and duplicate markers.
- `git diff --check`.
- Focused semantic checks for exact Basic Nest debit, all-or-nothing insufficient balance, malformed/unknown entries, repeated transactions, unrelated-resource isolation, caller-data immutability, and full Basic Nest presentation-metadata substitution.

Save/schema impact: None. Runtime in-memory ledger API only; no persistence, migration, autoload, building record, or offline progress.

Known blocker status: None. This plan intentionally stops before the later construction command because charging resources must eventually be coordinated with placement/occupancy rather than pretending a debit alone constructs a building.

See `docs/ACTIVE_PHASE.md` for exact scope, exclusions, acceptance criteria, validation commands, risks, rollback boundary, and reskin contract.
