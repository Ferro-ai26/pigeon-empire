# Active Phase

Phase: Phase 2 — Resource Foundation
Status: Approved slice — ready for build

## Objective

Add an editor-visible, read-only resource HUD panel that renders the verified resource catalog in authoritative order and refreshes displayed balances from the verified runtime ledger through a narrow presentation adapter.

## Gameplay purpose

Make the three starter resources readable during play so later gathering input can provide visible progress feedback, without introducing action controls or moving resource ownership into UI code.

## Exact scope

- Add one reusable editor-visible resource HUD scene composed of a panel/container and reusable resource rows.
- Add a small typed presenter/controller that receives a valid `ResourceCatalog` and `ResourceLedger`, creates exactly one row per catalog definition in catalog order, and refreshes each row's integer balance.
- Use catalog display metadata only for presentation text and semantic icon/style slots; use semantic resource IDs only to query balances and identify rows.
- Expose a narrow callable setup/refresh API suitable for later main-scene or gathering adapters.
- Keep layout/style values centralized in the HUD scene, theme resource, or exported semantic style properties rather than scattering them through gameplay scripts.
- Add a focused headless smoke that instantiates the HUD, injects catalog and ledger dependencies, verifies order and displayed balances before and after ledger credits, verifies invalid dependencies fail without mutating the ledger, and proves presentation substitution does not alter semantic row identity or balance behavior.

## Non-goals

- Gathering buttons, tap/click input, world-object actions, executor wiring, automatic ledger signals, event buses, animations, audio, feedback copy, timers, passive production, costs, storage, buildings, pigeons, jobs, objectives, upgrades, or economy changes.
- Changes to resource IDs, membership, order, gathering actions, rewards, or balance authority.
- Autoloads, save files, persistence, schema versions, migrations, autosave, offline gains, or startup/main-scene integration.
- Final art, bespoke icons, Android/browser/export work, monetization, combat, multiplayer, or unrelated refactors.

## Likely affected systems/files

- `scenes/ui/resource_hud.tscn` (new editor-visible reusable HUD)
- `scenes/ui/resource_row.tscn` (new editor-visible reusable row, if separation remains useful)
- `scripts/ui/resource_hud.gd` (new presentation adapter/controller)
- `scripts/ui/resource_row.gd` (optional narrow row binding helper)
- `tests/phase02_resource_hud_smoke.gd` (new focused smoke)

Narrow read-only helpers on the catalog or ledger are permitted only if required for deterministic presentation binding. Do not change authoritative data, balances, gathering execution, world scenes, startup behavior, or persistence.

## Acceptance criteria

1. Headless import and startup succeed, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. The HUD is an editor-visible reusable scene and receives supplied catalog/ledger dependencies; it does not own balances or load gathering definitions.
3. Successful setup creates exactly three rows in authoritative catalog order: `crumbs`, `twigs`, `shinies`.
4. Each row retains a stable semantic resource ID independent of its node name, label text, icon, color, dimensions, or sibling styling.
5. Initial displayed balances are integer zeroes matching the ledger; after direct ledger credits and one explicit refresh, only the corresponding displayed balances change to the exact ledger values.
6. Refresh is read-only: it never credits, debits, reorders, adds, or removes ledger resources and never mutates catalog definitions.
7. Null/invalid dependencies fail deterministically, do not crash, and leave any supplied ledger snapshot unchanged.
8. Display names come from catalog presentation metadata; no gameplay/balance script hardcodes player-facing resource names or balance values.
9. Layout, typography, panel/row styling, and semantic icon/style resolution remain presentation concerns centralized in scenes/theme tokens/exported style properties, not in the ledger, catalog, or gathering executor.
10. Replacing every resource display metadata field in an equivalent valid catalog may change rendered presentation text/slots but leaves semantic row IDs, row order, ledger snapshots, and displayed numeric balances unchanged.
11. Mechanically meaningful identity is not conveyed solely by color or placeholder imagery: every row includes readable text plus its numeric amount.
12. No final image is introduced. Missing semantic icon assets use a documented text/shape fallback without changing gameplay code.
13. No input, gathering execution, world/main scene, autoload, save/schema, timer, production, or new resource/currency is introduced or changed.
14. The focused smoke prints exactly one `PHASE02_RESOURCE_HUD_SMOKE PASS` and exits 0.
15. Headless import/startup, baseline smoke, all four Phase 1 smokes, all four existing Phase 2 smokes, the new focused smoke, and `git diff --check` pass.

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
git diff --check
```

## Save/schema impact

None. The HUD mirrors runtime-only balances and stores no authoritative or persistent state. Stable semantic resource IDs remain the binding key, but no save contract, schema version, or migration is introduced.

## Risks and rollback boundary

- Letting labels own or calculate balances would duplicate ledger authority; every numeric refresh must query the supplied ledger.
- Rebuilding rows by node name, color, or icon would couple mechanics to a skin; row identity must be the semantic resource ID.
- Embedding fixed colors, fonts, dimensions, or final-looking icon paths in controller code would poison later reskinning; keep them in editor-visible scenes/theme/style slots.
- Automatic signals or main-scene wiring would broaden this slice and create lifecycle ambiguity; use explicit setup/refresh only.
- Rollback boundary: the new HUD/row scenes, their narrow UI scripts, focused smoke, and any strictly necessary read-only compatibility lines. Reverting them restores the verified runtime resource foundation without migration or scene changes.

## Reskin boundary and placeholder-asset impact

- The mechanical boundary remains `ResourceCatalog` semantic IDs/order plus `ResourceLedger` integer balances. The HUD is a replaceable presentation adapter and must not become a source of gameplay state.
- Display name, description, icon slot, style slot, font, color, spacing, panel treatment, row dimensions, animation, and audio are replaceable presentation details.
- All existing images remain temporary placeholders. This slice should add no final image; unresolved icon slots must fall back to readable text and/or a neutral editor-visible shape.
- The focused smoke must substitute all resource presentation metadata, confirm presentation can change, and prove semantic row IDs/order and balance refresh results remain identical. This is a reskin-decoupling check, not subjective GUI approval.
- Manual GUI QA remains required later for mobile readability, overlap, spacing, and visual hierarchy; headless tests must not claim those qualities.
