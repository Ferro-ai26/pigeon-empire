# Active Phase

Phase: Phase 1 — Isometric World
Status: Approved slice — ready for build

## Objective

Implement a deterministic isometric coordinate utility and a minimal editor-visible rooftop grid that proves tiles can be projected, displayed, and selected consistently.

## Gameplay purpose

Establish the spatial foundation for the rooftop empire so later buildings, pigeons, and gathering targets can share one reliable tile-coordinate contract.

## Exact scope

- Add a typed, stateless grid utility for integer tile-to-world projection and world-to-tile conversion using one documented tile size.
- Add a small fixed rooftop grid to the main scene using project-owned placeholder visuals.
- Add pointer selection for valid cells and one clearly visible selected-cell state.
- Keep grid dimensions and projection constants centralized rather than scattered through UI or scene scripts.
- Add a focused headless smoke test covering projection round trips, grid bounds, required scene nodes, and selection-state changes through a callable API.

## Non-goals

- Camera pan/zoom.
- Resource gathering, buildings, placement previews, pigeons, jobs, production, progression, or persistence.
- Procedural maps, combat, multiplayer, monetization, Android work, final art, or final audio.
- More than one rooftop or any off-grid movement.

## Likely affected systems/files

- `scenes/main.tscn`
- `scripts/main.gd`
- `scripts/world/isometric_grid.gd` (new)
- `scenes/world/rooftop_grid.tscn` (new)
- `scripts/world/rooftop_grid.gd` (new)
- `tests/phase01_isometric_grid_smoke.gd` (new)

The Builder may adjust exact new paths within the same `world` boundary if required by Godot resource loading, but must not broaden scope.

## Acceptance criteria

1. Headless startup exits successfully and prints `PIGEON_EMPIRE_STARTUP_OK`.
2. The main scene contains one fixed rooftop grid with at least 4 × 4 valid cells rendered in an isometric diamond layout.
3. Every valid integer cell round-trips through tile-to-world and world-to-tile conversion at its cell center.
4. Out-of-bounds coordinates are rejected by a single grid-bounds API.
5. Selecting a valid cell updates a queryable selected-cell value and a visible highlight; invalid coordinates do not change the current selection.
6. The focused smoke prints exactly one `PHASE01_ISOMETRIC_GRID_SMOKE PASS` success line and exits 0.
7. Existing bootstrap smoke remains green and `git diff --check` reports no whitespace errors.

## Focused validation commands

```bash
godot --headless --path . --quit
godot --headless --path . -s res://tests/smoke_test.gd
godot --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd
git diff --check
```

Use the actual installed Godot 4 binary if `godot` is not the executable name.

## Save/schema impact

None. Selection and grid state are runtime-only; no save file or schema may be introduced in this slice.

## Risks and rollback boundary

- Inverse projection can select adjacent cells near diamond edges; smoke only guarantees exact cell-center round trips, while pointer behavior must clamp through the same bounds API.
- Placeholder drawing can become coupled to grid math; keep projection logic stateless and independent from rendering.
- Rollback boundary: all changes are confined to the listed Phase 1 world/grid files, main-scene wiring, and focused smoke. Reverting this slice must restore the Phase 0 boot scene without data migration.
