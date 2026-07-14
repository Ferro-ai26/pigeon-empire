You are Codex working directly on Kevin's Chucky VPS. Perform the one-time Pigeon Empire bootstrap and cron installation.

This is an execution task, not a design discussion. Use the finalized packet contents as authoritative. Do not modify Scraplord, Moon Cheese Inc., Market Game, Monster Motel, or unrelated Hermes jobs.

Canonical project:
- `/home/ubuntu/pigeon-empire`

GitHub target:
- `git@github.com:Ferro-ai26/pigeon-empire.git`

Cron prompt source files to install:
- `/home/ubuntu/pigeon-empire/ops/prompts/director.md`
- `/home/ubuntu/pigeon-empire/ops/prompts/builder.md`
- `/home/ubuntu/pigeon-empire/ops/prompts/qa.md`

Required cron model:
- provider: `openai-codex`
- model: `gpt-5.6-sol`
- reasoning effort: `low`

Required schedules, interpreted in the same Pacific-local scheduler convention as the existing Chucky jobs:
- Director: `0 8 * * 1-5`
- Builder: `0 13 * * 1-5`
- QA: `0 19 * * 1-5`
- Keep job `timezone` consistent with the working existing jobs. Do not introduce a double shift.

Required job names:
- `pigeon-empire-director-weekdays`
- `pigeon-empire-builder-weekdays`
- `pigeon-empire-qa-weekdays`

Required maximum iterations:
- Director: 20
- Builder: 40
- QA: 30

Required skills:
- `chucky-safe-character`
- `godot-project-lifecycle`

Required toolsets:
- terminal
- file
- skills

Execution sequence:

1. Preflight
   - Inspect `/home/ubuntu/.hermes/cron/jobs.json`, Hermes cron status, scheduler timezone behavior, Godot availability, Git, GitHub CLI authentication, and whether the target repo/path already exists.
   - Back up `jobs.json` before any change.
   - Preserve all unrelated job records and unrelated dirty files.
   - Confirm cron execution is already enforced to `openai-codex / gpt-5.6-sol / low`. Do not change the normal Discord model.
   - Do not modify Hermes scheduler source unless the existing enforcement is broken and a focused test proves a repair is necessary.

2. Repository bootstrap
   - Create `/home/ubuntu/pigeon-empire` only if absent.
   - If it already exists, inspect it and preserve all work.
   - Initialize Git with branches `main` and `chucky-dev`.
   - Create a minimal Godot 4 project that can start headlessly:
     - `project.godot`
     - a minimal main scene
     - a minimal startup script
     - a small smoke-test script
     - `.gitignore`
     - `.chucky/`
     - `ops/prompts/`
   - Create all canonical documents:
     - docs/GAME_BRIEF.md
     - docs/ART_BIBLE.md
     - docs/TECH_ARCHITECTURE.md
     - docs/ROADMAP.md
     - docs/ACTIVE_PHASE.md
     - docs/CURRENT_HANDOFF.md
     - docs/QA_REPORT.md
     - docs/KNOWN_ISSUES.md
     - docs/DECISIONS.md
     - docs/PLAYTEST_CHECKLIST.md
   - Copy the finalized mandate into the project documents without expanding its scope.
   - Set initial workflow state to `NEEDS_PLAN`.
   - ACTIVE_PHASE should say the next Director run must select the first bounded Phase 0/1 objective; it must not pre-authorize a large implementation.

3. Prompt installation
   - Store the exact three reviewed role prompts in `ops/prompts/`.
   - Add a small sync/verification utility under `ops/` that:
     - reads the prompt files
     - updates or creates only the three named jobs
     - is idempotent
     - writes a timestamped `jobs.json` backup
     - validates JSON before replacement
     - explicitly pins provider/model on every job
     - sets workdir to `/home/ubuntu/pigeon-empire`
     - sets the required skills, toolsets, schedules, delivery, and iteration ceilings
     - preserves unrelated jobs byte-for-byte at the object level
   - Prefer the supported Hermes cron CLI for fields it exposes.
   - Because current Hermes CLI does not expose every per-job model field, a minimal validated jobs.json update is acceptable for the missing fields.
   - Use the existing Discord home/origin delivery convention. Do not invent a new channel.

4. Cron safety
   - Create or update the three jobs in a paused/disabled state first.
   - Validate:
     - prompt files exactly match embedded job prompts
     - all three jobs are pinned to `openai-codex / gpt-5.6-sol`
     - schedules are correct
     - workdir is correct
     - iteration ceilings are correct
     - unrelated jobs are unchanged
     - `hermes cron list` and `hermes cron status` remain healthy
   - Only after repository and cron validation succeed, enable the three jobs.
   - Do not manually run Builder or QA.
   - Do not force the Director if doing so would overlap another active cron run. The next scheduled Director run is sufficient.

5. Git and remote
   - Commit the clean bootstrap to `main`.
   - Create/reset `chucky-dev` only by normal non-destructive branch operations from validated main.
   - If `Ferro-ai26/pigeon-empire` already exists, connect and push.
   - If it does not exist and authenticated `gh` can create it without prompting, create it as a public repository and push both branches.
   - If GitHub creation is unavailable, keep the local repo healthy and report the exact remote blocker. Do not fail the cron setup solely for that reason.
   - Never expose credentials.

6. Validation
   - Run Godot headless import/startup and smoke validation if Godot is installed.
   - If Godot is unavailable, validate project structure and scripts as far as possible, then report `NEEDS KEVIN TEST`; do not fabricate success.
   - Validate JSON, prompt identity, Git cleanliness, branch state, cron health, and effective model fields.
   - Do not restart the gateway merely because jobs.json changed. Restart only if an actual scheduler/config code change requires it.

7. Final report
   Provide:
   - Status: DONE, BLOCKED, or NEEDS KEVIN TEST
   - Repo path
   - GitHub/remote state
   - Bootstrap commit
   - Branches
   - Godot validation
   - Three job IDs, names, schedules, enabled states
   - Effective provider/model/reasoning
   - Prompt identity validation
   - Unrelated jobs preserved
   - Next scheduled Director run
   - Exact remaining blocker, if any

Keep the report concise. Do not begin building gameplay beyond the minimal validated bootstrap.
