# Active Phase

Phase: Phase 3 — Building System
Status: Approved slice — ready for build

## Objective

Add one presentation-neutral runtime construction executor that resolves a building definition, validates its footprint against supplied occupancy, and charges its complete cost only for a valid affordable request, returning an immutable semantic construction result without creating scenes, owning occupancy, or applying storage.

## Gameplay purpose

Turn the verified Basic Nest definition, placement validator, and atomic cost transaction into one safe construction decision. A valid request at an open rooftop anchor can succeed and report the exact occupied cells; invalid placement or insufficient resources must leave every balance unchanged.

## Exact scope

- Add a narrow `BuildingConstructionExecutor` with injected `BuildingCatalog`, `BuildingPlacementValidator`, and `ResourceLedger` dependencies.
- Accept a semantic building ID, integer anchor, integer grid bounds, and caller-owned occupied-cell collection.
- Resolve the definition and complete placement validation before charging resources.
- Debit the definition's copied construction-cost bundle exactly once only after placement succeeds.
- Return a typed, presentation-neutral result containing a stable status, semantic building ID, anchor, and copied footprint cells.
- Define deterministic statuses for success, missing dependency, invalid/unknown building ID, invalid placement, and insufficient or rejected cost transaction.
- Preserve all caller-owned collections and all injected dependency state on rejection except the ledger's exact successful debit.
- Add one focused Phase 3 headless smoke using authoritative `basic_nest` data.

## Non-goals

- Creating a building node, scene, visual, preview, ghost, button, panel, input flow, selection behavior, animation, audio, or main-scene integration.
- Mutating or owning the occupied-cell collection; reserving cells; maintaining a building registry; assigning instance IDs; demolition, refunds, movement, upgrades, production, jobs, pigeons, timers, storage-cap application, persistence, autosave, or offline gains.
- Changing grid dimensions, resource balances at startup, Basic Nest mechanics or costs, catalogs, placement rules, ledger APIs, gathering behavior, or authoritative JSON.
- General command queues, undo/redo, transaction history, concurrency, or rollback after external mutations.

## Likely affected systems/files

- `scripts/buildings/building_construction_executor.gd` (new orchestration boundary)
- `scripts/buildings/building_construction_result.gd` (new typed immutable semantic result, if kept separate)
- `tests/phase03_building_construction_executor_smoke.gd` (new focused smoke)

Do not modify scenes, UI, data JSON, images, themes, existing catalogs, the placement validator, or the resource ledger unless a demonstrable integration defect blocks this exact slice. Any such defect must remain narrowly scoped and covered by the focused smoke.

## Acceptance criteria

1. Headless import and startup pass, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. An authoritative `basic_nest` request at an open valid anchor succeeds, reports the semantic building ID and exact 2x2 row-major footprint cells, and debits exactly `25 crumbs` and `10 twigs` once while leaving `shinies` unchanged.
3. The executor resolves mechanics from the injected catalog; it does not accept caller-supplied costs or footprints.
4. Out-of-bounds or occupied placement rejects before debit and preserves the complete ledger snapshot.
5. Insufficient crumbs or twigs rejects without any balance change, including when the other required resource is sufficient.
6. Empty/unknown building IDs and missing catalog, validator, or ledger dependencies reject deterministically without mutating supplied state.
7. Repeating a successful request against unchanged caller occupancy charges again only while fully affordable; the first unaffordable repeat rejects atomically. Occupancy mutation remains the caller's deferred responsibility.
8. The caller-owned occupied-cell array remains unchanged after every outcome. Returned cell collections are copied so caller mutation cannot alter result internals or catalog/validator state.
9. Existing resource, catalog, placement-validator, and construction-cost transaction APIs retain their verified behavior; all prior smokes pass unchanged.
10. The executor depends only on semantic IDs, footprint mechanics, integer grid coordinates, supplied occupancy, semantic transaction statuses, and balances—not names, descriptions, icons, style/world-visual slots, textures, colors, copy, node names, layout, audio, animation, or art dimensions.
11. Substituting every Basic Nest presentation field while preserving semantic ID, footprint, and costs produces the same construction status, cells, and exact ledger delta.
12. The slice loads no image, scene, font, theme, animation, audio, UI, or final art and introduces no image file.
13. No building instance, occupancy mutation, storage contribution, save/schema, autoload, main-scene, gathering, or startup-state behavior is introduced or changed.
14. The focused smoke prints exactly one `PHASE03_BUILDING_CONSTRUCTION_EXECUTOR_SMOKE PASS` and exits 0.
15. Headless import/startup, baseline smoke, all Phase 1 smokes, all Phase 2 smokes, all three existing Phase 3 smokes, the new focused smoke, clean parser/error scanning, and `git diff --check` pass.

## Focused validation commands

```bash
/home/ubuntu/.local/bin/godot4 --headless --path . --import
/home/ubuntu/.local/bin/godot4 --headless --path . --quit
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_visual_layering_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_world_object_selection_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_catalog_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_ledger_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_gathering_action_catalog_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_gathering_action_executor_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_hud_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_playable_gathering_loop_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase03_building_catalog_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase03_building_placement_validator_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase03_construction_cost_transaction_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase03_building_construction_executor_smoke.gd
git diff --check
```

Capture combined output for every Godot command. Fail on nonzero exit, `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, a missing marker, or a duplicate marker. Use each existing smoke's actual historical marker and require the new marker exactly once.

## Save/schema impact

None. This slice coordinates in-memory runtime dependencies only. It adds no save file, schema version, migration, autoload, persisted balance, building record, occupancy registry, storage state, or offline progression.

## Risks and rollback boundary

- Charging before placement validation would consume resources for rejected construction; resolve definition and placement completely before calling `debit_bundle()`.
- The executor cannot atomically mutate caller-owned occupancy after payment without owning a world-state transaction. This slice deliberately returns validated cells and leaves occupancy mutation deferred rather than faking cross-system atomicity.
- Accepting caller-provided definitions, costs, or footprint cells would bypass catalog authority; resolve all mechanics by semantic building ID.
- Collapsing every failure into display text would couple mechanics to UI; return stable semantic statuses and raw mechanical fields.
- Mutable result arrays could leak state; store and return copies.
- Rollback boundary: the new executor, optional typed result, and focused smoke. Reverting those files restores the three verified Phase 3 foundations with no migration or data rollback.

## Reskin boundary and placeholder-asset impact

- Mechanical contract: semantic building/resource IDs, authoritative footprint and cost data, integer anchor/bounds, supplied semantic occupancy cells, atomic ledger debit, stable statuses, and copied result cells.
- Replaceable presentation contract: building/resource names, descriptions, icon/style/world-visual slots, textures, fonts, colors, copy, layout, animation, audio, and future construction feedback remain outside the executor.
- This slice introduces and resolves no image. All current and future images remain temporary placeholders and cannot determine lookup, validity, footprint, cost, occupancy, or transaction outcome.
- Failure and success meaning remain semantic so future UI can combine text, shape, icons, and theme colors; no gameplay meaning is encoded solely by color or placeholder appearance.
- The focused smoke substitutes all Basic Nest presentation metadata and proves identical mechanics. This is a reskin-boundary check, not subjective visual approval.
