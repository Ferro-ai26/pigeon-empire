# Active Phase

Phase: Phase 1 — Isometric World
Status: Approved slice — ready for build

## Objective

Add runtime-only selection for rooftop world objects through semantic grid cells, with replaceable selection feedback that does not make placeholder artwork part of the interaction contract.

## Gameplay purpose

Let the player identify and select an occupied rooftop cell so later building and pigeon interactions can target a world object through a narrow, deterministic API.

## Exact scope

- Add a small typed selection controller to the existing `WorldObjects` container.
- Resolve a rooftop cell to an existing `RooftopWorldObject` by its semantic `grid_cell`; when multiple objects share a cell, reverse sibling order is the deterministic topmost tie-break.
- Expose callable selection APIs for selecting by valid rooftop cell, clearing selection, and reading the selected object/cell.
- Wire primary pointer presses to the existing isometric projection so an occupied cell selects its object and a valid empty cell clears object selection.
- Add a typed selected-state API to `RooftopWorldObject` and an editor-visible, non-color-only placeholder marker beneath its replaceable visual subtree.
- Add a focused headless smoke covering occupied selection, empty-cell clearing, invalid-cell rejection, deterministic tie-breaking, pointer-independent callable behavior, adjacent-state isolation, and presentation-token substitution.

## Non-goals

- Buildings, placement, resources, pigeons, movement, collision/physics hitboxes, navigation, production, progression, persistence, object details panels, hover states, drag selection, multi-select, or commands.
- Changes to grid selection semantics, camera behavior, coordinate projection, visual-layer math, rooftop dimensions, or scene startup policy.
- Texture-alpha or pixel-perfect hit testing, deriving interaction bounds from placeholder dimensions, or attaching gameplay meaning to a color/image.
- New image files, final art, final typography, animation, audio, browser/export work, Android work, combat, multiplayer, monetization, or unrelated refactors.

## Likely affected systems/files

- `scenes/main.tscn`
- `scenes/world/rooftop_world_object.tscn`
- `scripts/world/rooftop_world_object.gd`
- `scripts/world/rooftop_world_selection.gd` (new controller)
- `tests/phase01_world_object_selection_smoke.gd` (new)

The Builder may adjust the new controller/test filenames within the existing `world` and `tests` boundaries if Godot resource loading requires it, but must not broaden scope.

## Acceptance criteria

1. Headless startup exits successfully and prints exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. `scenes/main.tscn` keeps exactly one editor-visible `WorldObjects` container, now owning one typed selection controller and the two verified placeholder object instances.
3. Selecting either occupied semantic cell returns success, exposes that exact `RooftopWorldObject` and cell through typed read APIs, and marks exactly that object selected.
4. Selecting a valid empty rooftop cell returns no object, clears the prior object selection, and does not change the rooftop grid's selected-cell state.
5. Requesting a cell outside the existing 5 × 5 rooftop returns failure/rejection without changing the last selected world object or its selected marker state.
6. If two test objects share a cell, reverse scene sibling order deterministically selects the topmost candidate; textures, polygon bounds, colors, and node names do not affect the result.
7. Primary-pointer handling converts the pointer through the existing `WorldObjects` local transform and `IsometricGrid.world_to_tile()` contract, then delegates to the same callable selection API used by tests. No physics or texture hitbox is introduced.
8. Object selection and clearing do not change object `grid_cell`, position, `z_index`, grid projection/bounds, camera position/zoom, or the rooftop grid's own selected-cell state.
9. Selection feedback includes an editor-visible shape/geometry cue and is not communicated solely by color. Its colors, dimensions, visibility styling, and future image/icon replacement remain presentation properties outside selection logic.
10. The focused smoke temporarily changes or replaces a selection-feedback presentation property, proves selection identity and behavior are unchanged, restores it, prints exactly one `PHASE01_WORLD_OBJECT_SELECTION_SMOKE PASS`, and exits 0.
11. Headless import/startup, baseline smoke, all prior Phase 1 smokes, the new focused smoke, and `git diff --check` pass.

## Focused validation commands

```bash
/home/ubuntu/.local/bin/godot4 --headless --path . --import
/home/ubuntu/.local/bin/godot4 --headless --path . --quit
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_visual_layering_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_world_object_selection_smoke.gd
git diff --check
```

## Save/schema impact

None. Selection is runtime-only and stores object references/cells only for the current scene. No save file, persistent identifier, migration, or schema change is permitted.

## Risks and rollback boundary

- Both `RooftopGrid` and world-object selection can observe primary pointer input. The controller must not mutate or depend on grid selection; the focused smoke must prove adjacent state isolation.
- Camera/parent transforms can produce wrong cells if pointer coordinates are treated as global pixels. Convert through the `WorldObjects` local transform before using the shared projection utility.
- Visual or collision-bound hit testing would couple mechanics to temporary art. Resolve candidates solely from semantic cells and documented sibling order.
- A selected Node reference can become stale if an object leaves the tree. Clearing or validating the reference must be safe; object removal behavior beyond avoiding an invalid retained selection is not a lifecycle system in this slice.
- Rollback boundary: the selection controller, its `WorldObjects` scene attachment, selected-state additions to the reusable world-object scene/script, and the focused smoke. Reverting those changes must restore the verified visual-layering slice with no migration.

## Reskin boundary and placeholder-asset impact

- `grid_cell`, candidate resolution, selected identity, and tie-breaking are mechanics. They must not depend on textures, icons, fonts, colors, copy, polygon dimensions, animation styling, audio, or final theme resources.
- `PlaceholderVisual` and the new selection marker remain temporary, replaceable presentation children. No image file is added or treated as final art.
- Selection feedback must expose semantic style slots/properties and a non-color geometry cue so Kevin can replace its color, shape, icon, or entire visual subtree without changing controller or gameplay code.
- Pointer targeting is cell-based, not sprite-bound; changing placeholder dimensions or art composition must not alter which object is selected.
- The substitution smoke proves mechanics/presentation decoupling only. Pointer feel, overlap readability, and final visual quality remain explicit manual GUI QA items.
