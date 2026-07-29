# Active Phase

Phase: Phase 3 — Building System
Status: Approved slice — ready for build

## Objective

Add one presentation-neutral runtime building registry that accepts a successful construction result, publishes one immutable building record, owns the occupied-cell index, and supports deterministic lookup by instance ID or occupied cell without creating scenes, applying storage, or changing construction payment.

## Gameplay purpose

Give completed Basic Nest construction a single authoritative in-memory home. The world needs to know which semantic building occupies each rooftop cell before construction can safely become a playable placement flow and before later building selection or storage can consume runtime building state.

## Exact scope

- Add a narrow `BuildingRegistry` that owns ordered runtime building records and an occupied-cell index.
- Add an immutable `BuildingInstanceRecord` containing a registry-assigned positive integer instance ID, semantic building ID, integer anchor, and copied footprint cells.
- Accept only a successful `BuildingConstructionResult` with a non-empty building ID and non-empty, unique footprint cells.
- Register one record atomically only when none of its cells are already occupied.
- Assign monotonically increasing instance IDs only on successful registration; rejected requests must not consume an ID.
- Provide read-only lookup by instance ID and by occupied cell, ordered record enumeration, occupied-cell enumeration, record count, and copied collections.
- Return stable semantic registration statuses for success, invalid construction result, malformed footprint, and occupied footprint.
- Add one focused Phase 3 headless smoke using an authoritative successful `basic_nest` construction result.

## Non-goals

- Changing `BuildingConstructionExecutor`, charging or refunding resources, validating catalog footprints or grid bounds, or combining debit and registration into one transaction.
- Creating a building scene, node, sprite, preview, ghost, button, panel, input flow, selection highlight, animation, audio, or main-scene integration.
- Demolition, movement, upgrades, production, jobs, pigeons, timers, storage-cap application, persistence, autosave, offline gains, or save IDs.
- Accepting arbitrary presentation metadata, caller-assigned instance IDs, caller-owned mutable records, or concurrent mutation support.
- Advancing to Phase 4 or starting a second Phase 3 objective.

## Likely affected systems/files

- `scripts/buildings/building_registry.gd` (new runtime state owner)
- `scripts/buildings/building_instance_record.gd` (new immutable semantic record)
- `scripts/buildings/building_registration_result.gd` (new typed semantic registration result, if kept separate)
- `tests/phase03_building_registry_smoke.gd` (new focused smoke)

Do not modify scenes, UI, data JSON, images, themes, catalogs, placement validation, construction execution, or the resource ledger unless a demonstrable integration defect blocks this exact slice. Any such defect must remain narrow and covered by the focused smoke.

## Acceptance criteria

1. Headless import and startup pass, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. Registering one successful authoritative `basic_nest` construction result publishes exactly one record with instance ID `1`, semantic building ID `basic_nest`, the exact anchor, and the exact copied 2x2 row-major footprint.
3. Every footprint cell resolves to that record; unrelated cells and unknown instance IDs return no record without mutation.
4. A second non-overlapping valid result registers as instance ID `2` and preserves deterministic insertion order.
5. Any overlap rejects atomically, preserving complete records, occupied-cell mappings, insertion order, and next successful instance ID.
6. Null, failed, empty-building-ID, empty-footprint, duplicate-cell, or malformed-cell input rejects deterministically without changing registry state or consuming an ID.
7. Caller mutation of source/result arrays or returned record/cell/order collections cannot alter registry records, occupancy, lookup, count, or ordering.
8. The registry does not resolve definitions, recalculate footprints, validate bounds, debit/refund balances, mutate the construction result, or apply storage.
9. Existing resource, building catalog, placement, cost transaction, and construction executor behavior remains unchanged; all prior smokes pass.
10. Registry mechanics depend only on semantic building identity, integer runtime instance identity, anchor, footprint cells, and semantic statuses—not names, descriptions, icons, style/world-visual slots, textures, colors, copy, node names, layout, audio, animation, or art dimensions.
11. Substituting every Basic Nest presentation field while preserving semantic ID, footprint, and cost produces the same registry records, occupied-cell lookup, IDs, and ordering.
12. The slice loads no image, scene, font, theme, animation, audio, UI, or final art and introduces no image file.
13. No save/schema, autoload, main-scene, startup-state, storage-cap, gathering, or resource-balance behavior is introduced or changed.
14. The focused smoke prints exactly one `PHASE03_BUILDING_REGISTRY_SMOKE PASS` and exits 0.
15. Headless import/startup, baseline smoke, all Phase 1 smokes, all Phase 2 smokes, all four existing Phase 3 smokes, the new focused smoke, clean parser/error scanning, and `git diff --check` pass.

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
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase03_building_registry_smoke.gd
git diff --check
```

Capture combined output for every Godot command. Fail on nonzero exit, `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, a missing marker, or a duplicate marker. Use each existing smoke's actual historical marker and require the new marker exactly once.

## Save/schema impact

None. This slice adds in-memory session state only. Runtime instance IDs are registry-local and explicitly are not a persistence contract. It adds no save file, schema version, migration, autoload, persisted occupancy, storage state, or offline progression.

## Risks and rollback boundary

- Accepting failed or malformed construction results could publish impossible occupancy; validate the complete candidate before any registry mutation.
- Updating records and the cell index incrementally could leave partial state on overlap; preflight every candidate cell, then publish record and index together.
- Exposing internal arrays or records would let callers corrupt occupancy; retain immutable records and return copies of all collections.
- Treating registry IDs as future save IDs would prematurely freeze persistence design; document them as in-memory runtime identity only.
- This registry does not make payment plus occupancy atomic. The later integration slice must preflight against a registry snapshot and define the commit boundary rather than pretending this slice solved cross-system rollback.
- Rollback boundary: the new registry, immutable record/result types, and focused smoke. Reverting those files restores the verified construction executor with no migration or data rollback.

## Reskin boundary and placeholder-asset impact

- Mechanical contract: semantic building ID, registry-local integer instance ID, integer anchor, footprint cells, occupied-cell mapping, stable statuses, and deterministic order.
- Replaceable presentation contract: building/resource names, descriptions, icon/style/world-visual slots, textures, fonts, colors, copy, layout, animation, audio, future selection feedback, and building scene choice remain outside the registry.
- This slice introduces and resolves no image. All current and future images remain temporary placeholders and cannot determine registration, identity, occupancy, ordering, or lookup.
- Occupied/selected meaning remains semantic so future UI can combine text, shape, icons, and theme colors; no gameplay meaning is encoded solely by color or placeholder appearance.
- The focused smoke substitutes all Basic Nest presentation metadata and proves identical registry mechanics. This is a reskin-boundary check, not subjective visual approval.
