# Pigeon Empire — Autonomous Development Mandate

Status: FINAL
Owner: Kevin
Autonomous operator: Chucky
Engine: Godot 4 / GDScript
Canonical repository: `/home/ubuntu/pigeon-empire`
GitHub target: `git@github.com:Ferro-ai26/pigeon-empire.git`

## Product definition

Pigeon Empire is a compact 2D isometric / 2.5D cozy colony-management game with light idle progression.

The player starts with a few pigeons occupying an abandoned rooftop. Pigeons gather resources, construct buildings, take simple jobs, automate production, and ultimately construct the Grand Roost.

Tone:

- Cozy
- Humorous
- Slightly absurd
- Readable
- Easy to learn
- Built for gradual expansion

Core loop:

1. Gather Crumbs, Twigs, and Shinies.
2. Spend resources on buildings.
3. Increase population and production capacity.
4. Assign pigeons to simple jobs.
5. Upgrade and automate production.
6. Complete objectives.
7. Construct the Grand Roost.

Initial resources:

- Crumbs — food and basic operating resource
- Twigs — construction material
- Shinies — uncommon advanced resource

Initial building set:

- Basic Nest
- Crumb Depot
- Twig Workshop
- Shiny Collector
- Grand Roost

Initial pigeon roles:

- Forager
- Builder
- Courier or Collector

## Vertical-slice destination

The autonomous program ends when the game has:

- One compact isometric rooftop
- Camera pan and zoom
- Resource counters and gathering
- A small pigeon population
- Simple job assignment
- Building placement and validation
- Passive production
- Building upgrades
- Objectives and progression
- Save/load and autosave
- Placeholder sound support
- Placeholder artwork
- Concise onboarding
- A final Grand Roost objective
- A playable browser build when supported
- No critical or progression-blocking issue

After this definition of done is reached, set the workflow state to `VERTICAL_SLICE_COMPLETE` and stop adding features.

## Explicit exclusions

Do not add during this mandate:

- Combat or enemies
- Multiplayer
- Trading networks
- Transportation systems
- Disasters
- Large technology trees
- Procedural world generation
- Multiple districts or maps
- Complex citizen simulation
- Advanced pathfinding
- Dozens of buildings or currencies
- Prestige systems
- Monetization or advertisements
- Android publishing
- Steam integration
- Mod support
- Final commercial artwork
- A web management UI

## Technical direction

- Godot 4
- GDScript
- 2D isometric presentation
- Placeholder assets first
- Data-driven definitions
- Modular, reskinnable systems
- Headless smoke tests
- Browser build only when the installed Godot toolchain supports it
- Never repeatedly attempt incompatible Android or x86-only tooling on the ARM VPS

Use structured data for buildings, resources, upgrades, roles, and objectives. Avoid scattering balance values and display strings through UI scripts.

## Canonical documents

The repository must contain:

```text
docs/
├── GAME_BRIEF.md
├── ART_BIBLE.md
├── TECH_ARCHITECTURE.md
├── ROADMAP.md
├── ACTIVE_PHASE.md
├── CURRENT_HANDOFF.md
├── QA_REPORT.md
├── KNOWN_ISSUES.md
├── DECISIONS.md
└── PLAYTEST_CHECKLIST.md
```

The repository and these documents are project memory. Discord history is not project memory.

## Roadmap

### Phase 0 — Foundation

Repository, Godot shell, documentation, main scene, test harness, headless startup validation, placeholder conventions, and safe web-export detection.

### Phase 1 — Isometric World

Rooftop map, camera controls, coordinate/grid utilities, visual layering, and selectable world objects.

### Phase 2 — Resource Foundation

Resource definitions, counters, gathering actions, resource UI, and data-driven balance.

### Phase 3 — Building System

Placement preview, validation, construction cost, Basic Nest, storage, and building selection.

### Phase 4 — Pigeon Population

Pigeon entities, population limits, simple movement or simulated assignments, jobs UI, Forager, and Builder.

### Phase 5 — Production and Automation

Passive gathering, production buildings, upgrades, assignment efficiency, and only simple safe offline progression.

### Phase 6 — Objectives and Progression

Guided objectives, unlocks, Shinies, Grand Roost requirements, and completion state.

### Phase 7 — Persistence

Save/load, save versioning, autosave, corrupt-save protection, and persistence smoke tests.

### Phase 8 — UX and Presentation

Onboarding, tooltips, feedback, placeholder audio hooks, readability, and basic accessibility.

### Phase 9 — Release Candidate

Complete progression run, regressions, browser build, playtest checklist, critical fixes, and stable tag.

## Daily studio loop

Weekdays, America/Los_Angeles:

- 08:00 — Creative Director and Architect
- 13:00 — Builder
- 19:00 — QA and Integration

The pipeline is:

```text
Director selects one bounded next step
        ↓
Builder implements that exact step
        ↓
QA proves whether it works
        ↓
Validated work reaches main
        ↓
Documents become tomorrow's memory
```

## Workflow state machine

`docs/CURRENT_HANDOFF.md` must contain exactly one current state:

```text
NEEDS_PLAN
READY_FOR_BUILD
READY_FOR_QA
VERIFIED
BLOCKED
VERTICAL_SLICE_COMPLETE
```

Normal transition:

```text
VERIFIED → NEEDS_PLAN → READY_FOR_BUILD → READY_FOR_QA → VERIFIED
```

Rules:

- A role does not work when the state is wrong for that role.
- The director never plans over unvalidated changes.
- The builder does not work from `BLOCKED`.
- QA does not invent missing implementation.
- All feature work stops at `VERTICAL_SLICE_COMPLETE`.

## Git strategy

Branches:

- `main` — stable and validated
- `chucky-dev` — autonomous development

Builder commits coherent work to `chucky-dev`.

QA merges or fast-forwards validated work into `main` only after all required checks pass.

Never:

- erase unexplained changes
- use destructive reset to hide a problem
- commit secrets, caches, `.godot` data, save files, keystores, or export junk
- claim a test or push succeeded without evidence
- merge failed work into `main`

## Model policy

Every Pigeon Empire cron job must explicitly contain:

```text
provider: openai-codex
model: gpt-5.6-sol
reasoning_effort: low
```

Recommended maximum iterations:

- Director: 20
- Builder: 40
- QA: 30

## Token discipline

Director normally reads:

- `CURRENT_HANDOFF.md`
- `ACTIVE_PHASE.md`
- relevant roadmap section
- latest `QA_REPORT.md`
- only directly relevant decisions or architecture

Builder normally reads:

- `ACTIVE_PHASE.md`
- `CURRENT_HANDOFF.md`
- directly relevant source files
- only the applicable architecture section

QA normally reads:

- `ACTIVE_PHASE.md`
- git diff
- tests
- `PLAYTEST_CHECKLIST.md`
- `KNOWN_ISSUES.md`

Do not reread the entire repository or every document each run.

## Failure handling

When blocked, record:

- exact command
- concise error output
- involved files
- attempted correction
- unverified work
- safest next action

Never fabricate successful validation. Never stack new features on broken work. Prefer a narrow repair slice.

## Reporting

Each cron report must use:

```text
Role:
Objective:
Changed:
Tests:
Commit:
State:
Next:
```

Keep Discord reports concise. Detailed evidence belongs in the repository.
