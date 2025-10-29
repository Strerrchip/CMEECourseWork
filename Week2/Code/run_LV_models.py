#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: run_LV_models.py
# Desc: Run LV1.py and LV2.py with profiling; print timing and top hotspots
# Date: Oct 2025

from pathlib import Path
import subprocess
import time
import pstats

ROOT = Path(__file__).resolve().parent
LV1 = ROOT / "LV1.py"
LV2 = ROOT / "LV2.py"
PROF1 = ROOT / "LV1.prof"
PROF2 = ROOT / "LV2.prof"

def run_with_profile(cmd, prof_path):
    """Run a python command under cProfile, return wall time seconds."""
    t0 = time.perf_counter()
    subprocess.run(["python3", "-m", "cProfile", "-o", str(prof_path)] + cmd,
                   check=True)
    t1 = time.perf_counter()
    return t1 - t0

def show_profile(prof_path, title, top=10, sortby="cumtime"):
    print(f"\n=== Profile: {title} ({prof_path.name}) ===")
    p = pstats.Stats(str(prof_path))
    p.sort_stats(sortby).print_stats(top)

def main():
    # 1) LV1
    t1 = run_with_profile([str(LV1)], PROF1)
    show_profile(PROF1, "LV1.py")
    print(f"LV1 wall time: {t1:.3f} s")

    # 2) LV2 with example args: r a z e K
    args = ["1.0", "0.5", "1.0", "0.5", "50", "--tmax", "80"]
    t2 = run_with_profile([str(LV2)] + args, PROF2)
    show_profile(PROF2, "LV2.py")
    print(f"LV2 wall time: {t2:.3f} s")

if __name__ == "__main__":
    main()
