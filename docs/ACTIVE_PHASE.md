# Active Phase

Phase: Phase 3 — Building System
Status: Approved slice — ready for build

## Objective

Add one atomic multi-resource debit operation to the runtime `ResourceLedger`, verified against the existing Basic Nest construction-cost bundle, without creating buildings, occupancy, placement UI, storage behavior, or persistence.

## Gameplay purpose

Let a later construction command charge the complete Basic Nest cost (`25 crumbs`, `10 twigs`) as one all-or-nothing resource transaction. The player must never lose one resource when another required resource is missing or invalid.

## Exact scope

- Extend `ResourceLedger` with one narrow typed method that accepts a caller-owned dictionary of semantic resource IDs to positive integer amounts.
- Validate the entire candidate bundle before any balance changes.
- On success, debit every declared amount exactly once and return a stable semantic success result.
- On rejection, report a stable semantic failure reason and preserve the complete pre-call ledger snapshot.
- Support deterministic outcomes for success, invalid/empty bundle, unknown resource ID, invalid amount, and insufficient balance.
- Treat only positive `int` amounts as valid at this runtime boundary; do not coerce strings, floats, zero, negatives, booleans, arrays, or null values.
- Do not mutate the caller-owned cost dictionary or expose writable internal ledger storage.
- Add one focused Phase 3 headless smoke using the authoritative Basic Nest cost dictionary and an equivalent presentation-substituted definition.

## Non-goals

- Building construction commands, placement validation changes, occupancy ownership, building instances, Basic Nest scene/node creation, placement preview/ghosts, pointer input, construction buttons, refunds, demolition, movement, selection, storage caps/contributions, production, upgrades, jobs, pigeons, timers, persistence, autosave, offline gains, or main-scene integration.
- Changing resource IDs, starter balances, gathering rewards, Basic Nest costs, footprint, display metadata, authoritative data files, or existing single-resource `credit`, `can_afford`, and `debit` behavior.
- General transaction histories, currencies, reservations, rollback logs, concurrency controls, or arbitrary signed balance deltas.

## Likely affected systems/files

- `scripts/resources/resource_ledger.gd` (add atomic bundle validation/debit API and stable semantic statuses)
- `tests/phase03_construction_cost_transaction_smoke.gd` (new focused smoke)

A small typed result under `scripts/resources/` may be added only if needed to expose the stable status without presentation strings. Do not modify building definitions, building JSON, placement validation, scenes, UI, or assets.

## Acceptance criteria

1. Headless import and startup pass, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. With balances of at least `25 crumbs` and `10 twigs`, debiting the authoritative `basic_nest` construction-cost dictionary succeeds and subtracts exactly `25 crumbs` and `10 twigs` once; unrelated `shinies` remain unchanged.
3. Repeating the same debit succeeds only while the full bundle remains affordable; a rejected repeat preserves the complete pre-call balance snapshot.
4. If crumbs or twigs are individually insufficient, the operation reports insufficient balance and changes no resource balance, regardless of dictionary iteration order.
5. Empty bundles and values that are zero, negative, float, string, boolean, array, dictionary, or null reject deterministically before mutation.
6. Unknown or empty resource IDs reject deterministically before mutation, including when valid entries precede the bad entry in caller order.
7. The caller-owned bundle remains semantically unchanged after every success and rejection. Ledger ID lists and balance snapshots remain copied from internal storage.
8. Existing single-resource credit, affordability, and debit APIs retain their verified behavior; all Phase 2 smokes pass unchanged.
9. The operation depends only on stable semantic resource IDs, integer costs, and ledger balances—not building names, descriptions, icon/style/world-visual slots, textures, colors, copy, node names, layout, audio, animation, or art dimensions.
10. Substituting every Basic Nest presentation field while preserving its semantic ID and cost dictionary produces the same status and exact balance delta.
11. The slice loads no image, scene, font, theme, animation, audio, UI, or final art and introduces no image file.
12. No building, occupancy, placement, storage-cap, save/schema, autoload, main-scene, gathering reward, or resource-definition behavior is introduced or changed.
13. The focused smoke prints exactly one `PHASE03_CONSTRUCTION_COST_TRANSACTION_SMOKE PASS` and exits 0.
14. Headless import/startup, baseline smoke, all Phase 1 smokes, all Phase 2 smokes, both existing Phase 3 smokes, the new focused smoke, clean parser/error scanning, and `git diff --check` pass.

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
git diff --check
```

For every Godot command, capture combined output and fail on nonzero exit, `SCRIPT ERROR`, `Parse Error`, unexpected `ERROR:` lines, a missing marker, or a duplicate marker. Use each existing smoke's actual historical marker and require the new marker exactly once.

## Save/schema impact

None. This extends an in-memory runtime ledger operation only. It adds no save file, schema version, migration, autoload, persisted balance, building record, or offline-progress behavior.

## Risks and rollback boundary

- Sequentially debiting while validating would permit partial payment; validation of every ID, amount, and balance must finish before the first mutation.
- Loose Variant conversion could silently accept malformed costs; require exact runtime types and positive integers.
- Returning mutable internal dictionaries would compromise later checks; preserve copied snapshot behavior.
- Reaching into `BuildingCatalog` from the ledger would couple a generic resource authority to building content; the ledger receives only the semantic cost bundle.
- A later construction command must coordinate this transaction with placement/occupancy; that integration is explicitly deferred rather than faked here.
- Rollback boundary: the new ledger bundle API, its optional typed status result, and the focused smoke. Reverting them leaves the verified Phase 2 ledger and both verified Phase 3 slices unchanged with no migration.

## Reskin boundary and placeholder-asset impact

- Mechanical contract: semantic resource IDs, positive integer cost amounts, current balances, all-or-nothing validation, exact debits, and stable semantic outcomes.
- Replaceable presentation contract: building/resource names, descriptions, icons, style slots, world visuals, fonts, colors, copy, layout, animation, audio, and future transaction feedback remain outside the ledger.
- This slice introduces and resolves no image. Every current or future image is a temporary placeholder and cannot determine cost, affordability, transaction order, or balance delta.
- Failure meaning is exposed semantically so future UI can combine text, shape, and icon cues with theme colors; gameplay meaning is not encoded by color alone.
- The focused smoke substitutes every Basic Nest presentation field and proves identical transaction mechanics. This verifies decoupling only, not subjective GUI quality.
