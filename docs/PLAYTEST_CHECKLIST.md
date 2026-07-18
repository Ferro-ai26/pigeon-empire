# Playtest Checklist

## Bootstrap baseline

- [ ] Project opens in Godot 4 without parser/resource errors.
- [ ] Main scene starts and shows the rooftop-grid title and one 5 × 5 isometric rooftop.
- [x] Headless startup exits successfully.
- [x] Automated smoke test loads and instantiates the main scene.

## Phase 1 — Isometric world

- [ ] Grid cells form a readable diamond layout with no missing cells.
- [ ] Clicking a valid diamond moves the gold selected-cell highlight to that cell.
- [ ] Clicking outside the rooftop does not move or clear the current selection.
- [x] Focused Phase 1 grid smoke passes projection round trips, bounds, scene-node, selection-state, and style-token substitution checks.
- [ ] Dragging with the primary mouse button pans the rooftop in the expected direction and stops at each world bound.
- [ ] Mouse-wheel steps zoom uniformly in and out, remain within the configured limits, and keep the rooftop comfortably framed.
- [ ] Clicking valid and invalid cells after panning and zooming preserves the documented selection behavior.
- [x] Focused camera smoke passes scene-node, callable pan, bounds, stepped zoom, selection-preservation, and style-token substitution checks.
- [ ] The two temporary rooftop objects overlap in the expected near-row-in-front order and remain readable at supported zoom levels.
- [ ] Equal-depth rooftop objects follow scene sibling order consistently when inspected in the GUI.
- [x] Focused visual-layering smoke passes scene ownership, depth ordering, equal-depth determinism, invalid-cell rejection, adjacent-state isolation, and presentation-token substitution checks.
- [x] QA reran headless import/startup, baseline, grid, camera, visual-layering, reskin substitution, exact marker-count, and diff checks for the visual-layering slice.
- [ ] Clicking either occupied rooftop cell selects its topmost world object and shows the geometric selection marker.
- [ ] Clicking a valid empty cell clears world-object selection while the rooftop grid keeps its own selected-cell behavior.
- [ ] Selection targeting and marker readability remain usable after camera pan/zoom; placeholder replacement does not change targeting.
- [x] Builder focused selection smoke passes occupied/empty/invalid selection, deterministic sibling tie-breaking, callable projection, adjacent-state isolation, and restored presentation-token substitution checks.

Automated grid, camera, visual-layering, and world-object-selection acceptance is verified at Builder level. The unchecked items above require an actual GUI playtest and are not claimed by headless QA.
