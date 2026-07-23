# Current Handoff

State: READY_FOR_QA

Branch: `chucky-dev`
Planning base commit: `fcbfbb8c18a8af26fcffde85bd78941906b54f14`
Objective completed: Added an editor-visible, read-only resource HUD that renders supplied catalog definitions in authoritative order and explicitly refreshes balances from a supplied runtime ledger.

Built ownership:
- `scenes/ui/resource_hud.tscn` centralizes the HUD panel theme, margins, spacing, and reusable row scene reference.
- `scenes/ui/resource_row.tscn` owns the readable text/number row and neutral text/shape icon fallback.
- `scripts/ui/resource_hud.gd` validates injected catalog/ledger dependencies, builds semantic rows, and performs read-only explicit refreshes.
- `scripts/ui/resource_row.gd` binds replaceable display metadata while retaining semantic resource identity independently.
- `tests/phase02_resource_hud_smoke.gd` verifies ordering, balances, rejection safety, catalog immutability, and full presentation-metadata substitution.

Builder validation passed:
- Godot 4.6.2 headless import.
- Headless startup with exactly one `PIGEON_EMPIRE_STARTUP_OK`.
- Baseline smoke.
- All four Phase 1 smokes.
- All four pre-existing Phase 2 smokes.
- Focused resource HUD smoke with exactly one `PHASE02_RESOURCE_HUD_SMOKE PASS`.
- `git diff --check`.

QA boundary:
- Re-run every command in `docs/ACTIVE_PHASE.md` against the builder commit.
- Confirm parser/error output remains clean and exact success-marker counts are one.
- Verify rejected null/mismatched dependencies preserve both the ledger snapshot and the last valid HUD rows.
- Verify substituted display names/icon slots/style slots change presentation metadata while semantic IDs, order, and numeric balances remain stable.
- Do not claim subjective readability, spacing, mobile hierarchy, or GUI behavior from headless tests.

Known blocker status: None.

Build boundary retained:
- The HUD is not wired into `scenes/main.tscn` and introduces no input, signals, gathering execution, persistence, economy changes, or final art.
- Semantic IDs and ledger balances remain the mechanical contract. Copy, icon/style slots, fonts, colors, spacing, layout, animation, audio, and placeholder appearance remain replaceable presentation concerns.

Save/schema impact: None. Runtime-only read presentation; no persisted state, schema version, migration, or autosave.
