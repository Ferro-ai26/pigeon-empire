# Active Phase

Phase: Phase 1 — Isometric World
Status: Approved slice — ready for build

## Objective

Add a bounded, deterministic rooftop camera controller that supports pointer-drag panning and stepped zoom without changing grid coordinates or cell selection semantics.

## Gameplay purpose

Let the player inspect the rooftop comfortably while preserving the reliable tile-selection foundation needed by later world objects and buildings.

## Exact scope

- Add one `Camera2D` child to the editor-visible main scene, owned by a small typed world-camera controller.
- Support primary-pointer drag panning through a callable controller API used by input handling; mouse drag is the required desktop/browser mapping and the API must remain suitable for later touch wiring.
- Support mouse-wheel stepped zoom through the same controller, clamped to centralized minimum and maximum zoom values.
- Clamp the camera's target position to centralized rectangular world-space bounds sized for this fixed rooftop slice.
- Keep camera state independent from `IsometricGrid`, `RooftopGrid.selected_cell`, and all placeholder draw/style properties.
- Add a focused headless smoke test that exercises the callable pan/zoom API, clamp edges, required scene nodes, and preservation of grid projection and selection state.

## Non-goals

- Touch gestures, pinch zoom, inertia, smoothing, edge scrolling, camera shake, minimaps, or saved camera state.
- Enlarging or procedurally generating the rooftop.
- Resource gathering, buildings, placement previews, pigeons, production, progression, or persistence.
- New image assets, final art, final typography, final animation, final audio, Android work, combat, multiplayer, or monetization.
- Refactoring the existing projection or rooftop drawing implementation beyond compatibility fixes strictly required by camera input coordinates.

## Likely affected systems/files

- `scenes/main.tscn`
- `project.godot` only if named input actions are required
- `scripts/world/rooftop_camera.gd` (new)
- `tests/phase01_camera_controls_smoke.gd` (new)
- `scripts/world/rooftop_grid.gd` only if a minimal viewport-to-world pointer conversion fix is proven necessary

The Builder may adjust the new camera script path within the existing `world` boundary if Godot resource loading requires it, but must not broaden scope.

## Acceptance criteria

1. Headless startup exits successfully and prints `PIGEON_EMPIRE_STARTUP_OK`.
2. `scenes/main.tscn` contains exactly one enabled `Camera2D` with a dedicated typed controller script.
3. A non-zero pan request through the callable API changes camera target position in the expected direction, and requests beyond every configured edge clamp to the centralized camera bounds.
4. Zoom-in and zoom-out requests change both camera axes uniformly in deterministic steps and clamp at centralized minimum and maximum values.
5. Camera movement and zoom do not change `IsometricGrid` projection results, rooftop bounds, or the currently selected valid cell.
6. Existing valid-cell selection remains callable after camera movement; invalid coordinates still leave selection unchanged.
7. Camera behavior contains no dependency on textures, icons, fonts, colors, copy, placeholder image dimensions, or final visual theme values.
8. The focused smoke prints exactly one `PHASE01_CAMERA_CONTROLS_SMOKE PASS` success line and exits 0.
9. Existing bootstrap and Phase 1 grid smokes remain green, and `git diff --check` reports no whitespace errors.

## Focused validation commands

```bash
/home/ubuntu/.local/bin/godot4 --headless --path . --import
/home/ubuntu/.local/bin/godot4 --headless --path . --quit
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd
git diff --check
```

## Save/schema impact

None. Camera position, drag state, and zoom are runtime-only. No save file, migration, or schema change is permitted.

## Risks and rollback boundary

- `Camera2D` transforms can expose incorrect pointer-coordinate conversion in rooftop selection. Any fix must convert viewport input to world/local coordinates through Godot transforms without changing projection math.
- Drag input can conflict with click selection. A drag must not be interpreted as a different cell-selection mechanic; keep camera gesture state isolated and retain the existing callable selection contract.
- Broad bounds or excessive zoom can reveal empty world space. Use conservative centralized constants for this fixed 5 × 5 rooftop rather than deriving mechanics from viewport art.
- Rollback boundary: the camera node/script, optional named input actions, focused smoke, and any narrowly proven pointer-coordinate compatibility fix. Reverting the slice must restore the verified grid with no data migration.

## Reskin boundary and placeholder-asset impact

- No image files are added or modified; all current images and drawn grid styling remain temporary placeholders.
- Camera mechanics operate only on world-space position, zoom, viewport input, and semantic bounds. They must not inspect sprite sizes, texture dimensions, colors, fonts, copy, layout styling, animation styling, or audio.
- Camera limits and zoom constants belong in the controller as gameplay/navigation configuration, not in placeholder assets or theme tokens.
- The focused smoke must temporarily alter at least one existing rooftop style token while the camera is displaced, then prove camera bounds/zoom and grid selection state are unchanged before restoring the token. This verifies substitution safety, not subjective visual quality.
