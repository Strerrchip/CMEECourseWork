# HPC coursework

Author: Leyu Chen (Avery). College username: lc2025. Course year: 2025.

Both cluster arrays have completed on Imperial CX3. Real task outputs, scheduler logs and processed results are included. See STATUS.md for run records and checks. The initial upload on 19 October contained local preparation while Unified Access was unavailable. Completed cluster results were checked locally on 21 October 2026.

## Files

- Code: main functions, cluster R entry scripts, supplied Demographic.R, PBS scripts and local checks.
- Data: 100 demographic task files, 100 neutral task files, the neutral summary, local exercise data and the personal speciation rate.
- Results: exercise graphs and answers, demographic comparisons, and the four-panel neutral abundance distribution graph with its task summary table.
- Log: 200 scheduler standard-output files (.OU) and 200 error files (.ER) for both arrays. All downloaded error files are empty.

Sourcing Code/lc2025_HPC_2025_main.R defines functions and identity fields without starting simulations, printing, changing directories or random-number state, or creating graphics.

## Environment and cluster runs

Local and cluster runs used R 4.4.2. Both PBS scripts load the verified module:

```bash
module load R/4.4.2-gfbf-2024a
```

Main functions use base R. The separate personal-rate generation method uses digest. The saved rate is 0.0021811 for Question 24. Keep 0.1 for Questions 18 and 22 and the local Question 23 test.

The demographic array has 100 tasks, with 150 simulations of 120 months per task. There are 25 tasks per initial condition, giving 3,750 simulations per condition and 15,000 in total. The PBS wall-time request is ten minutes per task.

The neutral array has 100 tasks: 25 each at community sizes 500, 1000, 2500 and 5000. Each simulation runs for 690 minutes with a 12-hour PBS wall-time limit. Burn-in and sampling settings are recorded in Results/neutral_task_settings.csv and the logs.

For each array, tasks 1-3 were checked before tasks 4-100 were submitted. Completed job IDs are in STATUS.md. To reproduce a run, submit from this folder on HPC. Do not execute simulations on login nodes. These commands start new jobs; they are not needed to inspect supplied results:

```bash
qsub -J 1-3 Code/run_demographic.sh
qsub -J 1-3 Code/run_neutral.sh
```

After checking those first tasks, submit tasks 4-100 of the corresponding array. Preserve supplied outputs before rerunning because task filenames are reused.

## Checks and result processing

Run from this folder, containing Code, Data, Results and Log:

```powershell
Rscript --vanilla Code/check_final_preparation.R
Rscript --vanilla Code/check_stage8.R
Rscript --vanilla Code/check_stage7.R
```

The preparation check covers function signatures, source side effects, syntax, identity and file availability. Stage 8 processes the complete demographic data for Questions 5-6. Stage 7 processes the complete neutral data for Question 26 and saves Data/neutral_cluster_summary.rda and Results/plot_neutral_cluster_results.png. Generic readiness messages are not scheduler certificates; actual execution is recorded in the retained logs.

Other exercise checks are in Code/check_stage1.R through Code/check_stage6.R. Stage 5 intentionally runs for five minutes and creates a timestamped local output. The included Question 23 five-minute file is a local test, separate from the 690-minute neutral cluster runs. Optional challenge completion is not claimed.
