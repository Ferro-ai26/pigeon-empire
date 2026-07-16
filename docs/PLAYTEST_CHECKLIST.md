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
- [x] Focused Phase 1 smoke passes projection round trips, bounds, scene-node, selection-state, and style-token substitution checks.
