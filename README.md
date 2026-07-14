# Pigeon Empire

A cozy, slightly absurd pigeon colony-management game built with Godot 4.

In **Pigeon Empire**, the player begins with a handful of scrappy pigeons occupying an abandoned rooftop. Gather resources, construct buildings, assign pigeons to jobs, automate production, and transform a neglected rooftop into the headquarters of a thriving pigeon civilization.

The first major objective is to construct the **Grand Roost**.

## Project Status

**Early development — Phase 0: Foundation**

The repository currently contains:

* A working Godot 4 project
* A minimal main scene
* Headless startup validation
* An automated smoke test
* Project architecture and design documents
* Separate `main` and `chucky-dev` branches
* An autonomous planning, building, and QA workflow

Gameplay systems are being developed incrementally through small, validated milestones.

## Core Gameplay Loop

1. Gather **Crumbs**, **Twigs**, and **Shinies**
2. Construct and upgrade rooftop buildings
3. Increase the pigeon population
4. Assign pigeons to specialized jobs
5. Automate resource production
6. Complete progression objectives
7. Construct the Grand Roost

## Planned Resources

* **Crumbs** — food and basic operating resource
* **Twigs** — primary construction material
* **Shinies** — uncommon advanced resource

## Planned Pigeon Roles

* Forager
* Builder
* Courier or Collector

## Planned Buildings

* Basic Nest
* Crumb Depot
* Twig Workshop
* Shiny Collector
* Grand Roost

## Vertical Slice Goals

The initial playable release is planned to include:

* One compact isometric rooftop map
* Camera movement and zoom
* Resource gathering and counters
* A small pigeon population
* Simple job assignments
* Building placement and validation
* Passive production
* Building upgrades
* Objectives and progression
* Save, load, and autosave
* Placeholder artwork and audio
* Basic onboarding
* A complete Grand Roost progression path
* A playable browser build when supported

## Technology

* **Engine:** Godot 4
* **Language:** GDScript
* **Presentation:** 2D isometric / 2.5D
* **Architecture:** Modular and data-driven
* **Testing:** Godot headless startup and smoke tests
* **Primary development environment:** Ubuntu ARM VPS

The project uses placeholder-first development so gameplay systems can be validated before final artwork is produced.

## Development Workflow

Pigeon Empire is being developed through a controlled autonomous pipeline operated by **Chucky**, a Hermes-based development agent.

The weekday workflow is divided into three roles:

### Creative Director and Architect

Selects one bounded objective, defines acceptance criteria, and prepares the active development plan.

### Builder

Implements only the approved objective and runs focused validation.

### QA and Integration

Reviews the changes, runs broader tests, applies narrow fixes, and promotes validated work to the stable branch.

The workflow follows this sequence:

```text
Director plans one bounded objective
        ↓
Builder implements the objective
        ↓
QA validates and integrates it
        ↓
Verified work reaches main
```

Repository documents are treated as the persistent source of truth rather than relying on chat history.

## Branches

### `main`

Stable and validated project state.

### `chucky-dev`

Active autonomous development branch.

Changes are promoted to `main` only after required validation passes.

## Project Structure

```text
pigeon-empire/
├── .chucky/
├── docs/
│   ├── ACTIVE_PHASE.md
│   ├── ART_BIBLE.md
│   ├── CURRENT_HANDOFF.md
│   ├── DECISIONS.md
│   ├── GAME_BRIEF.md
│   ├── KNOWN_ISSUES.md
│   ├── PLAYTEST_CHECKLIST.md
│   ├── QA_REPORT.md
│   ├── ROADMAP.md
│   └── TECH_ARCHITECTURE.md
├── ops/
│   ├── prompts/
│   └── sync_cron_jobs.py
├── scenes/
├── scripts/
├── tests/
├── project.godot
└── README.md
```

## Roadmap

1. Project foundation
2. Isometric rooftop world
3. Resource systems
4. Building placement
5. Pigeon population and jobs
6. Production and automation
7. Objectives and progression
8. Save and load
9. UX and presentation
10. Vertical-slice release candidate

Detailed milestone definitions are available in [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Running the Project

Clone the repository:

```bash
git clone git@github.com:Ferro-ai26/pigeon-empire.git
cd pigeon-empire
```

Open the project in Godot 4:

```bash
godot4 --editor --path .
```

Run the project:

```bash
godot4 --path .
```

Run the headless startup check:

```bash
godot4 --headless --path . --quit
```

Run the smoke test:

```bash
godot4 --headless --path . --script res://tests/smoke_test.gd
```

Depending on the installation, the executable may be named `godot` instead of `godot4`.

## Scope Boundaries

The initial vertical slice intentionally excludes:

* Combat and enemies
* Multiplayer
* Large technology trees
* Procedural world generation
* Multiple maps or districts
* Complex citizen simulation
* Monetization and advertisements
* Android publishing
* Steam integration
* Final commercial artwork

These systems may be considered later, but they are outside the current development mandate.

## License

No open-source license has been selected yet.

Unless a license is added, all rights are reserved.
