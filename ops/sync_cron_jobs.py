#!/usr/bin/env python3
"""Idempotently install or verify the three Pigeon Empire Hermes cron jobs."""

from __future__ import annotations

import argparse
import copy
import hashlib
import json
import os
import shutil
import tempfile
from datetime import datetime, timedelta
from pathlib import Path
from zoneinfo import ZoneInfo

REPO = Path("/home/ubuntu/pigeon-empire")
JOBS_PATH = Path.home() / ".hermes" / "cron" / "jobs.json"
PACIFIC = ZoneInfo("America/Los_Angeles")
SKILLS = ["chucky-safe-character", "godot-project-lifecycle"]
TOOLSETS = ["terminal", "file", "skills"]
SPECS = (
    ("pigeon-empire-director-weekdays", "director.md", "0 8 * * 1-5", 8, 20),
    ("pigeon-empire-builder-weekdays", "builder.md", "0 13 * * 1-5", 13, 40),
    ("pigeon-empire-qa-weekdays", "qa.md", "0 19 * * 1-5", 19, 30),
)


def now() -> datetime:
    return datetime.now(PACIFIC)


def next_weekday(hour: int, after: datetime | None = None) -> str:
    cursor = (after or now()).astimezone(PACIFIC)
    candidate = cursor.replace(hour=hour, minute=0, second=0, microsecond=0)
    if candidate <= cursor:
        candidate += timedelta(days=1)
    while candidate.weekday() >= 5:
        candidate += timedelta(days=1)
    return candidate.isoformat()


def stable_id(name: str) -> str:
    return hashlib.sha256(name.encode("utf-8")).hexdigest()[:12]


def delivery_origin(jobs: list[dict]) -> dict | None:
    candidates = [
        job for job in jobs
        if job.get("deliver") == "origin" and isinstance(job.get("origin"), dict)
    ]
    successful = [job for job in candidates if job.get("last_status") == "ok"]
    selected = (successful or candidates)[-1] if (successful or candidates) else None
    return copy.deepcopy(selected.get("origin")) if selected else None


def desired_job(name: str, prompt_file: str, expr: str, hour: int,
                max_iterations: int, enabled: bool, origin: dict | None,
                existing: dict | None) -> dict:
    timestamp = now().isoformat()
    job = copy.deepcopy(existing) if existing else {
        "id": stable_id(name),
        "created_at": timestamp,
        "repeat": {"times": None, "completed": 0},
        "last_run_at": None,
        "last_status": None,
        "last_error": None,
        "last_delivery_error": None,
    }
    job.update({
        "name": name,
        "prompt": (REPO / "ops" / "prompts" / prompt_file).read_text(),
        "skills": list(SKILLS),
        "skill": SKILLS[0],
        "model": "gpt-5.6-sol",
        "provider": "openai-codex",
        "reasoning_effort": "low",
        "base_url": None,
        "script": None,
        "no_agent": False,
        "context_from": None,
        "schedule": {"kind": "cron", "expr": expr, "display": expr},
        "schedule_display": expr,
        "timezone": None,
        "deliver": "origin",
        "origin": copy.deepcopy(origin),
        "enabled_toolsets": list(TOOLSETS),
        "workdir": str(REPO),
        "max_iterations": max_iterations,
        "enabled": enabled,
        "state": "scheduled" if enabled else "paused",
        "paused_at": None if enabled else (job.get("paused_at") or timestamp),
        "paused_reason": None,
        "next_run_at": next_weekday(hour),
    })
    return job


def validate(data: dict, enabled: bool | None = None) -> None:
    assert isinstance(data.get("jobs"), list), "jobs.json lacks a jobs list"
    by_name = {job.get("name"): job for job in data["jobs"]}
    for name, prompt_file, expr, _hour, ceiling in SPECS:
        job = by_name.get(name)
        assert job is not None, f"missing job: {name}"
        assert job["prompt"] == (REPO / "ops" / "prompts" / prompt_file).read_text()
        assert job.get("provider") == "openai-codex"
        assert job.get("model") == "gpt-5.6-sol"
        assert job.get("reasoning_effort") == "low"
        assert job.get("schedule", {}).get("expr") == expr
        assert job.get("timezone") is None
        assert job.get("workdir") == str(REPO)
        assert job.get("max_iterations") == ceiling
        assert job.get("skills") == SKILLS
        assert job.get("enabled_toolsets") == TOOLSETS
        assert job.get("deliver") == "origin"
        if enabled is not None:
            assert job.get("enabled") is enabled


def atomic_write(data: dict) -> Path:
    JOBS_PATH.parent.mkdir(parents=True, exist_ok=True)
    stamp = now().strftime("%Y%m%dT%H%M%S.%f%z")
    backup = JOBS_PATH.with_name(f"jobs.json.pigeon-empire.{stamp}.bak")
    shutil.copy2(JOBS_PATH, backup)
    encoded = json.dumps(data, indent=2, ensure_ascii=False) + "\n"
    json.loads(encoded)
    fd, temp_name = tempfile.mkstemp(prefix="jobs.json.", dir=JOBS_PATH.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as handle:
            handle.write(encoded)
            handle.flush()
            os.fsync(handle.fileno())
        os.replace(temp_name, JOBS_PATH)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)
    return backup


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--enable", action="store_true", help="enable all three jobs")
    parser.add_argument("--check", action="store_true", help="verify without writing")
    args = parser.parse_args()

    data = json.loads(JOBS_PATH.read_text())
    if args.check:
        validate(data)
        print("PIGEON_CRON_VALID")
        return 0

    original_unrelated = [
        copy.deepcopy(job) for job in data["jobs"]
        if job.get("name") not in {spec[0] for spec in SPECS}
    ]
    existing = {job.get("name"): job for job in data["jobs"]}
    origin = delivery_origin(original_unrelated)
    desired = {
        name: desired_job(name, prompt_file, expr, hour, ceiling,
                          args.enable, origin, existing.get(name))
        for name, prompt_file, expr, hour, ceiling in SPECS
    }
    output_jobs = []
    seen = set()
    for job in data["jobs"]:
        name = job.get("name")
        if name in desired:
            if name not in seen:
                output_jobs.append(desired[name])
                seen.add(name)
        else:
            output_jobs.append(job)
    for name, *_rest in SPECS:
        if name not in seen:
            output_jobs.append(desired[name])
    data["jobs"] = output_jobs
    data["updated_at"] = now().isoformat()
    validate(data, args.enable)
    assert [job for job in data["jobs"] if job.get("name") not in desired] == original_unrelated
    backup = atomic_write(data)
    print(f"PIGEON_CRON_WRITTEN enabled={args.enable} backup={backup}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
