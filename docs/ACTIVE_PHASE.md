# Active Phase

Phase: Phase 2 — Resource Foundation
Status: Approved slice — ready for build

## Objective

Add one editor-visible starter gathering panel and a narrow runtime coordinator that compose the verified resource catalog, gathering-action catalog, ledger, executor, and resource HUD into a playable click-to-gather loop in `scenes/main.tscn`.

## Gameplay purpose

Let the player perform each of the three starter gathering actions and immediately see the corresponding resource counter increase, creating the smallest playable resource loop before Phase 3 construction work begins.

## Exact scope

- Add one reusable editor-visible gathering panel with exactly one control per authoritative gathering-action definition, in catalog order.
- Bind controls by stable semantic action ID. Use gathering-action display metadata only for player-facing copy and semantic icon/style slots.
- Add a narrow main-scene/runtime coordinator that loads both verified catalogs, creates one runtime ledger and executor, sets up the existing resource HUD and gathering panel, and handles an action request by executing exactly one action then explicitly refreshing the HUD.
- Compose the gathering panel and existing resource HUD into `scenes/main.tscn` without moving resource authority into UI nodes.
- Expose callable setup and action-request methods so focused headless tests can exercise the loop without synthesizing pointer input.
- Keep layout and styling centralized in editor-visible scenes, themes, or exported semantic style properties.
- Add one focused smoke covering successful setup, all three actions, exact accumulation, unrelated-balance isolation, rejection safety, deterministic catalog order, and full presentation-metadata substitution.

## Non-goals

- Buildings, placement, costs, storage, pigeons, jobs, production timers, passive income, objectives, upgrades, selection-driven gathering, world-object rewards, cooldowns, stamina, tooltips, animations, audio, persistence, autosave, offline gains, or economy rebalance.
- Changes to resource/action IDs, authoritative membership/order, reward amounts, ledger rules, or executor semantics.
- Event buses, autoloads, global singletons, schema versions, migrations, Android/browser/export work, monetization, combat, multiplayer, final art, or unrelated refactors.

## Likely affected systems/files

- `scenes/main.tscn` (compose the runtime UI and coordinator)
- `scripts/main.gd` (or one new narrow runtime coordinator script; preserve startup behavior)
- `scenes/ui/gathering_panel.tscn` (new editor-visible reusable action panel)
- `scenes/ui/gathering_action_button.tscn` (optional reusable row/control)
- `scripts/ui/gathering_panel.gd` (semantic action binding and request emission only)
- `scripts/ui/gathering_action_button.gd` (optional narrow presentation binding helper)
- `tests/phase02_playable_gathering_loop_smoke.gd` (new focused smoke)

Existing catalog, ledger, executor, and HUD files may receive only narrow compatibility helpers required for composition. Do not alter their authority boundaries or authoritative data.

## Acceptance criteria

1. Headless import and startup succeed, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. `scenes/main.tscn` visibly composes the existing resource HUD and a reusable editor-visible gathering panel while preserving the rooftop world and camera nodes.
3. Runtime setup loads `res://data/resources/resource_definitions.json` and `res://data/resources/gathering_action_definitions.json`, then creates exactly one ledger and one executor for the session.
4. Successful panel setup creates exactly three controls in authoritative action order: `gather_crumbs`, `gather_twigs`, `gather_shinies`.
5. Every control retains a stable semantic action ID independent of node name, text, icon, color, dimensions, order of clicks, or placeholder appearance.
6. One accepted request executes exactly one catalog-defined action and performs exactly one ledger credit; it does not calculate or duplicate rewards in UI/coordinator code.
7. After one request for each starter action, the HUD shows exact balances `crumbs=1`, `twigs=1`, and `shinies=1`; repeated requests accumulate exactly according to catalog rewards.
8. Each successful action changes only its declared resource balance, and the HUD refresh remains read-only.
9. Empty/unknown action IDs, invalid dependencies, and failed setup reject deterministically without ledger mutation or replacement of the last valid panel/HUD state.
10. Startup/setup failure does not expose partially initialized interactive controls and reports a deterministic failure without crashing.
11. Player-facing action/resource names come from catalog metadata. No gameplay, ledger, executor, or coordinator script hardcodes display copy, icon paths, colors, dimensions, or final-theme values.
12. Layout, typography, controls, panel styles, semantic icon/style resolution, animation styling, and audio remain replaceable presentation concerns centralized outside gameplay/state logic.
13. Mechanically meaningful action identity is not conveyed solely by color or placeholder imagery; every gathering control includes readable text.
14. Replacing every resource and gathering-action presentation metadata field in equivalent valid catalogs may change rendered copy/slots but leaves semantic IDs, order, reward mechanics, ledger snapshots, and HUD balances unchanged.
15. No final image is introduced. Missing icon slots use a documented text/shape/control fallback without changing gameplay code.
16. No save file, schema, autoload, building/storage system, timer, new resource/currency, or balance change is introduced.
17. The focused smoke prints exactly one `PHASE02_PLAYABLE_GATHERING_LOOP_SMOKE PASS` and exits 0.
18. Headless import/startup, baseline smoke, all four Phase 1 smokes, all five existing Phase 2 smokes, the new focused smoke, clean parser/error scanning, and `git diff --check` pass.

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
git diff --check
```

For every Godot command, capture combined output and fail validation on `SCRIPT ERROR`, `Parse Error`, or unexpected `ERROR:` lines. Confirm each expected success marker appears exactly once.

## Save/schema impact

None. The coordinator owns runtime-only catalogs, ledger, executor, and UI bindings for one session. No save contract, schema version, migration, autosave, or persisted balance is introduced.

## Risks and rollback boundary

- Main-scene composition can accidentally turn UI into resource authority; all mutations must remain a single executor call against the session ledger.
- Multiple signal connections can double-credit a click; setup must be idempotent or reject repeat wiring, and the smoke must prove one request produces one reward.
- Partial catalog/setup failure can leave live controls bound to invalid state; candidate setup must complete before publishing interactivity.
- Hardcoded action labels or icon-dependent identity would couple mechanics to this placeholder skin; bind semantic IDs separately from display metadata.
- Main startup currently exits in headless mode. The smoke should instantiate the scene detached and invoke the coordinator's narrow callable setup/action API, or isolate only the coordinator, rather than weakening startup policy.
- Rollback boundary: the new gathering panel/control scenes and scripts, focused smoke, and the narrow `main.tscn`/coordinator composition lines. Reverting that set restores the verified Phase 2 catalogs, ledger, executor, and standalone HUD without migration.

## Reskin boundary and placeholder-asset impact

- The mechanical contract is stable semantic action/resource IDs, catalog order/rewards, executor results, and ledger balances. UI controls, labels, icon/style slots, layout, themes, animation, and audio are replaceable adapters.
- All image files remain temporary placeholders. This slice adds no final image and must not infer action identity, hit area, reward, or resource mapping from texture appearance or dimensions.
- Gathering and resource display names/descriptions/icon slots/style slots may all be substituted without changing coordinator, executor, ledger, or action handling code.
- Controls must retain readable text/non-color identity when icons are absent. Semantic icon slots may resolve later through a centralized skin/theme contract.
- The focused smoke must substitute all presentation metadata and prove semantic control IDs/order, exact executor rewards, ledger snapshots, and HUD values remain identical. This proves decoupling, not subjective visual quality.
- Manual GUI QA remains required for mobile tap targets, overlap, readability, hierarchy, camera/UI coexistence, and click feel; headless tests must not claim those qualities.
