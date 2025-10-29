#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: LV1.py
# Desc: Lotka–Volterra (consumer–resource) dynamics; save time-series and phase plot as PDFs
# Date: Oct 2025

"""
Integrate a simple consumer–resource (Lotka–Volterra) model using
an explicit Euler scheme (no SciPy required), and save two figures:

1) Time series of Resource (R) and Consumer (C) vs time
2) Phase portrait: C vs R

Both PDFs are saved in ../Results without displaying on screen.
"""

from pathlib import Path
import numpy as np

# Use a non-interactive backend so nothing pops up
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def lv_euler(R0=40.0, C0=9.0, a=0.6, b=0.025, c=0.8, d=0.02,  # parameters
             tmax=60.0, dt=0.01):
    """
    Euler integration for:
        dR/dt =  a*R - b*R*C
        dC/dt = -c*C + d*R*C
    Returns (t, R, C)
    """
    n = int(tmax / dt) + 1
    t = np.linspace(0, tmax, n)
    R = np.zeros(n)
    C = np.zeros(n)
    R[0], C[0] = R0, C0

    for i in range(n - 1):
        dR = a * R[i] - b * R[i] * C[i]
        dC = -c * C[i] + d * R[i] * C[i]
        R[i + 1] = max(R[i] + dt * dR, 0.0)  # keep non-negative
        C[i + 1] = max(C[i] + dt * dC, 0.0)

    return t, R, C


def main():
    # ---- run model
    t, R, C = lv_euler()

    # ---- output directory (Week2/Results)
    out_dir = Path(__file__).resolve().parent.parent / "Results"
    out_dir.mkdir(parents=True, exist_ok=True)

    # ---- Figure 1: time series
    fig1 = plt.figure()
    plt.plot(t, R, label="Resource (R)")
    plt.plot(t, C, label="Consumer (C)")
    plt.xlabel("Time")
    plt.ylabel("Density")
    plt.title("Lotka–Volterra: time series")
    plt.legend()
    fig1.tight_layout()
    fig1.savefig(out_dir / "LV_time.pdf")

    # ---- Figure 2: phase portrait (C vs R)
    fig2 = plt.figure()
    plt.plot(R, C)
    plt.xlabel("Resource density (R)")
    plt.ylabel("Consumer density (C)")
    plt.title("Consumer–Resource population dynamics")
    fig2.tight_layout()
    fig2.savefig(out_dir / "LV_phase.pdf")

    # plt.show()  # intentionally omitted


if __name__ == "__main__":
    main()
