# Current Handoff

State: READY_FOR_BUILD

Branch: `chucky-dev`
Planning base commit: `b7f4ea74c3d498cc0c41ac3b6857d7d212a5a4d8`
Current roadmap phase: Phase 3 — Building System
Objective: Add one presentation-neutral runtime construction executor that resolves the authoritative Basic Nest, validates supplied placement/occupancy, and charges its complete resource bundle only on success, returning copied semantic result data without creating scenes or owning occupancy.

Repository evidence:
- `BuildingCatalog` and `BuildingDefinition` provide authoritative semantic lookup, 2x2 Basic Nest footprint, copied costs (`25 crumbs`, `10 twigs`), and presentation metadata isolated from mechanics.
- `BuildingPlacementValidator` is stateless and returns stable semantic placement status plus copied candidate cells from supplied bounds and occupancy.
- `ResourceLedger.debit_bundle()` validates complete bundles before mutation and returns stable semantic transaction statuses.
- No construction executor, runtime building registry, occupancy authority, building scene, or storage application exists.
- QA has independently verified the catalog, placement validator, and atomic cost transaction at the promoted base commit.
- Entry tree was clean. After fetch, local/remote `main` and `chucky-dev` all pointed to `b7f4ea7`.
- Godot `4.6.2.stable.official.71f334935` is available at `/home/ubuntu/.local/bin/godot4`.

Required build outcome:
- Resolve building mechanics from the injected catalog by semantic ID.
- Validate placement before charging; preserve all balances on every rejected request.
- Debit the exact authoritative cost once on success and return semantic ID, anchor, status, and copied footprint cells.
- Keep occupancy caller-owned and unchanged; do not create a building instance or apply storage.
- Keep all presentation assets and metadata outside construction logic and prove equivalent behavior under complete Basic Nest presentation substitution.

Required validations:
- Godot headless import/startup with exactly one `PIGEON_EMPIRE_STARTUP_OK`.
- Baseline, all Phase 1 smokes, all six Phase 2 smokes, all three existing Phase 3 smokes, and new `phase03_building_construction_executor_smoke.gd` with exactly one `PHASE03_BUILDING_CONSTRUCTION_EXECUTOR_SMOKE PASS`.
- Combined-output scan rejects nonzero exits, `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, missing markers, and duplicate markers.
- `git diff --check`.
- Focused checks for exact valid debit/cells, invalid placement before debit, insufficient-balance atomicity, missing/unknown dependency rejection, caller/result collection isolation, repeated affordability, and full presentation substitution.

Save/schema impact: None. Runtime in-memory orchestration only; no persistence, migration, autoload, building record, occupancy registry, storage state, or offline progress.

Known blocker status: None. Cross-system occupancy mutation is intentionally deferred; this slice returns validated cells but does not pretend payment plus caller-owned world mutation is one atomic transaction.

See `docs/ACTIVE_PHASE.md` for exact scope, exclusions, acceptance criteria, validation commands, risks, rollback boundary, and reskin contract.
