# Pigeon Empire Chucky Bootstrap Packet

This packet is ready to hand to Codex on the Chucky VPS.

## What it creates

- A new isolated Godot repository at `/home/ubuntu/pigeon-empire`
- The canonical design and workflow documents
- Minimal Phase 0 project/bootstrap files
- Three separate weekday Hermes jobs:
  - 08:00 Pacific — Director
  - 13:00 Pacific — Builder
  - 19:00 Pacific — QA
- Explicit `openai-codex / gpt-5.6-sol / low` job pinning
- An idempotent cron-prompt sync/verification utility
- Safe paused-first installation followed by validation and activation

## Recommended use

1. Copy this packet to the Chucky VPS.
2. Open Codex CLI from `/home/ubuntu/.hermes`.
3. Paste the contents of `02_PASTE_TO_CODEX_BOOTSTRAP.md`.
4. Let Codex inspect the live Hermes schema and perform the bootstrap.
5. Review its final report before manually forcing any cron run.

Do not paste the three role prompts into one cron job. They are intentionally separate jobs with separate responsibilities.

## Important

The bootstrap instruction forbids changes to existing Scraplord, Moon Cheese, Monster Motel, and Market Game projects or jobs.

The new jobs are created disabled first. They are enabled only after repository, prompt, schedule, model, and cron-health validation pass.
