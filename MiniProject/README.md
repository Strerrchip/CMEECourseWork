# Microbial growth models and temperature

Author: Avery L. Chen (Leyu Chen), Imperial College London.

This self-contained Computing MiniProject compares exponential, logistic and Gompertz growth models using nonlinear least squares. It asks which models receive most support across the supplied growth curves, and how logistic rate and plateau estimates vary with temperature within comparable experimental series.

## Inputs and layout

The original `data/LogisticGrowthData.csv` and `data/LogisticGrowthMetaData.csv` are supplied course data from the MQB-HPC archive. The growth file contains 4,387 observations grouped into 305 curves from ten cited studies. The source studies are listed in the report bibliography. Original values are retained; time is shifted within curves, and data-quality flags are exported separately. Curves need six distinct observation times and a positive time span for fitting.

```text
MiniProject/
  run_MiniProject.py          # entry point
  README.md
  requirements.txt
  .gitignore
  code/                      # analysis scripts
    report/                  # LaTeX and BibTeX source
  data/                      # supplied raw inputs
  results/                   # generated files; excluded from Git
```

## Dependencies

The analysis was developed and checked using Python 3.14.5 with NumPy 2.5.4, pandas 3.0.6, SciPy 1.18.1 and Matplotlib 3.11.2. `requirements.txt` records the installed Python package versions. NumPy supplies numerical arrays, pandas manages grouped tables, SciPy performs optimisation and Matplotlib draws figures. The runner uses the Python standard library to launch each step and check outputs.

For complete local report compilation, install a TeX distribution providing `pdflatex`, `bibtex`, `texcount`, and the standard packages used in `code/report/report.tex`. TeX Live can provide these on Linux. The pipeline does not install software automatically. R and bash are not needed for this implementation.

From the project root, create a Python environment and install dependencies:

```powershell
# Windows PowerShell (use an available Python 3.14 installation)
py -3.14 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -X utf8 run_MiniProject.py
```

```sh
# Linux with Python 3.14 and a TeX distribution installed
python3.14 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python run_MiniProject.py
```

An existing environment can run the entry point directly. All paths are resolved relative to the entry point, so running from another working directory is also supported.

## Execution modes

- Default: prepare data, fit all 290 eligible curves, retry failed fits, review fits, compare models, analyse temperature, generate report figures, check agreement with report counts, and compile `results/report/report.pdf`.
- `--skip-pdf`: perform the same analysis and create `results/MiniProject_Overleaf.zip` without local PDF compilation. Upload this ZIP as an existing project in Overleaf. This mode is useful on a machine without TeX; it is not a complete local PDF-build check.
- `--diagnostics`: additionally generate individual diagnostic plots for all screened curves.
- `--report-only`: refresh comparison summaries, temperature analysis and figures from existing reviewed fits, then prepare and compile the report without fitting again. It can be combined with `--skip-pdf` to export the Overleaf project only.
- `--check`: check required files and dependencies without generating outputs. Combine with `--skip-pdf` to check only the analysis environment.

For example, on the current Windows computer without a local TeX installation:

```powershell
.\.venv\Scripts\python.exe -X utf8 run_MiniProject.py --skip-pdf
```

Errors stop the pipeline with a nonzero exit status. Missing TeX is detected before fitting in the default mode. Logs are saved in `results/pipeline.log`, and successful-run versions and mode are saved in `results/pipeline_run.json`. The raw files are never rewritten. Rerunning replaces generated tables and figures and removes only the three previous retry CSV files before rebuilding retry results.

## Script roles

| Script | Purpose |
|---|---|
| `prepare_data.py` | Define curves, shift time, flag observations and export fitting eligibility. |
| `growth_models.py` | Define the three growth functions and comparison metrics. |
| `fit_growth_curves.py` | Fit from several starting values; save parameters, predictions, residuals and attempt logs. |
| `review_growth_fits.py` | Combine initial and retry fits and identify incomplete or numerically flagged comparisons. |
| `summarise_model_comparison.py` | Export AICc and BIC summaries overall, by study and by organism label. |
| `analyse_temperature.py` | Screen comparable Bae-study curves and describe logistic parameter trends. |
| `make_report_figures.py` | Generate smooth example fits, comparison plots and the study table. |
| `plot_fit_diagnostics.py` | Optional individual observed/predicted and residual plots. |

## Outputs and interpretation

Prepared data and screening tables are written directly under `results/`. Initial fits are in `results/batch/`, failed-pair retries in `results/retry_failed_10000/`, combined review tables in `results/review/`, model summaries in `results/model_comparison/`, temperature results in `results/temperature_analysis/` and figure candidates in `results/report_figures/`. The report uses four figures and one study table; the species heatmap remains a supporting candidate.

The checked dataset has 284 complete comparisons, including 234 without numerical warnings. AICc minima are 123 logistic, 92 Gompertz and 69 exponential. Strict temperature screening retains 41 curves; eight series with at least three temperatures contain 26 curves. Five of those series have increasing plateau estimates at every retained temperature. The runner verifies these headline counts before preparing the fixed report. If changes to data, fitting or numerical libraries alter them, update and review the report rather than bypassing the check.

Model preference does not establish model adequacy or parameter identifiability. Temperature slopes are descriptive, and measurement labels are retained without conversion. The report discusses error assumptions, selection bias and uncertainty.

The Overleaf export contains generated figures and current report source. Local compilation runs TeXcount explicitly and writes the resulting number into the generated report copy; shell escape is not required. Overleaf computes its count through the source's own TeXcount command. Report source under `code/report/` remains unchanged by either analysis mode.

## Version control

Commit the root runner, README, requirements, `.gitignore`, analysis/report source and supplied input CSV files. Do not commit `.venv`, caches or generated results. The local `.gitignore` explicitly retains the two input CSVs because the parent coursework repository may ignore CSV files globally. The assessor regenerates results using the root runner.

Local validation of the analysis and Overleaf export does not verify a Linux environment or local TeX compilation. The compiled Overleaf report has been visually reviewed separately. These checks should not be reported as a successful single-command local PDF build until the default mode has run with the required TeX tools.

A fresh Windows analysis run using the documented environment completed in approximately 9.3 minutes. Prepared data, initial/retry fits, merged predictions, comparison summaries and temperature tables matched the previous analysis byte for byte. The refreshed temperature PNGs matched the visually reviewed report figures. The report-only mode, launch from another working directory, absence of retry files and retention of raw CSVs under the parent Git ignore rules were also checked. Default-mode preflight correctly identified the unavailable local TeX tools before starting analysis.
