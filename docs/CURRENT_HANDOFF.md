# Current Handoff

State: READY_FOR_BUILD

Branch: `chucky-dev`
Planning base commit: `0ed222a`
Objective: Add a bounded, deterministic rooftop camera controller with pointer-drag panning and stepped zoom while preserving grid coordinates and selection semantics.

Required validations:
- `/home/ubuntu/.local/bin/godot4 --headless --path . --import`
- `/home/ubuntu/.local/bin/godot4 --headless --path . --quit` and confirm `PIGEON_EMPIRE_STARTUP_OK`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd` and confirm `PIGEON_EMPIRE_SMOKE_OK`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd` and confirm exactly one `PHASE01_ISOMETRIC_GRID_SMOKE PASS`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd` and confirm exactly one `PHASE01_CAMERA_CONTROLS_SMOKE PASS`
- `git diff --check`

Known blocker status: None. The verified grid baseline was re-run successfully under Godot 4.6.2 before this plan. Manual GUI pointer selection remains an unchecked follow-up; the camera slice must preserve the callable selection contract and explicitly test style-token substitution without claiming subjective visual approval.

Builder boundary: implement only the camera-control slice approved in `docs/ACTIVE_PHASE.md`. Do not add touch gestures, gameplay systems, persistence, final assets, or unrelated refactors.
