#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: LV2.py
# Desc: Lotka–Volterra with resource density dependence (logistic term); save PDFs, CLI params
# Date: Oct 2025

from pathlib import Path
import argparse
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

def lv2_euler(R0=40.0, C0=9.0, r=1.0, a=0.5, z=1.0, e=0.5, K=50.0,
              tmax=60.0, dt=0.01):
    """Euler integration for:
        dR/dt = r*R*(1 - R/K) - a*C*R
        dC/dt = -z*C + e*a*C*R
    Returns (t, R, C)
    """
    n = int(tmax / dt) + 1
    t = np.linspace(0, tmax, n)
    R = np.zeros(n); C = np.zeros(n)
    R[0], C[0] = R0, C0
    for i in range(n - 1):
        dR = r*R[i]*(1 - R[i]/K) - a*C[i]*R[i]
        dC = -z*C[i] + e*a*C[i]*R[i]
        R[i+1] = max(R[i] + dt*dR, 0.0)
        C[i+1] = max(C[i] + dt*dC, 0.0)
    return t, R, C

def save_figs(t, R, C, out_dir, tag="LV2"):
    out_dir = Path(out_dir); out_dir.mkdir(parents=True, exist_ok=True)
    # time series
    fig1 = plt.figure()
    plt.plot(t, R, label="Resource (R)")
    plt.plot(t, C, label="Consumer (C)")
    plt.xlabel("Time"); plt.ylabel("Density")
    plt.title(f"{tag}: time series")
    plt.legend(); fig1.tight_layout()
    fig1.savefig(out_dir / f"{tag}_time.pdf")
    plt.close(fig1)
    # phase portrait
    fig2 = plt.figure()
    plt.plot(R, C)
    plt.xlabel("Resource density (R)")
    plt.ylabel("Consumer density (C)")
    plt.title(f"{tag}: phase portrait")
    fig2.tight_layout()
    fig2.savefig(out_dir / f"{tag}_phase.pdf")
    plt.close(fig2)

def parse_args():
    p = argparse.ArgumentParser(
        description="Lotka–Volterra with resource density dependence (LV2)"
    )
    p.add_argument("r", type=float, nargs="?", default=1.0, help="resource growth rate r")
    p.add_argument("a", type=float, nargs="?", default=0.5, help="attack rate a")
    p.add_argument("z", type=float, nargs="?", default=1.0, help="consumer mortality z")
    p.add_argument("e", type=float, nargs="?", default=0.5, help="conversion efficiency e")
    p.add_argument("K", type=float, nargs="?", default=50.0, help="resource carrying capacity K")
    p.add_argument("--R0", type=float, default=40.0)
    p.add_argument("--C0", type=float, default=9.0)
    p.add_argument("--tmax", type=float, default=60.0)
    p.add_argument("--dt", type=float, default=0.01)
    p.add_argument("--outdir", default=str(Path(__file__).resolve().parent.parent / "Results"))
    return p.parse_args()

def main():
    args = parse_args()
    t, R, C = lv2_euler(R0=args.R0, C0=args.C0, r=args.r, a=args.a, z=args.z,
                        e=args.e, K=args.K, tmax=args.tmax, dt=args.dt)
    save_figs(t, R, C, args.outdir, tag=f"LV2_r{args.r}_a{args.a}_z{args.z}_e{args.e}_K{args.K}")
    # Print final values
    print(f"Final R={R[-1]:.4f}, C={C[-1]:.4f}  (t={args.tmax})")

if __name__ == "__main__":
    main()
