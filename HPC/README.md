# HPC coursework

Author: Leyu Chen (Avery). College username: lc2025. Course year: 2025.

This is the completed local preparation uploaded on 19 October 2026. The coursework is incomplete because required HPC access remains unavailable. Read STATUS.md for the exact scope. No actual cluster runs or scheduler logs are included.

## Files

- Code: required main and cluster R scripts, supplied Demographic.R, shell scripts and local checks.
- Data: local saved data and personal rate. The Q23 five-minute file is explicitly a local test.
- Results: local graphs, answers, timing and task-setting tables, plus the preparation-check record.
- Log: reserved for real cluster logs; currently empty apart from .gitkeep.

The main file defines functions and identity fields. Sourcing it does not start simulations, change directories, plot or clear the workspace. The required scripts are lc2025_HPC_2025_main.R, lc2025_HPC_2025_demographic_cluster.R and lc2025_HPC_2025_neutral_cluster.R.

## Local checks

Run from this folder, containing Code, Data, Results and Log:

```powershell
Rscript --vanilla Code/check_final_preparation.R
```

Checks for individual stages are in Code/check_stage1.R through Code/check_stage8.R. The stage 5 check intentionally runs for five minutes and creates a timestamped local test output. Stage 7 and stage 8 wait for complete real cluster output before creating final summaries. No placeholder cluster data are used.

R 4.4.2 was used locally. Main coursework functions use base R. The separate supplied personal-rate method uses digest; the resulting saved rate is 0.0021811. Keep 0.1 for Questions 18, 22 and the local Q23 test; the personal rate is for Q24.

## Prepared cluster runs

The demographic array has 100 tasks, each with 150 simulations lasting 120 months. Four initial conditions receive 25 tasks each. The shell script requests ten minutes per task; local benchmark maximum was 0.15 seconds per simulation, which is not a cluster speed guarantee.

The neutral array has 100 tasks: 25 each at community sizes 500, 1000, 2500 and 5000. Each task is configured for 690 minutes with a requested 12-hour scheduler limit. These are prepared settings, not completed execution.

After access is restored, first confirm the actual scheduler and R environment. The shell scripts do not guess a module name. Follow the worksheet by submitting tasks 1-3 first, waiting for completion and inspecting the real data and output/error logs, then submitting tasks 4-100. Submit from this folder and use the relevant script:

```bash
qsub -J 1-3 Code/run_demographic.sh
qsub -J 1-3 Code/run_neutral.sh
```

Do not execute array simulations directly on the login node. Do not submit the remaining tasks until the corresponding first three have passed. Retain all required real .rda and scheduler .o/.e files for GitHub submission.

Questions 5-6 and 26 processing functions are prepared, but final outputs depend on complete real cluster results. Local checks do not certify scheduler compatibility, successful HPC execution or complete coursework submission. Optional challenges are not claimed as completed.
