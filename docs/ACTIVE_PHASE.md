# Active Phase

Phase: Phase 2 — Resource Foundation
Status: Approved slice — ready for build

## Objective

Add a runtime-only gathering action executor that resolves a semantic action ID through the verified gathering catalog and atomically credits its declared reward to the verified resource ledger.

## Gameplay purpose

Make the three starter gathering actions mechanically executable through one narrow, deterministic API, proving the first manual resource-gain loop without coupling it to UI, input, world objects, or presentation assets.

## Exact scope

- Add a typed runtime-only executor initialized with a valid `GatheringActionCatalog` and `ResourceLedger`.
- Expose one callable operation that accepts a semantic gathering action ID, resolves its immutable definition, and credits exactly that definition's resource ID and reward amount to the ledger.
- Reject unknown/empty action IDs and missing dependencies deterministically without mutating any ledger balance.
- Ensure one successful call produces exactly one ledger credit and does not mutate the action catalog or unrelated resource balances.
- Return a small typed/semantic result or deterministic status suitable for later UI/input adapters without exposing presentation metadata as a mechanical dependency.
- Add a focused headless smoke covering every starter action, repeated execution, exact deltas, unrelated-balance isolation, invalid calls, missing dependencies, catalog immutability, and presentation-metadata substitution.

## Non-goals

- Buttons, labels, HUD/resource counters, tap/click input, world-object interaction, signals/event buses, animations, audio, feedback copy, cooldowns, timers, passive production, random rewards, costs, inventory capacity, buildings, pigeons, jobs, objectives, upgrades, or economy changes.
- Changes to starter action IDs, resource targets, reward amounts, resource membership, or catalog order.
- Autoloads, scene/startup integration, persistence, save files, schema versions, migrations, autosave, or offline gains.
- Multi-resource rewards, loot tables, final art, Android/browser/export work, monetization, combat, multiplayer, or unrelated refactors.

## Likely affected systems/files

- `scripts/resources/gathering_action_executor.gd` (new typed runtime execution boundary)
- `tests/phase02_gathering_action_executor_smoke.gd` (new focused smoke)

Narrow compatibility changes to the existing catalog or ledger are permitted only if required to support typed read-only execution or deterministic failure reporting. Do not change authoritative data, balances, scenes, autoloads, or startup behavior.

## Acceptance criteria

1. Headless import and startup succeed, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. A valid executor uses only the supplied `GatheringActionCatalog` and `ResourceLedger`; it does not load JSON, scenes, textures, or presentation resources itself.
3. Executing `gather_crumbs`, `gather_twigs`, or `gather_shinies` credits exactly the resource and positive integer reward declared by that action definition.
4. Each successful call applies exactly one credit; repeated calls accumulate deterministically by the declared reward amount.
5. Executing one action leaves every unrelated resource balance unchanged.
6. Empty and unknown action IDs fail deterministically, report a stable semantic failure status, and leave the complete ledger snapshot unchanged.
7. Missing/null catalog or ledger dependencies cannot produce a successful execution and cannot mutate external state.
8. Execution does not mutate catalog membership, source order, definitions, action IDs, targets, or rewards.
9. Mechanics depend only on semantic action ID, semantic resource ID, and reward amount. Display name, description, icon/style slots, textures, colors, fonts, copy, layout, animation, audio, image dimensions, and node names are not used to resolve or award an action.
10. Replacing every presentation metadata field in an equivalent valid action catalog leaves execution results and ledger deltas unchanged.
11. No UI, input, scene, world, autoload, save/schema, persistent state, timer, production, or new resource/currency is introduced or changed.
12. The focused smoke prints exactly one `PHASE02_GATHERING_ACTION_EXECUTOR_SMOKE PASS` and exits 0.
13. Headless import/startup, baseline smoke, all four Phase 1 smokes, all three existing Phase 2 smokes, the new focused smoke, and `git diff --check` pass.

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
git diff --check
```

## Save/schema impact

None. The executor and ledger balances remain runtime-only. Stable semantic action/resource IDs are used, but this slice introduces no save contract, persisted balance, schema version, or migration.

## Risks and rollback boundary

- Bypassing the catalog and hardcoding reward values would create duplicated balance authority; execution must read target and amount only from the resolved immutable definition.
- A failure path that credits before validation could partially mutate the ledger; resolve and validate dependencies/action before performing the single credit.
- Returning presentation-heavy results could couple later adapters to placeholder copy/assets; expose semantic status and IDs only.
- Broad ledger/catalog changes could destabilize already verified contracts; prefer a new narrow executor and retain existing APIs.
- Rollback boundary: the new executor script, focused smoke, and any narrowly justified compatibility lines. Reverting them restores the verified catalog-plus-ledger state with no migration or scene changes.

## Reskin boundary and placeholder-asset impact

- Action ID, resource ID, and reward amount are the complete mechanical execution contract. All display metadata and visual/audio styling remain replaceable presentation concerns.
- No image, font, audio, theme, scene, or other presentation asset is added, loaded, or changed; all existing image files remain temporary placeholders.
- The executor must not inspect icon/style slots or infer mechanics from texture appearance, color, copy, dimensions, layout, animation, audio, or node names.
- The focused smoke must rebuild an equivalent catalog with every presentation field replaced, execute the same action sequence, and prove identical semantic results and ledger deltas. This verifies decoupling only, not subjective visual quality.
