# Active Phase

Phase: Phase 3 — Building System
Status: Approved slice — ready for build

## Objective

Add a presentation-neutral building placement validator that evaluates the existing `basic_nest` semantic footprint against rooftop grid bounds and an injected set of occupied cells, without adding preview UI, construction, costs, building instances, or persistent state.

## Gameplay purpose

Give later placement-preview and construction slices one deterministic authority for whether a building footprint fits on the rooftop. This prevents UI, placeholder art, and construction execution from inventing conflicting placement rules.

## Exact scope

- Add one typed placement-validation service under `scripts/buildings/`.
- Accept a verified `BuildingDefinition`, an anchor cell, explicit grid bounds, and a caller-supplied occupied-cell collection.
- Define the anchor as the footprint's top-left semantic grid cell; enumerate footprint cells deterministically in row-major order.
- Return a typed, presentation-neutral result containing a stable semantic status, the requested anchor, and copied footprint cells.
- Support exactly these outcomes: valid placement, invalid/missing definition, invalid grid bounds, out of bounds, and occupied-cell conflict.
- Validate all inputs and resolve the complete candidate footprint before returning success; the service must not mutate the definition, occupied collection, grid, scene tree, or any runtime ledger.
- Add one focused headless smoke covering the authoritative Basic Nest 2x2 footprint, all four rooftop boundaries, overlap rejection, deterministic cell order, copied result collections, malformed inputs, unchanged dependencies, and presentation-metadata substitution.

## Non-goals

- Placement preview visuals, pointer tracking, taps/clicks, selection, ghost sprites, valid/invalid colors, construction commands, resource affordability/debits, storage caps, building instances, occupancy ownership, demolition, movement, production, upgrades, timers, pigeons/jobs, persistence, autosave, or offline gains.
- Diagonal/rotated footprints, irregular footprint masks, multiple building definitions, terrain rules, adjacency rules, pathfinding, procedural worlds, or grid resizing.
- Changes to the authoritative 5x5 rooftop size, Basic Nest balance/data, Phase 1 grid selection behavior, Phase 2 resource behavior, main scene, autoloads, UI scenes, or placeholder assets.

## Likely affected systems/files

- `scripts/buildings/building_placement_result.gd` (new typed immutable result)
- `scripts/buildings/building_placement_validator.gd` (new stateless semantic validator)
- `tests/phase03_building_placement_validator_smoke.gd` (new focused smoke)

Existing building catalog/definition code may receive only a narrow read-only compatibility helper if strictly required. Do not alter authoritative building data or Phase 1/2 behavior.

## Acceptance criteria

1. Headless import and startup pass, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. Given the authoritative `basic_nest`, anchor `(0, 0)`, grid bounds `(5, 5)`, and no occupancy, validation succeeds and returns exactly `(0,0)`, `(1,0)`, `(0,1)`, `(1,1)` in row-major order.
3. Anchor `(3, 3)` succeeds for the 2x2 Basic Nest; anchors `(4, 3)`, `(3, 4)`, negative-x, and negative-y reject as out of bounds.
4. An occupied cell outside the candidate footprint does not block placement. Any occupied cell inside the candidate footprint rejects with the occupied-conflict status.
5. Duplicate occupied cells do not change the result. Invalid occupied entries reject deterministically rather than being silently coerced.
6. Null/invalid definitions and zero or negative grid dimensions reject with their stable semantic statuses and do not crash.
7. The result exposes the requested anchor and copied footprint-cell collections. Caller mutation of returned collections cannot alter prior results, future validation, the definition, or caller-owned occupancy.
8. Every rejection is presentation-neutral and leaves all inputs byte-for-byte/semantically unchanged; no partial occupancy or scene mutation occurs.
9. Validation depends only on semantic footprint dimensions, integer grid cells, grid bounds, and occupancy—not node names, textures, colors, copy, art dimensions, icon/style/world-visual slots, or placeholder appearance.
10. Substituting every Basic Nest presentation field while preserving its semantic mechanics produces identical status, anchor, and footprint cells.
11. The service loads no image, scene, font, theme, animation, audio, UI, or final art. No image file is introduced.
12. No construction cost debit, runtime building state, storage change, save/schema, autoload, main-scene, resource authority, building authority, or Phase 1 selection behavior is introduced or changed.
13. The focused smoke prints exactly one `PHASE03_BUILDING_PLACEMENT_VALIDATOR_SMOKE PASS` and exits 0.
14. Headless import/startup, baseline smoke, all Phase 1 smokes, all Phase 2 smokes, the existing Phase 3 catalog smoke, the new focused smoke, clean parser/error scanning, and `git diff --check` pass.

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
git diff --check
```

For every Godot command, capture combined output and fail on nonzero exit, `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, a missing marker, or a duplicate marker. Use each existing smoke's actual historical marker and require the new marker exactly once.

## Save/schema impact

None. The validator is stateless and receives transient inputs. It creates no building instance, occupancy authority, save file, schema version, migration, autosave, or persisted data.

## Risks and rollback boundary

- Letting preview or construction callers duplicate footprint math would create conflicting rules; keep footprint enumeration in this narrow validator.
- Reading `RooftopGrid.GRID_SIZE` directly would couple domain logic to a scene script; grid bounds must be injected as semantic data.
- Mutating caller-owned occupancy or returning writable internal arrays would violate the stateless contract; duplicate inputs/results where required and prove isolation.
- Accepting loosely typed cells could hide malformed state; reject non-`Vector2i` occupancy entries deterministically.
- Adding rotation or irregular masks now would inflate the contract before the single Basic Nest needs them.
- Rollback boundary: the two new building placement scripts and focused smoke. Reverting them returns the verified building catalog unchanged with no migration.

## Reskin boundary and placeholder-asset impact

- Mechanical contract: building semantic definition, positive footprint dimensions, integer anchor/cells, explicit grid bounds, occupancy, deterministic status, and row-major footprint order.
- Replaceable presentation contract: display name, description, icon slot, style slot, world-visual slot, future preview style tokens, and all future textures/audio/animation remain outside the validator.
- This slice introduces and resolves no image. Existing and future images are temporary placeholders and cannot determine footprint size, bounds, occupancy, or placement validity.
- Valid/invalid placement is exposed as a semantic status so a later adapter can combine text/shape/icon cues with theme colors; gameplay meaning is not encoded by color alone.
- The focused smoke substitutes all Basic Nest presentation metadata and proves identical placement mechanics. This verifies decoupling only, not subjective GUI quality.
