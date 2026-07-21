# Active Phase

Phase: Phase 2 — Resource Foundation
Status: Approved slice — ready for build

## Objective

Add an immutable, typed gathering-action definition catalog that data-drives the initial manual resource rewards without executing actions, changing balances, or adding input/UI.

## Gameplay purpose

Give the later gathering executor one authoritative mapping from stable action IDs to semantic resource IDs and positive integer reward amounts, so gathering balance is not hardcoded in input, world, or UI scripts.

## Exact scope

- Add authoritative JSON definitions for exactly three initial manual actions, one each awarding `crumbs`, `twigs`, and `shinies`.
- Give each definition a stable semantic action ID, known semantic resource ID, positive integer reward amount, and presentation-only display metadata slots.
- Add typed immutable definition and catalog APIs with deterministic source order and lookup by action ID.
- Validate the complete candidate dataset before atomic publication; reject duplicate/empty action IDs, unknown resource IDs, non-positive/non-integer rewards, missing fields, malformed roots/entries, and invalid field types.
- Preserve the previously published valid catalog after every rejected reload.
- Return copied ordered collections so callers cannot mutate catalog membership or order.
- Add a focused headless smoke covering authoritative membership/order, typed lookup, reward contracts, every rejection class, atomic failed reloads, copied collections, unknown non-mutating lookup, and presentation-metadata substitution.

## Non-goals

- Executing gathering actions, crediting/debiting the resource ledger, tap/click input, cooldowns, timed/passive production, random rewards, costs, inventory capacity, buildings, pigeons, jobs, objectives, upgrades, or economy tuning beyond the three starter rewards.
- UI scenes, buttons, labels, icons, animations, audio, feedback copy, world-object changes, camera/grid changes, or startup integration.
- Autoloads, signals/event buses, save files, schema versions, migrations, autosave, offline gains, or persistence.
- New resources/currencies, resource conversion, multi-resource rewards, loot tables, final art, Android/browser/export work, monetization, combat, multiplayer, or unrelated refactors.

## Likely affected systems/files

- `data/resources/gathering_action_definitions.json` (new authoritative starter-action data)
- `scripts/resources/gathering_action_definition.gd` (new typed immutable definition)
- `scripts/resources/gathering_action_catalog.gd` (new atomic catalog/validation owner)
- `tests/phase02_gathering_action_catalog_smoke.gd` (new focused smoke)

The Builder may make a narrowly required read-only compatibility addition to `ResourceCatalog`, but must not change authoritative resource membership, resource balances, scenes, project autoloads, or gameplay integration.

## Acceptance criteria

1. Headless import and startup succeed, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. The authoritative action catalog loads exactly three definitions in source order: `gather_crumbs`, `gather_twigs`, and `gather_shinies`.
3. Those definitions target `crumbs`, `twigs`, and `shinies` respectively, and each reward is a positive integer declared in JSON rather than a gameplay, input, scene, or UI script.
4. Every target resource ID is validated against a successfully loaded authoritative `ResourceCatalog`; unknown target IDs reject the complete candidate reload.
5. Definition identity and mechanics depend only on stable action ID, semantic resource ID, and reward amount; display metadata, texture, icon appearance, color, font, copy, layout, animation, audio, dimensions, and node names are not mechanical keys.
6. Known lookup returns a typed immutable definition; unknown lookup returns `null`, does not mutate state, and does not alter deterministic order.
7. Duplicate or empty action IDs, missing fields, malformed root/entry shapes, invalid field types, unknown resource IDs, and zero/negative/non-integer rewards fail with deterministic errors.
8. Candidate data is fully validated before publication; after every rejected reload, the previous valid catalog remains intact and queryable with unchanged membership, order, targets, and rewards.
9. Ordered definition/ID collections are copies; mutating a returned collection cannot alter internal catalog state.
10. Replacing all presentation metadata in equivalent entries leaves action identity, order, target resource IDs, rewards, lookup, and validation unchanged.
11. No ledger balance, scene, autoload, save/schema, UI, input, world, production, or persistent state is introduced or changed.
12. The focused smoke prints exactly one `PHASE02_GATHERING_ACTION_CATALOG_SMOKE PASS` and exits 0.
13. Headless import/startup, baseline smoke, all four Phase 1 smokes, both existing Phase 2 smokes, the new focused smoke, and `git diff --check` pass.

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
git diff --check
```

## Save/schema impact

None. Definitions are immutable project data, the catalog is runtime-only, and this slice does not read or write save data. Stable action/resource IDs are suitable for later versioned persistence, but no save contract or migration is introduced.

## Risks and rollback boundary

- Publishing while parsing could expose a partial catalog after a late invalid entry; validate candidate order/lookup structures completely before replacing published state.
- Accepting unknown resource IDs would create actions that a ledger cannot execute; validate targets against the authoritative resource catalog.
- Hardcoding reward values in future input/UI code would defeat data-driven balance; keep reward amounts exclusively in authoritative action data and typed definitions.
- Writable definition fields or exposed internal arrays would let callers silently mutate balance data; use typed getters and copied collections.
- Godot JSON values are Variants; explicitly validate exact field types and use explicit typed locals to satisfy warning-as-error validation.
- Rollback boundary: the new JSON, definition/catalog scripts, and focused smoke. Reverting those files restores the verified ledger-only Phase 2 state without migration or scene changes.

## Reskin boundary and placeholder-asset impact

- Action ID, target semantic resource ID, and reward amount are gameplay/data contracts. Display names, descriptions, icon/style slots, textures, colors, fonts, copy, layout, animation, and audio are replaceable presentation metadata.
- No image or other presentation asset is added or read; all existing images remain temporary placeholders.
- Definitions may carry semantic icon/style slot strings, but mechanics must not load those assets or infer action/resource meaning from their appearance.
- The focused smoke must substitute every presentation field and prove identity, target, reward, lookup, validation, and order remain unchanged. This verifies the reskin boundary, not subjective visual quality.
