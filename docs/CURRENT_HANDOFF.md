# Current Handoff

State: READY_FOR_QA

Branch: `chucky-dev`
Planning base commit: `f08fe67`
Objective: Implement a deterministic isometric coordinate utility and a minimal editor-visible rooftop grid with bounded cell selection.
Implementation: `scripts/world/isometric_grid.gd` owns the 64 × 32 tile projection contract. `scenes/world/rooftop_grid.tscn` and `scripts/world/rooftop_grid.gd` own the fixed 5 × 5 editor-visible grid, bounds API, pointer selection, and selected-cell highlight. `scenes/main.tscn` instances that grid.
Validation evidence: Godot 4.6.2 headless import passed; startup printed `PIGEON_EMPIRE_STARTUP_OK`; bootstrap smoke printed `PIGEON_EMPIRE_SMOKE_OK`; focused smoke printed exactly `PHASE01_ISOMETRIC_GRID_SMOKE PASS`; `git diff --check` passed.
Known blockers: None. GUI pointer selection has not yet been manually exercised; its callable selection path and state preservation on invalid coordinates are covered headlessly.

QA should run the commands in `docs/ACTIVE_PHASE.md` and manually confirm that clicking valid diamonds moves the gold highlight while clicking outside the 5 × 5 rooftop leaves selection unchanged.
