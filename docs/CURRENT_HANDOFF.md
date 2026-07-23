# Current Handoff

State: READY_FOR_BUILD

Branch: `chucky-dev`
Planning base commit: `fcbfbb8c18a8af26fcffde85bd78941906b54f14`
Objective: Add an editor-visible, read-only resource HUD panel that renders the verified resource catalog in authoritative order and refreshes displayed balances from the verified runtime ledger through a narrow presentation adapter.

Required validations:
- `/home/ubuntu/.local/bin/godot4 --headless --path . --import`
- `/home/ubuntu/.local/bin/godot4 --headless --path . --quit` with exactly one `PIGEON_EMPIRE_STARTUP_OK`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_visual_layering_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_world_object_selection_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_catalog_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_ledger_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_gathering_action_catalog_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_gathering_action_executor_smoke.gd`
- `/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_hud_smoke.gd` with exactly one `PHASE02_RESOURCE_HUD_SMOKE PASS`
- `git diff --check`

Known blocker status: None. Entry tree was clean at `fcbfbb8`; local `main`, local `chucky-dev`, `origin/main`, and `origin/chucky-dev` all pointed to that verified commit. The existing resource catalog, runtime ledger, gathering catalog, and gathering executor are verified.

Build boundary:
- Build only the reusable editor-visible resource HUD/row presentation adapter and focused smoke described in `docs/ACTIVE_PHASE.md`.
- Do not wire it into `scenes/main.tscn`, add gathering controls, introduce signals/autoloads/persistence, change balances/data, or implement another roadmap objective.
- Keep semantic IDs and ledger balances as the mechanical contract. Keep copy, icon/style slots, fonts, colors, spacing, layout, animation, audio, and placeholder appearance replaceable.

Save/schema impact: None. Runtime-only read presentation; no persisted state, schema version, migration, or autosave.

Reskin boundary: All image files are temporary placeholders. The HUD must retain semantic row identity independent of labels, node names, icon appearance, colors, dimensions, and theme. Missing icons require a readable text/shape fallback, and presentation-metadata substitution must leave ordering and balance refresh mechanics unchanged.
