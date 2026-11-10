"""Run Lean's exhaustive project theorem axiom audit and save provenance.

Verification.lean discovers theorem declarations from the imported environment,
not a hand-selected theorem-name list. Both Lean and this wrapper reject axioms
outside the stated allowlist. Build all modules before running this command.
"""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time
from datetime import datetime, timezone


def main() -> None:
    here = Path(__file__).resolve().parent
    repo = here.parent
    results = repo / "results"
    results.mkdir(exist_ok=True)
    lake = shutil.which("lake")
    if not lake:
        fallback = Path.home() / ".elan" / "bin" / ("lake.exe" if os.name == "nt" else "lake")
        if fallback.is_file():
            lake = str(fallback)
    if not lake:
        raise SystemExit("lake is not available")
    command = [lake, "env", "lean", "Verification.lean"]
    start = time.monotonic()
    completed = subprocess.run(command, cwd=here, text=True, encoding="utf-8",
                               errors="replace", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    elapsed = time.monotonic() - start
    (results / "lean-axioms.log").write_text(completed.stdout, encoding="utf-8")
    if completed.returncode:
        raise SystemExit(f"Lean axiom audit failed ({completed.returncode}); see results/lean-axioms.log")
    records = [json.loads(line.split("AXIOM_AUDIT ", 1)[1])
               for line in completed.stdout.splitlines() if "AXIOM_AUDIT {" in line]
    counts = re.findall(r"AXIOM_AUDIT_COUNT (\d+)", completed.stdout)
    if len(counts) != 1 or not records or len(records) != int(counts[0]):
        raise SystemExit("Incomplete theorem audit output")
    if len({r["theorem"] for r in records}) != len(records):
        raise SystemExit("Duplicate theorem records")
    allowed = {"propext", "Classical.choice", "Quot.sound"}
    for record in records:
        forbidden = set(record["axioms"]) - allowed
        if forbidden:
            raise SystemExit(f"Disallowed axioms: {record['theorem']}: {forbidden}")
    version = subprocess.run([lake, "env", "lean", "--version"], cwd=here,
                             text=True, encoding="utf-8", stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT, check=True).stdout.strip()
    sources = [here / "ContextualityTensor.lean", here / "Verification.lean",
               here / "lakefile.toml", here / "lean-toolchain", here / "lake-manifest.json"]
    sources += sorted((here / "ContextualityTensor").rglob("*.lean"))
    hashes = {p.relative_to(repo).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
              for p in sources}
    report = {"status": "passed", "checked_at_utc": datetime.now(timezone.utc).isoformat(),
              "command": "lake env lean Verification.lean", "lean_version": version,
              "elapsed_seconds": elapsed, "discovery": "all imported theorem declarations under ContextualityTensor",
              "theorem_count": len(records), "allowed_axioms": sorted(allowed),
              "source_sha256": hashes, "theorems": records}
    (results / "lean-axioms.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Passed axiom audit: {len(records)} project theorems; allowlist {sorted(allowed)}")


if __name__ == "__main__":
    main()
