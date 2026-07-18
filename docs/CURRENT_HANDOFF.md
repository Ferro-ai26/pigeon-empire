# Current Handoff

State: READY_FOR_QA

Branch: `chucky-dev`
Planning base commit: `80a15a6`
Builder base commit: `b523e70`
Objective: Add runtime-only rooftop world-object selection through semantic grid cells, with deterministic sibling-order tie-breaking and replaceable non-color-only selection feedback.

Required validations:
- `/home/ubuntu/.local/bin/godot4 --headless --path . --import`
- `/home/ubuntu/.local/bin/godot4 --headless --path . --quit` with exactly one `PIGEON_EMPIRE_STARTUP_OK`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_visual_layering_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_world_object_selection_smoke.gd` with exactly one `PHASE01_WORLD_OBJECT_SELECTION_SMOKE PASS`
- `git diff --check`

Known blocker status: None. Manual GUI pointer feel and selection-marker readability remain unverified and must not be claimed by headless QA.

Builder implementation: `WorldObjects` now uses `RooftopWorldSelection` for semantic-cell resolution, reverse-sibling tie-breaking, pointer projection delegation, empty-cell clearing, and invalid-cell rejection. `RooftopWorldObject` owns runtime selected state and drives the editor-visible `SelectionFeedback` geometry through replaceable style tokens. The focused smoke covers both occupied placeholders, empty/invalid behavior, tie-breaking, callable projection, adjacent-state isolation, and restored presentation-token substitution.

Builder boundary: Implement only the approved world-object-selection slice in `docs/ACTIVE_PHASE.md`. Do not add details UI, placement, buildings, resources, pigeons, persistence, or begin Phase 2. Preserve semantic-cell targeting and the reskin boundary; placeholder art dimensions must never define interaction.
