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
- [x] QA reran headless import/startup, baseline, all prior Phase 1 smokes, focused world-object selection, exact marker-count, reskin substitution, and diff checks for the selection slice.

Automated grid, camera, visual-layering, and world-object-selection acceptance is QA-verified. The unchecked items above require an actual GUI playtest and are not claimed by headless QA.

## Phase 2 — Resource foundation

- [x] Builder focused resource-catalog smoke passes authoritative loading, deterministic source order, known/unknown lookup, copied enumeration, malformed and duplicate rejection without partial publication, and restored presentation-metadata substitution.
- [x] QA reran headless import/startup, baseline, all Phase 1 smokes, the focused resource-catalog smoke, exact marker-count checks, metadata substitution/restoration, and `git diff --check`.
- [x] Builder focused resource-ledger smoke passes zero initialization in catalog order, independent counters, guarded credit/debit, affordability, all rejection paths without mutation, copied views, and presentation-metadata substitution.
- [x] QA reran headless import/startup, baseline, all Phase 1 smokes, resource-catalog and resource-ledger smokes, exact marker-count checks, metadata substitution, and `git diff --check` for the resource-ledger slice.
- [x] Builder focused gathering-action catalog smoke passes authoritative membership/order, typed lookup and rewards, resource-ID validation, every required malformed-data rejection with atomic state retention, copied collections, unknown lookup, and full presentation-metadata substitution.
- [x] QA reran headless import/startup, baseline, all Phase 1 smokes, all three Phase 2 smokes, exact marker-count checks, metadata substitution, and `git diff --check` for the gathering-action catalog slice.
- [x] Builder focused gathering-action executor smoke passes all starter actions, exact isolated credits, repeated accumulation, invalid and missing-dependency rejection without mutation, catalog immutability, semantic results, and full presentation-metadata substitution.
- [x] QA reran headless import/startup, baseline, all four Phase 1 smokes, all four Phase 2 smokes, exact marker-count checks, presentation-metadata substitution, parser/error-log checks, and `git diff --check` for the gathering-action executor slice.
- [x] Builder focused resource-HUD smoke passes editor-visible scene instantiation, authoritative row order, explicit read-only balance refresh, invalid-dependency rejection without ledger or valid-row mutation, and full presentation-metadata substitution.
- [ ] In the Godot GUI, the temporary HUD fallback marker, display names, and integer balances remain readable without overlap at the intended mobile viewport.
- [x] QA reran headless import/startup, baseline, all Phase 1 smokes, all five Phase 2 smokes, exact marker-count checks, metadata substitution, parser/error-log checks, and `git diff --check` for the resource-HUD slice.
- [x] Builder focused playable gathering-loop smoke passes preserved main-scene world composition, catalog-ordered semantic controls, all three actions, exact isolated and repeated credits, explicit read-only HUD refresh, invalid request/setup safety, and complete resource/action presentation-metadata substitution.
- [x] QA reran headless import/startup, baseline, all four Phase 1 smokes, all six Phase 2 smokes, exact marker-count checks, complete presentation-metadata substitution, parser/error-log scanning, and `git diff --check` for the playable gathering-loop slice.
- [ ] In the Godot GUI, each gathering control has a comfortable mobile tap target, readable text, and no overlap with the resource HUD or rooftop/camera view.
- [ ] Clicking each gathering control once visibly increments only its matching resource counter; repeated clicks feel responsive and never double-credit.

The resource HUD and starter gathering panel now form a playable resource loop, but subjective readability, spacing, tap feel, hierarchy, and camera/UI coexistence remain manual GUI QA items; headless validation does not claim them.

## Phase 3 — Building system

- [x] Builder focused building-catalog smoke passes exact `basic_nest` authority/order and mechanics, resource-reference and strict numeric validation, malformed-data rejection, atomic failed reloads, typed lookup, copied collections, and complete presentation-metadata substitution.
- [x] QA reran headless import/startup, baseline, all Phase 1 and Phase 2 smokes, the Phase 3 focused smoke, exact marker-count checks, parser/error scanning, reskin substitution, and `git diff --check`.
- [x] Builder focused placement-validator smoke passes the authoritative Basic Nest 2x2 row-major footprint, all rooftop boundaries, overlap and duplicate occupancy handling, malformed input rejection, copied results, unchanged dependencies, and full presentation-metadata substitution.
- [x] QA independently reran headless import/startup, baseline, all Phase 1 and Phase 2 smokes, both Phase 3 smokes, exact marker-count checks, parser/error scanning, reskin substitution, and `git diff --check` for the placement-validator slice.
- [x] Builder focused construction-cost transaction smoke passes exact authoritative Basic Nest debit, affordable repeats, all-or-nothing insufficient balances in either caller order, malformed/unknown rejection, copied ledger views, caller-data immutability, unrelated-resource isolation, and complete presentation-metadata substitution.
- [x] QA independently reran headless import/startup, baseline, all Phase 1 and Phase 2 smokes, all three Phase 3 smokes, exact marker-count checks, parser/error scanning, reskin substitution, and `git diff --check` for the construction-cost transaction slice.
- [x] Builder focused construction-executor smoke passes authoritative Basic Nest resolution, exact 2x2 cells and debit, placement-before-payment, insufficient-balance atomicity, invalid/missing dependency rejection, repeated affordability, caller/result collection isolation, and complete presentation-metadata substitution.
- [x] QA independently reran headless import/startup, baseline, all Phase 1 and Phase 2 smokes, all four Phase 3 smokes, exact marker-count checks, parser/error scanning, reskin substitution, and `git diff --check` for the construction-executor slice.
- [x] Builder focused building-registry smoke passes authoritative Basic Nest registration, registry-local IDs, deterministic record/cell lookup and order, atomic overlap/malformed rejection, rejected-ID preservation, copied collection isolation, and complete presentation-metadata substitution.

The current additions provide semantic placement validation, atomic cost debit, a presentation-neutral construction decision, and authoritative in-memory building occupancy. The registry does not create scenes, apply storage, combine payment with registration, or introduce GUI, persistence, or export behavior.
