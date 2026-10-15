"""Rebuild the microbial growth analysis and report from the supplied raw data."""

import argparse
import csv
from importlib import metadata
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results"
STEPS = ["prepare_data.py", "fit_growth_curves.py", "review_growth_fits.py",
         "summarise_model_comparison.py", "analyse_temperature.py", "make_report_figures.py"]
REPORT_FIGURES = ["figure_1_fit_examples.pdf", "figure_2_model_comparison.pdf",
                  "figure_4_temperature_growth_rate.pdf", "figure_5_temperature_plateau.pdf"]


def read_rows(path):
    with path.open(encoding="utf-8", newline="") as stream:
        return list(csv.DictReader(stream))


def preflight(skip_pdf, report_only, diagnostics):
    required = [ROOT / "code" / name for name in STEPS]
    required += [ROOT / "code/growth_models.py"]
    required += [ROOT / "data" / name for name in
                 ["LogisticGrowthData.csv", "LogisticGrowthMetaData.csv"]]
    required += [ROOT / "code/report" / name for name in
                 ["report.tex", "references.bib", "word_count.tex"]]
    if diagnostics:
        required.append(ROOT / "code/plot_fit_diagnostics.py")
    missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
    if missing:
        raise RuntimeError("Missing project files: " + ", ".join(missing))
    versions = {name: metadata.version(name) for name in ["numpy", "pandas", "scipy", "matplotlib"]}
    if not skip_pdf:
        missing_tools = [name for name in ["pdflatex", "bibtex", "texcount"] if not shutil.which(name)]
        if missing_tools:
            raise RuntimeError("Missing LaTeX tools: " + ", ".join(missing_tools)
                               + ". Install a TeX distribution, or use --skip-pdf for analysis and Overleaf export only.")
    if report_only:
        expected = [RESULTS / name for name in ["review/merged_model_fits.csv",
                    "review/merged_predictions.csv", "review/curve_fit_review.csv",
                    "prepared_growth_data.csv", "curve_catalog.csv"]]
        if any(not path.is_file() for path in expected):
            raise RuntimeError("--report-only requires existing completed analysis outputs.")
    return versions


def run_command(command, log, cwd=ROOT):
    """Stream progress to the console and keep one combined diagnostic log."""
    print("\nRunning: " + " ".join(map(str, command)), flush=True)
    log.write("\nRunning: " + " ".join(map(str, command)) + "\n")
    log.flush()
    environment = os.environ.copy()
    environment["PYTHONUTF8"] = "1"
    environment["MPLBACKEND"] = "Agg"
    with subprocess.Popen(command, cwd=cwd, env=environment, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace") as process:
        for line in process.stdout:
            print(line, end="", flush=True)
            log.write(line)
            log.flush()
        code = process.wait()
    log.flush()
    if code:
        raise RuntimeError(f"Command failed (exit {code}); see results/pipeline.log.")


def run_script(name, log, *arguments):
    run_command([sys.executable, "-X", "utf8", "-u", str(ROOT / "code" / name), *arguments], log)


def validate_report_numbers():
    """Refuse to compile a fixed report against materially different results."""
    overall = read_rows(RESULTS / "model_comparison/model_comparison_overall.csv")
    expected = {
        ("All complete comparisons", "AICc"): {"Exponential": 69, "Logistic": 123, "Gompertz": 92},
        ("All complete comparisons", "BIC"): {"Exponential": 19, "Logistic": 148, "Gompertz": 117},
        ("Complete comparisons without numerical flags", "AICc"): {"Exponential": 48, "Logistic": 106, "Gompertz": 80},
        ("Complete comparisons without numerical flags", "BIC"): {"Exponential": 6, "Logistic": 129, "Gompertz": 99},
    }
    for (subset, criterion), counts in expected.items():
        actual = {row["model"]: int(row["n_unique_best"]) for row in overall
                  if row["subset"] == subset and row["criterion"] == criterion}
        if actual != counts:
            raise RuntimeError(f"Regenerated {criterion} counts differ from the report: {actual}. Review the report before compilation.")
    series = read_rows(RESULTS / "temperature_analysis/temperature_series_summary.csv")
    strict = [row for row in series if row["screening"] == "Strict"]
    parameters = read_rows(RESULTS / "temperature_analysis/temperature_parameters_strict.csv")
    ids = {row["series_id"] for row in strict}
    selected = [row for row in parameters if row["series_id"] in ids]
    increasing = 0
    for identifier in ids:
        group = sorted([row for row in selected if row["series_id"] == identifier], key=lambda row: float(row["Temp"]))
        increasing += all(float(right["capacity"]) > float(left["capacity"])
                          for left, right in zip(group, group[1:]))
    if (len(parameters), len(strict), len(selected), increasing) != (41, 8, 26, 5):
        raise RuntimeError("Regenerated temperature results differ from the report; review before compilation.")
    if not all(float(row["log_rate_slope_per_C"]) > 0 for row in strict):
        raise RuntimeError("Temperature slope directions differ from the report.")
    print("Report count checks passed.", flush=True)


def prepare_report():
    folder = RESULTS / "report"
    (folder / "figures").mkdir(parents=True, exist_ok=True)
    for name in ["report.tex", "references.bib", "word_count.tex"]:
        shutil.copyfile(ROOT / "code/report" / name, folder / name)
    for name in REPORT_FIGURES:
        shutil.copyfile(RESULTS / "report_figures" / name, folder / "figures" / name)
    # A skipped or failed build must not leave an old PDF labelled as current.
    for name in ["report.pdf", "report-words.sum"]:
        (folder / name).unlink(missing_ok=True)
    archive = RESULTS / "MiniProject_Overleaf.zip"
    import zipfile
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as output:
        for name in ["report.tex", "references.bib", "word_count.tex"]:
            output.write(folder / name, name)
        for name in REPORT_FIGURES:
            output.write(folder / "figures" / name, "figures/" + name)
    return folder


def compile_report(folder, log):
    # Run TeXcount explicitly so local compilation does not require shell escape.
    counted = subprocess.run(["texcount", "-1", "-sum=1,1,0,0,0,0,0", "-merge", "-q", "report.tex"],
                             cwd=folder, text=True, encoding="utf-8", capture_output=True, check=True)
    count = counted.stdout.strip()
    if not re.fullmatch(r"\d+", count):
        raise RuntimeError("Unexpected TeXcount output: " + count + counted.stderr)
    if int(count) > 3500:
        raise RuntimeError(f"Report word count {count} exceeds 3500.")
    (folder / "report-words.sum").write_text(count + "\n", encoding="utf-8")
    (folder / "word_count.tex").write_text(r"{\large Word count: \input{report-words.sum}\par}" + "\n", encoding="utf-8")
    latex = ["pdflatex", "-interaction=nonstopmode", "-halt-on-error", "report.tex"]
    run_command(latex, log, folder)
    run_command(["bibtex", "report"], log, folder)
    run_command(latex, log, folder)
    run_command(latex, log, folder)
    pdf = folder / "report.pdf"
    if not pdf.is_file() or pdf.stat().st_size == 0:
        raise RuntimeError("LaTeX did not create a nonempty report PDF.")
    diagnostics = (folder / "report.log").read_text(encoding="utf-8", errors="replace")
    if "There were undefined references" in diagnostics or "There were undefined citations" in diagnostics:
        raise RuntimeError("Report compilation left unresolved references; inspect results/report/report.log.")
    print(f"Compiled report: {pdf}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skip-pdf", action="store_true", help="Run analysis and export an Overleaf ZIP; do not compile a local PDF.")
    parser.add_argument("--report-only", action="store_true", help="Refresh summaries, figures and the report from existing fits, without fitting again.")
    parser.add_argument("--diagnostics", action="store_true", help="Also generate all individual fit diagnostic plots.")
    parser.add_argument("--check", action="store_true", help="Check inputs and dependencies without generating outputs.")
    args = parser.parse_args()
    started = time.monotonic()
    versions = preflight(args.skip_pdf, args.report_only, args.diagnostics)
    print("Project files and dependencies passed preflight.", flush=True)
    if args.check:
        return
    RESULTS.mkdir(exist_ok=True)
    with (RESULTS / "pipeline.log").open("w", encoding="utf-8") as log:
        if not args.report_only:
            run_script("prepare_data.py", log)
            run_script("fit_growth_curves.py", log)
            retry_folder = RESULTS / "retry_failed_10000"
            # Remove only previous generated retry files, never raw inputs.
            for name in ["model_fits.csv", "predictions.csv", "fit_attempts.csv"]:
                (retry_folder / name).unlink(missing_ok=True)
            initial = read_rows(RESULTS / "batch/model_fits.csv")
            if any(row["status"] == "failed" for row in initial):
                run_script("fit_growth_curves.py", log, "--retry-failed", "--max-nfev", "10000")
            for name in STEPS[2:]:
                run_script(name, log)
            if args.diagnostics:
                run_script("plot_fit_diagnostics.py", log, "--all")
        else:
            for name in STEPS[3:]:
                run_script(name, log)
        validate_report_numbers()
        report_folder = prepare_report()
        if not args.skip_pdf:
            compile_report(report_folder, log)
    status = {"python": sys.version, "packages": versions, "elapsed_seconds": time.monotonic() - started,
              "local_pdf_compiled": not args.skip_pdf, "used_existing_analysis": args.report_only}
    (RESULTS / "pipeline_run.json").write_text(json.dumps(status, indent=2) + "\n", encoding="utf-8")
    if args.skip_pdf:
        print("Analysis and Overleaf export completed. Local PDF compilation was explicitly skipped.")
    else:
        print("Full analysis and local report compilation completed.")
    print("Overleaf project: results/MiniProject_Overleaf.zip")


if __name__ == "__main__":
    try:
        main()
    except (RuntimeError, OSError, subprocess.CalledProcessError, metadata.PackageNotFoundError) as error:
        print(f"Pipeline stopped: {error}", file=sys.stderr)
        sys.exit(1)
