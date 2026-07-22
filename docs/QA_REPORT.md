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

## Phase 2 — Resource Foundation

- Result: **VERIFIED**
- Builder commit reviewed: `d79fc1f`
- QA integration fix: none required.
- Godot: `4.6.2.stable.official.71f334935` at `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (exactly one `PIGEON_EMPIRE_STARTUP_OK`), bootstrap smoke, all four Phase 1 smokes, resource-catalog smoke (exactly one `PHASE02_RESOURCE_CATALOG_SMOKE PASS`), and `git diff --check`.
- Reskin check passed: the focused smoke substitutes all display metadata for `crumbs`, proves semantic identity, lookup, validation, and source order remain unchanged, restores the original metadata, and reloads successfully. The catalog uses semantic icon/style slots and contains no texture, font, color, dimension, animation, audio, node-name, or final-theme dependency.
- Atomicity/read-only checks passed: malformed and duplicate candidate sets preserve the previously published catalog; unknown lookup is non-mutating; ordered enumeration returns copied storage.
- Persistence/save tests: not applicable; the slice adds immutable definition data only and no save, schema, autoload, balance, or gameplay state.
- Manual GUI status: not applicable to this data-only slice; no GUI, browser/export, or visual-quality success is claimed.

## Phase 2 — Runtime Resource Ledger

- Result: **VERIFIED**
- Builder commit reviewed: `178f874`
- QA integration fix: none required.
- Godot: `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (exactly one `PIGEON_EMPIRE_STARTUP_OK`), baseline smoke, all four Phase 1 smokes, resource-catalog smoke, resource-ledger smoke (exactly one `PHASE02_RESOURCE_LEDGER_SMOKE PASS`), and `git diff --check`.
- Ledger checks passed: authoritative catalog-order zero initialization, independent integer counters, guarded credit/debit and affordability, deterministic unknown/invalid rejection without mutation, non-negative balances, and copied ID/snapshot collections.
- Reskin check passed: the focused smoke substitutes every display metadata field in an equivalent catalog and proves membership, order, initial balances, and credit/debit behavior remain unchanged. The ledger depends only on semantic IDs and reads no presentation asset.
- Persistence/save tests: not applicable; the ledger is runtime-only and the builder diff contains no save, schema, autoload, scene, or startup integration change.
- Manual GUI status: not applicable to this runtime-only slice; no GUI, browser/export, or visual-quality success is claimed.

## Phase 2 — Gathering Action Catalog

- Result: **VERIFIED**
- Builder commit reviewed: `0f9aaca`
- QA integration fix: none required.
- Godot: `4.6.2.stable.official.71f334935` at `/home/ubuntu/.local/bin/godot4`
- Validation passed: headless import, headless startup (exactly one `PIGEON_EMPIRE_STARTUP_OK`), baseline smoke, all four Phase 1 smokes, all three Phase 2 smokes, gathering-action catalog smoke (exactly one `PHASE02_GATHERING_ACTION_CATALOG_SMOKE PASS`), and `git diff --check`.
- Catalog checks passed: exact authoritative membership/order, typed known and non-mutating unknown lookup, positive integer JSON rewards, authoritative resource-ID validation, deterministic rejection coverage, atomic failed reloads, and copied ordered collections.
- Reskin check passed: the focused smoke substitutes every display metadata field and proves identity, order, targets, rewards, lookup, and validation remain unchanged. Mechanics depend only on stable action ID, semantic resource ID, and reward amount; no presentation asset is loaded.
- Persistence/save tests: not applicable; this immutable data-only slice contains no save, schema, autoload, scene, ledger-balance, or startup integration change.
- Manual GUI status: not applicable to this data-only slice; no GUI, browser/export, or visual-quality success is claimed.
