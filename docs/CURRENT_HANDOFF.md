# Current Handoff

State: READY_FOR_BUILD

Branch: `chucky-dev`
Planning base commit: `bf885420a6c3e8e6198618ba619f5e144aaa63bf`
Current roadmap phase: Phase 3 — Building System
Objective: Add one presentation-neutral runtime building registry that accepts successful construction results, publishes immutable registry-local building records, owns occupied-cell lookup, and rejects malformed or overlapping registration atomically.

Required implementation boundary:
- Add only the registry, immutable semantic record/result types as needed, and one focused registry smoke.
- Keep construction payment, catalog/placement authority, scenes/UI, storage, persistence, and main-scene integration unchanged.
- Treat registry instance IDs as in-memory runtime identity, not a save-schema contract.
- Preserve the reskin boundary: no presentation resource or placeholder appearance may affect registration, occupancy, identity, order, or lookup.

Required validations:
- Godot headless import and startup; startup must print exactly one `PIGEON_EMPIRE_STARTUP_OK`.
- Baseline smoke, all four Phase 1 smokes, all six Phase 2 smokes, all four existing Phase 3 smokes, and `tests/phase03_building_registry_smoke.gd`.
- New smoke must print exactly one `PHASE03_BUILDING_REGISTRY_SMOKE PASS`.
- Capture combined output; reject nonzero exits, parser/script errors, unexpected `ERROR:` lines, missing markers, or duplicate markers.
- Verify atomic overlap/malformed rejection, no rejected-ID consumption, copied collection isolation, occupied-cell and instance lookup, deterministic order, presentation-metadata substitution, and `git diff --check`.

Save/schema impact: None. The approved slice is runtime-only and registry-local IDs are not persistent identity.

Known blocker status: None. The repository is clean at the planning base and the prior construction-executor slice is independently VERIFIED.

Next: Builder implements exactly the approved registry slice in `docs/ACTIVE_PHASE.md`, validates it, updates durable handoff evidence, and stops before UI, storage, or construction integration.
