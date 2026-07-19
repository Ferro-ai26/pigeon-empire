# QA Report

## Phase 1 — Isometric World

- Result: **VERIFIED**
- Builder commits reviewed: `c692c81`, `2f99831`
- QA integration fix: moved placeholder colors and line/marker dimensions into editor-visible semantic style properties on `scenes/world/rooftop_grid.tscn`; added a non-color selected-cell marker and an automated style-token substitution check.
- Godot: `4.6.2.stable.official.71f334935` at `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (`PIGEON_EMPIRE_STARTUP_OK`), bootstrap smoke (`PIGEON_EMPIRE_SMOKE_OK`), focused smoke (exactly one `PHASE01_ISOMETRIC_GRID_SMOKE PASS`), and `git diff --check`.
- Reskin check passed: the focused smoke temporarily redirects `tile_fill_color`, verifies selection and bounds behavior are unchanged, then restores the token.
- Persistence/save tests: not applicable; this phase introduces runtime-only selection state and no schema or save files.
- Manual GUI status: not tested in this headless QA run. The visual layout and pointer-click checklist remain unchecked and are recorded as a manual follow-up, not as a merge blocker because all phase acceptance criteria have automated coverage except subjective visual confirmation.

## Phase 1 — Rooftop Camera Controls

- Result: **VERIFIED**
- Builder commit reviewed: `974a73c`
- QA integration fix: none required.
- Godot: `4.6.2.stable.official.71f334935` at `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (exactly one `PIGEON_EMPIRE_STARTUP_OK`), bootstrap smoke (exactly one `PIGEON_EMPIRE_SMOKE_OK`), grid smoke (exactly one `PHASE01_ISOMETRIC_GRID_SMOKE PASS`), camera smoke (exactly one `PHASE01_CAMERA_CONTROLS_SMOKE PASS`), and `git diff --check`.
- Reskin check passed: the camera smoke temporarily redirects the semantic `tile_fill_color` style token while the camera is displaced, proves camera/grid mechanics and selection remain unchanged, and restores the token. Camera code has no presentation-resource dependency.
- Persistence/save tests: not applicable; camera state is runtime-only and the builder diff contains no save or schema changes.
- Manual GUI status: not tested in this headless QA run. Pointer-drag and wheel feel, click selection under the active camera, framing, and subjective visual layout remain unchecked; no GUI or browser/export success is claimed.

## Phase 1 — Rooftop Visual Layering

- Result: **VERIFIED**
- Builder commit reviewed: `85f1d9f`
- QA integration fix: none required.
- Godot: `4.6.2.stable.official.71f334935` at `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (exactly one `PIGEON_EMPIRE_STARTUP_OK`), bootstrap smoke, grid smoke, camera smoke, visual-layering smoke (exactly one `PHASE01_VISUAL_LAYERING_SMOKE PASS`), and `git diff --check`.
- Reskin check passed: the visual-layering smoke temporarily redirects the replaceable placeholder color, proves semantic cells and layers remain unchanged, and restores it. Layering logic has no texture, color, copy, dimensions, animation, audio, or final-theme dependency.
- Persistence/save tests: not applicable; the slice changes runtime scene state only and contains no save or schema changes.
- Manual GUI status: not tested. Placeholder overlap/readability and equal-depth sibling-order appearance remain unchecked; no GUI or browser/export success is claimed.

## Phase 1 — Rooftop World Object Selection

- Result: **VERIFIED**
- Builder commit reviewed: `4f2fd6d`
- QA integration fix: none required.
- Godot: `4.6.2.stable.official.71f334935` at `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (exactly one `PIGEON_EMPIRE_STARTUP_OK`), bootstrap smoke, grid smoke, camera smoke, visual-layering smoke, world-object-selection smoke (exactly one `PHASE01_WORLD_OBJECT_SELECTION_SMOKE PASS`), and `git diff --check`.
- Reskin check passed: the focused smoke temporarily changes the selection marker's replaceable color and width tokens, proves semantic selection identity and behavior remain unchanged, and restores both tokens. Target resolution depends only on semantic cells and reverse sibling order.
- Persistence/save tests: not applicable; selection state is runtime-only and the builder diff contains no save or schema changes.
- Manual GUI status: not tested. Pointer feel after camera pan/zoom and selection-marker readability remain unchecked; no GUI, browser/export, or visual-quality success is claimed.
