# Current Handoff

State: READY_FOR_BUILD

Branch: `chucky-dev`
Planning base commit: `3019d9d4d200ba28e5f1a17d06c56451d82fb477`
Current roadmap phase: Phase 3 — Building System
Objective: Add an immutable JSON-backed catalog for the single `basic_nest` definition, with semantic footprint, construction costs, storage contributions, and replaceable presentation slots; do not implement placement, construction, spending, runtime storage, or UI.

Verified entry state:
- Repository was clean at run entry.
- `main`, `chucky-dev`, `origin/main`, and `origin/chucky-dev` all pointed to `3019d9d` before this planning commit.
- Phase 2 Playable Gathering Loop is recorded VERIFIED in `docs/QA_REPORT.md` and its documented scene, scripts, data, and focused smoke exist in the repository.
- Phase 3 roadmap scope is placement preview/validation, construction costs, Basic Nest, storage, and building selection. This slice establishes only the immutable Basic Nest definition boundary required by those later runtime slices.

Required implementation:
- Follow the exact scope, non-goals, acceptance criteria, rollback boundary, and reskin boundary in `docs/ACTIVE_PHASE.md`.
- Add only the authoritative building JSON, typed immutable definition/catalog scripts, and one focused building-catalog smoke, except for a strictly necessary narrow read-only resource-catalog compatibility helper.
- Preserve all verified Phase 1 and Phase 2 behavior and authority boundaries.

Required validations:
- Run every command listed in `docs/ACTIVE_PHASE.md`.
- Require clean exits, exact expected markers, no `SCRIPT ERROR`, no `Parse Error`, no unexpected `ERROR:` output, and a passing `git diff --check`.
- The focused smoke must prove complete-candidate atomic publication, immutable copied collections, strict numeric/resource-reference validation, exact authoritative Basic Nest mechanics, and full presentation-metadata substitution without mechanical change.

Save/schema impact: None. Immutable definition data only; no persistence or runtime building/storage state.

Known blocker status: None. Manual GUI QA is not applicable to this data-only slice, and no visual-quality claim should be made.
