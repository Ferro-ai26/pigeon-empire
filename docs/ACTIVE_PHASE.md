# Active Phase

Phase: Phase 3 — Building System
Status: Approved slice — ready for build

## Objective

Add an immutable, JSON-backed building-definition catalog for the single starter building `basic_nest`, including its semantic footprint, construction costs, and storage contribution, without adding placement, construction, spending, or runtime building state.

## Gameplay purpose

Establish one authoritative, testable definition for the Basic Nest so later Phase 3 slices can validate placement, charge construction costs, and apply storage from the same semantic data instead of scattering building rules through UI or world scripts.

## Exact scope

- Add one authoritative building-definition JSON document containing exactly `basic_nest`.
- Define stable mechanical fields for semantic building ID, positive integer footprint width/height, construction costs keyed by existing resource IDs, and non-negative storage contributions keyed by existing resource IDs.
- Include replaceable display metadata for name, description, semantic icon slot, semantic style slot, and semantic world-visual slot.
- Add a typed immutable building-definition value object and catalog loader with known/unknown lookup and copied deterministic ordered enumeration.
- Validate the complete candidate data before publication; failed reloads must preserve the last valid catalog.
- Inject or supply the verified `ResourceCatalog` during loading so every cost/storage resource ID is validated against the authoritative resource set.
- Add one focused headless smoke for authoritative membership/order, exact Basic Nest mechanics, lookup immutability, malformed-data rejection, atomic failed reloads, copied collections, and full presentation-metadata substitution.

## Non-goals

- Placement preview, grid occupancy, placement validation, building instances, construction commands, resource debits, affordability UI, storage runtime state/caps, building selection, demolition, production, upgrades, pigeons/jobs, timers, persistence, autosave, or offline gains.
- More than one building definition, balance tuning beyond the single authoritative Basic Nest values already selected for this slice, new resources/currencies, or changes to Phase 2 resource/action data.
- Loading scenes, textures, fonts, audio, animations, or final art from the mechanics catalog.
- Main-scene composition, UI work, autoloads, event buses, Android/browser/export work, monetization, combat, multiplayer, or unrelated refactors.

## Likely affected systems/files

- `data/buildings/building_definitions.json` (new authoritative Basic Nest definition)
- `scripts/buildings/building_definition.gd` (new typed immutable value object)
- `scripts/buildings/building_catalog.gd` (new atomic JSON-backed catalog)
- `tests/phase03_building_catalog_smoke.gd` (new focused smoke)

Existing `ResourceCatalog`/`ResourceDefinition` code may receive only a narrow read-only compatibility helper if strictly required. Do not alter Phase 2 authority, membership, order, balances, or behavior.

## Acceptance criteria

1. Headless import and startup pass, and startup prints exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. Loading the authoritative building data with a verified resource catalog succeeds and publishes exactly one definition in deterministic source order: `basic_nest`.
3. The Basic Nest definition exposes stable typed mechanical data: semantic ID, positive integer footprint dimensions, construction-cost entries, and non-negative storage-contribution entries.
4. The authoritative Basic Nest cost/storage keys all resolve to known Phase 2 resource IDs; unknown resource IDs reject the entire candidate load.
5. Construction costs are positive integers. Storage contributions are non-negative integers, and the definition contributes positive storage to at least one authoritative resource.
6. JSON numeric validation accepts only finite integral numeric values in allowed ranges; fractional, negative, zero where positivity is required, string, boolean, null, and overflow-like invalid values reject deterministically.
7. Empty/duplicate building IDs, missing fields, empty cost maps, malformed root/entry/map shapes, invalid footprints, duplicate semantic entries, and invalid presentation metadata reject deterministically.
8. The catalog validates the complete candidate set before publication. Every failed reload preserves the previous valid definition, order, lookup behavior, and size with no partial candidate state.
9. Known lookup returns the typed Basic Nest definition; unknown lookup returns null and does not mutate catalog state.
10. Ordered enumeration and returned cost/storage dictionaries are copies; caller mutation cannot change catalog membership, order, or published definition mechanics.
11. Gameplay identity and mechanics depend only on semantic IDs, footprint, resource IDs, costs, and storage amounts—not node names, copy, colors, textures, dimensions of art, or placeholder appearance.
12. Display name, description, icon slot, style slot, and world-visual slot are presentation metadata only. Substituting all of them leaves identity, order, footprint, costs, storage, validation, and lookup unchanged.
13. The mechanics catalog does not load images, scenes, fonts, themes, animation, or audio. No image file is introduced; all existing and future images remain temporary placeholders.
14. Mechanically important building identity is available as readable semantic data and is not encoded solely by color or a placeholder image.
15. No placement, debit, storage-cap runtime, building instance, main-scene, save/schema, autoload, resource membership, or economy-execution behavior is introduced or changed.
16. The focused smoke prints exactly one `PHASE03_BUILDING_CATALOG_SMOKE PASS` and exits 0.
17. Headless import/startup, baseline smoke, all Phase 1 smokes, all Phase 2 smokes, the new focused smoke, clean parser/error scanning, and `git diff --check` pass.

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
git diff --check
```

For every Godot command, capture combined output and fail validation on `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, nonzero exit, missing marker, or duplicate marker. Use each existing smoke's actual historical marker; require the new Phase 3 marker exactly once.

## Save/schema impact

None. This slice adds immutable definitions only. It introduces no runtime building instances, resource debits, storage balances/caps, save files, schema version, migration, autosave, or persisted state.

## Risks and rollback boundary

- Defining placement or storage runtime behavior inside the catalog would couple future systems to data-loading code; keep the catalog immutable and presentation-neutral.
- Permissive Variant conversion could accept fractional or malformed numeric data; validate numeric type, finiteness, integrality, and range before conversion.
- Publishing entries while parsing could expose partial state after a late invalid field; build and validate candidate structures completely before replacing published state.
- Returning writable cost/storage maps could violate claimed immutability; duplicate nested collections and prove caller mutation isolation.
- Hardcoded scene paths or texture dimensions would turn a placeholder skin into a mechanical contract; retain only semantic presentation slots.
- Rollback boundary: the new building JSON, two building catalog scripts, and focused smoke. Reverting those files returns the verified Phase 2 project unchanged with no migration.

## Reskin boundary and placeholder-asset impact

- Mechanical contract: semantic building/resource IDs, deterministic order, footprint cells, construction amounts, and storage amounts.
- Replaceable presentation contract: display name, description, semantic icon slot, semantic style slot, and semantic world-visual slot. Later presentation adapters may resolve those slots through centralized themes/assets without changing the catalog's mechanical API.
- This slice introduces no image. Every current or future image is temporary placeholder art and must not determine footprint, placement validity, costs, storage, selection, or building identity.
- The focused smoke must substitute every Basic Nest presentation field and prove identical ID, order, footprint, costs, storage, validation, and lookup. This proves system decoupling, not subjective visual quality.
- No GUI/visual-quality claim is in scope for this data-only slice.
