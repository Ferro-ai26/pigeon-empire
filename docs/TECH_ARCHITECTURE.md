# Technical Architecture

## Baseline

- Godot 4 and typed GDScript where practical.
- 2D isometric presentation using small focused scenes and scripts.
- Structured definitions for resources, buildings, upgrades, roles, and objectives.
- Avoid balance values and display strings scattered through UI scripts.
- Deterministic headless smoke tests are required for testable logic and startup.

## System boundaries

World/grid, resources, buildings, pigeons/jobs, production, objectives, persistence, and UI should remain modular and communicate through narrow APIs or signals. Save data must be versioned when persistence begins.

## Platform policy

Browser export is attempted only when the installed toolchain supports it. Do not repeatedly attempt Android or incompatible x86-only tooling on this ARM VPS.
