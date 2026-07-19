# Active Phase

Phase: Phase 2 — Resource Foundation
Status: Approved slice — ready for build

## Objective

Add a typed, data-driven resource-definition catalog that validates stable semantic resource IDs and exposes presentation metadata without introducing inventory, gathering, or UI behavior.

## Gameplay purpose

Establish one authoritative resource vocabulary for later counters, gathering actions, costs, and UI so those systems can refer to stable IDs instead of duplicating balance or display data.

## Exact scope

- Add a small typed resource-definition model with a stable semantic ID and replaceable display metadata.
- Add one project-owned data file containing the Phase 2 starter resource definitions required by the current game mandate; the Builder must use only resource names already established by repository authority and must not invent a new resource or currency.
- Add a typed catalog/loader that loads the definitions deterministically, rejects malformed entries and duplicate IDs, and provides read-only lookup plus ordered enumeration APIs.
- Keep display name, short description, semantic icon slot, and semantic style slot as presentation metadata; no gameplay logic may branch on those fields.
- Add a focused headless smoke covering successful load, deterministic order, known/unknown lookup, duplicate-ID rejection, malformed-entry rejection, and presentation-metadata substitution.

## Non-goals

- Resource balances, mutable counters, inventory, capacity, gathering actions, rewards, spending, costs, production, buildings, pigeons, jobs, progression, persistence, offline gains, or UI.
- Adding or renaming the mandated resource set, adding currencies, or defining economy balance beyond the resource-definition contract.
- World-object behavior, selection changes, camera/grid changes, scene startup changes, Android/browser/export work, monetization, combat, multiplayer, or unrelated refactors.
- New image, font, or audio files; final art, final copy, animation, or layout styling.

## Likely affected systems/files

- `scripts/resources/resource_definition.gd` (new typed definition)
- `scripts/resources/resource_catalog.gd` (new loader/catalog)
- `data/resources/resource_definitions.json` (new project-owned definitions)
- `tests/phase02_resource_catalog_smoke.gd` (new focused smoke)

The Builder may adjust filenames within the existing `scripts`, `data`, and `tests` boundaries if Godot resource loading requires it, but must not attach this catalog to gameplay or broaden scope.

## Acceptance criteria

1. Headless import and startup succeed, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. A project-owned data file defines each Phase 2 starter resource from the authoritative game mandate exactly once under a stable lowercase semantic ID; no new resource or currency is invented.
3. Every valid entry exposes typed semantic ID, display name, short description, semantic icon slot, and semantic style slot fields.
4. The catalog loads valid definitions successfully and exposes deterministic source order through typed ordered enumeration.
5. Lookup by a known semantic ID returns the exact definition; lookup by an unknown ID returns a documented safe result without mutating catalog state.
6. Duplicate IDs, missing required fields, empty IDs, and invalid field types fail through a deterministic validation result without partially publishing a catalog.
7. Resource identity, validation, lookup, and ordering do not depend on display strings, icon paths, colors, fonts, textures, copy, dimensions, animation, audio, or node names.
8. The focused smoke temporarily substitutes display metadata for one definition, proves semantic identity, lookup, validation, and order are unchanged, and restores the original value.
9. No mutable balance, save file, schema version, autoload, UI scene, world scene, or gameplay state is introduced.
10. The focused smoke prints exactly one `PHASE02_RESOURCE_CATALOG_SMOKE PASS` and exits 0.
11. Headless import/startup, all existing Phase 1 and baseline smokes, the new focused smoke, and `git diff --check` pass.

## Focused validation commands

```bash
/home/ubuntu/.local/bin/godot4 --headless --path . --import
/home/ubuntu/.local/bin/godot4 --headless --path . --quit
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/smoke_test.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_isometric_grid_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_camera_controls_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_visual_layering_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase01_world_object_selection_smoke.gd
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_catalog_smoke.gd
git diff --check
```

## Save/schema impact

None. This slice defines immutable runtime catalog data only. It must not create save files, mutable balances, schema versions, migrations, autoload state, or persistent identifiers beyond the stable definition IDs reserved for future systems.

## Risks and rollback boundary

- Inventing resources outside the mandate would silently change game scope. The Builder must derive entries from repository authority and stop rather than guess if those sources conflict.
- Treating display names or icon paths as identifiers would couple mechanics to a reskin. Only stable semantic IDs may cross into later gameplay contracts.
- Permissive parsing could publish a partial or ambiguous catalog. Validation must complete before definitions become available.
- Godot dictionary/JSON values are Variants; use explicit typed conversion and deterministic validation to avoid warning-as-error failures.
- Rollback boundary: the new resource-definition model, catalog loader, project-owned definition data, and focused smoke. Reverting those files must restore the verified Phase 1 state with no migration or scene changes.

## Reskin boundary and placeholder-asset impact

- Stable resource IDs and catalog validation are gameplay/data contracts. Display name, description, semantic icon slot, and semantic style slot are replaceable presentation metadata.
- The data file may reference semantic slots such as `resource.<id>.icon` and `resource.<id>.style`; it must not require a particular texture filename, pixel size, font, color, or final theme.
- No image file is added. Any existing images remain temporary placeholders and are not part of catalog validation.
- Resource meaning must be readable from semantic ID/text and must never be communicated solely by color or placeholder appearance.
- The substitution smoke proves catalog mechanics remain unchanged when display metadata is replaced; it does not claim subjective visual quality.
