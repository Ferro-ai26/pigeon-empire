# Active Phase

Phase: Phase 2 — Resource Foundation
Status: Approved slice — ready for build

## Objective

Add a typed runtime resource counter ledger initialized from the verified resource catalog, with guarded integer credit/debit APIs and no gathering, UI, or persistence behavior.

## Gameplay purpose

Give later gathering actions, costs, and resource UI one authoritative runtime balance API so they cannot create ad hoc counters or identify resources through display metadata.

## Exact scope

- Add one typed runtime ledger initialized from a valid `ResourceCatalog`.
- Initialize exactly one zero-valued integer counter for each catalog semantic ID in deterministic catalog order.
- Expose narrow typed APIs to query a known balance, credit a positive integer amount, test affordability, and debit a positive integer amount only when sufficient balance exists.
- Reject unknown semantic IDs, zero or negative mutation amounts, and insufficient debits without changing any balance.
- Return copied balance snapshots/ID collections so callers cannot mutate internal ledger state.
- Add a focused headless smoke covering initialization, independent counters, successful credit/debit, affordability, all rejection paths, non-mutation on failure, deterministic enumeration, copied snapshots, and presentation-metadata substitution.

## Non-goals

- Gathering actions, tap/click input, timed or passive production, rewards, costs owned by buildings, inventory capacity, storage, pigeons, jobs, objectives, upgrades, or economy balancing.
- UI scenes, labels, icons, animations, audio, feedback copy, world-object changes, camera/grid changes, or startup integration.
- Autoloads, save files, schema versions, migrations, autosave, offline gains, or persistence.
- Floating-point resources, negative balances, resource conversion, transactions spanning multiple resources, event buses/signals, or dependency injection frameworks.
- New or renamed resources/currencies, new images/fonts/audio, final art, Android/browser/export work, monetization, combat, multiplayer, or unrelated refactors.

## Likely affected systems/files

- `scripts/resources/resource_ledger.gd` (new typed runtime counter owner)
- `tests/phase02_resource_ledger_smoke.gd` (new focused smoke)

The Builder may make a narrowly required compatibility correction to the verified catalog API, but must not change authoritative resource membership, presentation metadata, scenes, project autoloads, or gameplay integration.

## Acceptance criteria

1. Headless import and startup succeed, with startup printing exactly one `PIGEON_EMPIRE_STARTUP_OK`.
2. A ledger created from the authoritative valid catalog contains exactly `crumbs`, `twigs`, and `shinies`, in catalog order, each initialized to integer zero.
3. Counter identity depends only on stable semantic resource IDs from `ResourceCatalog`; no display string, icon/style slot, texture, color, font, copy, dimensions, animation, audio, or node name is used as a key.
4. Querying a known ID returns its integer balance through a typed API; querying an unknown ID returns a documented deterministic failure result and does not create a counter.
5. Crediting a positive integer increases only the addressed known counter by exactly that amount.
6. Affordability reports true only for a valid positive amount not exceeding the addressed balance.
7. Debiting a valid affordable positive amount succeeds and decreases only the addressed counter; insufficient debits fail without mutation and balances never become negative.
8. Unknown IDs and zero/negative mutation amounts are rejected deterministically without changing ledger state.
9. Ordered ID enumeration and balance snapshots return copied collections; mutating a returned collection cannot alter ledger membership, order, or balances.
10. Replacing all display metadata in an equivalent catalog leaves ledger membership, initial balances, credit/debit behavior, and order unchanged.
11. No scene, autoload, save/schema, UI, gathering, production, world, or persistent state is introduced or changed.
12. The focused smoke prints exactly one `PHASE02_RESOURCE_LEDGER_SMOKE PASS` and exits 0.
13. Headless import/startup, baseline smoke, all four Phase 1 smokes, the catalog smoke, the new ledger smoke, and `git diff --check` pass.

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
/home/ubuntu/.local/bin/godot4 --headless --path . -s res://tests/phase02_resource_ledger_smoke.gd
git diff --check
```

## Save/schema impact

None. The ledger is runtime-only, starts from zero, is not an autoload, and must not read or write persistent data. Stable semantic IDs remain compatible with a future versioned save system, but no save contract or migration is introduced in this slice.

## Risks and rollback boundary

- Letting callers mutate an exposed dictionary would bypass validation and permit unknown or negative counters; expose typed operations and copied views only.
- Treating display metadata as identity would couple balances to a reskin; initialize exclusively from catalog semantic IDs.
- Combining counters with gathering or UI would blur system boundaries and overgrow this slice; those remain later Phase 2 objectives.
- Ambiguous failure behavior could make later costs unsafe; each rejected operation must return a documented deterministic result and preserve all balances.
- Godot dictionary values are Variants; use explicit integer types/conversions to avoid warning-as-error failures.
- Rollback boundary: the new ledger script and its focused smoke. Reverting those files must restore the verified catalog-only Phase 2 state without migration or scene changes.

## Reskin boundary and placeholder-asset impact

- The ledger and semantic IDs are gameplay/state contracts. Display names, descriptions, icon slots, style slots, colors, fonts, textures, copy, layout, animation, and audio remain presentation concerns outside the ledger.
- No image or other presentation asset is added or read. Existing image files remain temporary placeholders.
- Resource meaning and balance behavior must not rely solely on color or placeholder appearance.
- The focused smoke must build an equivalent catalog with substituted display metadata and prove ledger membership/order and mutation behavior are unchanged; this is a mechanics/presentation-decoupling check, not subjective visual approval.
