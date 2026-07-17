# Active Phase

Phase: Phase 1 — Isometric World
Status: Approved slice — ready for build

## Objective

Add a deterministic, data-independent visual-layering contract for rooftop world nodes so objects on lower isometric rows render in front of objects on higher rows without coupling draw order to placeholder art.

## Gameplay purpose

Make rooftop occupants and future buildings overlap predictably, preserving readable spatial relationships before selectable world objects are introduced.

## Exact scope

- Add a small typed world-layering utility that converts a world node's semantic rooftop cell into a deterministic `z_index`.
- Add an editor-visible `WorldObjects` container to `scenes/main.tscn` as the stable parent for later rooftop objects.
- Add two non-interactive placeholder world-object nodes at different valid cells solely to demonstrate and test ordering; their cell metadata must be independent from position, texture size, and visual styling.
- Apply layer values through a narrow callable API suitable for later buildings and pigeons.
- Add a focused headless smoke test covering layer ordering, equal-depth determinism, invalid-cell rejection, scene ownership, and style/placeholder substitution safety.

## Non-goals

- Object selection, hover feedback, placement, buildings, resources, pigeons, movement, collision, navigation, production, progression, persistence, or UI panels.
- Camera changes, grid projection changes, rooftop resizing, procedural maps, or sorting every frame.
- New image files, final art, final typography, animation, audio, browser/export work, Android work, combat, multiplayer, monetization, or unrelated refactors.
- Deriving draw order from sprite bounds, texture dimensions, pixel colors, node names, or final art composition.

## Likely affected systems/files

- `scenes/main.tscn`
- `scenes/world/rooftop_world_object.tscn` (new editor-visible placeholder component)
- `scripts/world/world_layering.gd` (new typed utility)
- `scripts/world/rooftop_world_object.gd` (new small component/controller)
- `tests/phase01_visual_layering_smoke.gd` (new)

The Builder may adjust new filenames within the existing `world` boundary if Godot resource loading requires it, but must not broaden scope.

## Acceptance criteria

1. Headless startup exits successfully and prints exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. `scenes/main.tscn` contains exactly one editor-visible `WorldObjects` container and exactly two placeholder world-object instances at distinct valid rooftop cells.
3. Each world object exposes semantic `grid_cell` metadata and receives its `z_index` through one typed callable layering contract; no per-object hardcoded layer values are permitted.
4. For two cells with different isometric depth (`x + y`), the object at greater depth receives the greater layer and therefore renders in front.
5. Cells with equal depth produce the same base layer deterministically; sibling order remains an explicit scene-order tie-break and is documented in code rather than inferred from artwork.
6. The layering API rejects cells outside the existing 5 × 5 rooftop without changing the object's last valid cell, position, or layer.
7. Applying or reapplying visual layers does not change `IsometricGrid` projection results, rooftop bounds, selected-cell state, or camera state.
8. Layering code contains no dependency on textures, icons, fonts, colors, copy, placeholder dimensions, animation styling, audio, or final theme resources.
9. The focused smoke temporarily changes/removes a placeholder presentation property or child while proving semantic cells and layer results remain unchanged, then restores it.
10. The focused smoke prints exactly one `PHASE01_VISUAL_LAYERING_SMOKE PASS` and exits 0; all existing smokes remain green and `git diff --check` passes.

## Focused validation commands

```bash
/home/ubuntu/.local/bin/godot4 --headless --path . --import
/home/ubuntu/.local/bin/godot4 --headless --path . --quit
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_visual_layering_smoke.gd
git diff --check
```

## Save/schema impact

None. Rooftop cells and visual layers are scene/runtime state only in this slice. No save file, migration, schema, or persistent identifier is permitted.

## Risks and rollback boundary

- Incorrect depth math can invert overlaps. The focused smoke must compare known near/far cells using the existing isometric coordinate contract.
- Automatic `YSort` or pixel-position sorting can hide an art dependency and make equal-depth behavior unstable. Use explicit semantic-cell-to-layer mapping and a documented scene-order tie-break.
- Placeholder nodes could accidentally become an object-selection API. Keep them non-interactive; selection is a later bounded slice.
- Rollback boundary: the `WorldObjects` container, two placeholder instances, new layering/component scripts and scene, and focused smoke. Reverting them must restore the verified camera/grid slice with no data migration.

## Reskin boundary and placeholder-asset impact

- All visual children of the placeholder world-object scene are temporary and replaceable. No new image file is required; a simple editor-visible primitive is sufficient.
- `grid_cell` and calculated `z_index` are mechanics/presentation-bridge metadata. They must remain outside textures, colors, sprite dimensions, labels, and theme values.
- The reusable world-object scene must separate its semantic root/controller from its replaceable visual child subtree so Kevin can swap the visual identity without changing layering code.
- Mechanical meaning must be inspectable through cell metadata and tests, not solely through color or placeholder silhouette.
- The substitution smoke proves decoupling only; subjective overlap quality and final visual composition remain manual GUI QA items.
