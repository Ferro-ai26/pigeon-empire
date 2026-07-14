# Post-Bootstrap Verification Checklist

These commands are for verification after Codex completes the bootstrap.

```bash
ssh chucky
cd /home/ubuntu/pigeon-empire

git status --short
git branch -vv
git log --oneline --decorate -8

printf '\n=== HANDOFF ===\n'
sed -n '1,220p' docs/CURRENT_HANDOFF.md

printf '\n=== ACTIVE PHASE ===\n'
sed -n '1,260p' docs/ACTIVE_PHASE.md

printf '\n=== CRON LIST ===\n'
hermes cron list

printf '\n=== CRON STATUS ===\n'
hermes cron status

printf '\n=== PIGEON JOB RECORDS ===\n'
python3 - <<'PY'
import json
from pathlib import Path

p = Path.home() / ".hermes" / "cron" / "jobs.json"
data = json.loads(p.read_text())
wanted = {
    "pigeon-empire-director-weekdays",
    "pigeon-empire-builder-weekdays",
    "pigeon-empire-qa-weekdays",
}
for job in data["jobs"]:
    if job.get("name") in wanted:
        print({
            "id": job.get("id"),
            "name": job.get("name"),
            "enabled": job.get("enabled"),
            "provider": job.get("provider"),
            "model": job.get("model"),
            "schedule": job.get("schedule"),
            "timezone": job.get("timezone"),
            "workdir": job.get("workdir"),
            "max_iterations": job.get("max_iterations"),
            "skills": job.get("skills"),
            "toolsets": job.get("enabled_toolsets"),
            "deliver": job.get("deliver"),
            "origin": job.get("origin"),
        })
PY

printf '\n=== MODEL ENFORCEMENT ===\n'
python3 - <<'PY'
from pathlib import Path
import yaml

cfg = yaml.safe_load((Path.home()/".hermes/config.yaml").read_text())
print(cfg.get("cron"))
print("interactive model:", cfg.get("model"))
PY

printf '\n=== PROMPT IDENTITY ===\n'
python3 - <<'PY'
import json
from pathlib import Path

repo = Path("/home/ubuntu/pigeon-empire")
jobs = json.loads((Path.home()/".hermes/cron/jobs.json").read_text())["jobs"]
mapping = {
    "pigeon-empire-director-weekdays": repo/"ops/prompts/director.md",
    "pigeon-empire-builder-weekdays": repo/"ops/prompts/builder.md",
    "pigeon-empire-qa-weekdays": repo/"ops/prompts/qa.md",
}
for name, path in mapping.items():
    job = next(j for j in jobs if j.get("name") == name)
    print(name, "MATCH" if job.get("prompt") == path.read_text() else "MISMATCH")
PY
```

Expected workflow state after bootstrap:

```text
NEEDS_PLAN
```

Expected first autonomous action:

The next 08:00 Pacific Director run selects one small Phase 0/1 objective and changes the workflow state to `READY_FOR_BUILD`.
