#!/usr/bin/env python3
"""Measure fresh Emacs processes, optionally interleaving a reference config."""
import argparse
import json
import os
from pathlib import Path
import statistics
import subprocess

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--emacs", default=os.environ.get("EMACS", "emacs"))
parser.add_argument("--runs", type=int, default=7)
parser.add_argument("--compare", type=Path, help="Reference configuration directory")
args = parser.parse_args()
if args.runs < 1:
    parser.error("--runs must be positive")
script = Path(__file__).with_suffix(".el").resolve()
samples = {"current": [], "reference": []}
for index in range(args.runs):
    labels = ["current"] if not args.compare else ["reference", "current"]
    if args.compare and index % 2:
        labels.reverse()
    for label in labels:
        environment = os.environ.copy()
        if label == "reference":
            environment["TAU_BENCH_ROOT"] = str(args.compare.resolve())
        result = subprocess.run(
            [args.emacs, "-Q", "--batch", "-l", str(script)],
            env=environment, text=True, capture_output=True, timeout=60,
        )
        if result.returncode:
            raise SystemExit(result.stderr or result.stdout)
        samples[label].append(json.loads(result.stdout.splitlines()[-1]))


def summarize(values):
    return {
        "emacs": values[0]["emacs"],
        "runs": len(values),
        "median": {key: statistics.median(sample[key] for sample in values)
                   for key in values[0] if key != "emacs"},
        "startup_samples_seconds": [sample["startup_seconds"] for sample in values],
    }


report = summarize(samples["current"])
if args.compare:
    report = {label: summarize(values) for label, values in samples.items()}
    report["paired_startup_improvement_percent"] = statistics.median(
        100 * (1 - current["startup_seconds"] / reference["startup_seconds"])
        for current, reference in zip(samples["current"], samples["reference"])
    )
print(json.dumps(report, indent=2))
