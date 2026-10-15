"""Create report figure candidates from saved fits and temperature analysis."""

from pathlib import Path
import re
import shutil
import textwrap

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from growth_models import exponential, logistic, gompertz


MODELS = ["Exponential", "Logistic", "Gompertz"]
COLORS = ["steelblue", "darkorange", "seagreen"]


def save_figure(fig, folder, name):
    fig.savefig(folder / f"{name}.png", dpi=220, bbox_inches="tight")
    fig.savefig(folder / f"{name}.pdf", bbox_inches="tight")
    plt.close(fig)


def predict(row, time, scale, duration):
    """Evaluate the fitted equations using the scaling used during fitting."""
    t = time / duration
    if row.model == "Exponential":
        return exponential(t, row.initial_value / scale, row.growth_rate * duration) * scale
    if row.model == "Logistic":
        return logistic(t, row.initial_value / scale, row.growth_rate * duration,
                        row.capacity / scale) * scale
    return gompertz(t, row.capacity / scale, row["shape"], row.rate * duration) * scale


def main():
    root = Path(__file__).resolve().parents[1]
    results = root / "results"
    folder = results / "report_figures"
    folder.mkdir(parents=True, exist_ok=True)
    data = pd.read_csv(results / "prepared_growth_data.csv")
    catalog = pd.read_csv(results / "curve_catalog.csv")
    review = pd.read_csv(results / "review" / "curve_fit_review.csv")
    fits = pd.read_csv(results / "review" / "merged_model_fits.csv")
    saved = pd.read_csv(results / "review" / "merged_predictions.csv")
    overall = pd.read_csv(results / "model_comparison" / "model_comparison_overall.csv")
    species = pd.read_csv(results / "model_comparison" / "model_comparison_by_species.csv")

    examples = [("C041", "Growth and plateau"), ("C034", "Growth followed by decline"),
                ("C185", "No observed plateau"), ("C246", "Little net change")]
    fig, axes = plt.subplots(2, 2, figsize=(10, 7))
    for ax, (identifier, description) in zip(axes.flat, examples):
        curve = data.loc[data.curve_id.eq(identifier)].sort_values("time_since_first")
        meta = review.loc[review.curve_id.eq(identifier)].iloc[0]
        time = curve.time_since_first.to_numpy(dtype=float)
        scale = float(np.max(np.abs(curve.PopBio)))
        duration = float(time.max())
        grid = np.linspace(0, duration, 600)
        ax.scatter(time, curve.PopBio, color="black", s=18, label="Observed", zorder=4)
        for model, color in zip(MODELS, COLORS):
            row = fits.loc[fits.curve_id.eq(identifier) & fits.model.eq(model)].iloc[0]
            if row.status != "converged":
                continue
            check = predict(row, time, scale, duration)
            original = saved.loc[saved.curve_id.eq(identifier) & saved.model.eq(model)]
            original = original.sort_values("time_since_first").predicted.to_numpy()
            if len(check) != len(original) or not np.allclose(check, original, rtol=1e-5, atol=scale*1e-8):
                raise ValueError(f"Reconstructed predictions differ: {identifier}, {model}")
            prediction = predict(row, grid, scale, duration)
            if not np.isfinite(prediction).all():
                raise ValueError(f"Non-finite smooth predictions: {identifier}, {model}")
            ax.plot(grid, prediction, color=color, lw=1.5, label=model)
        ax.set_title(f"{identifier}: {description}\n{meta.Species}, {meta.Temp:g} C", fontsize=9)
        ax.set_xlabel("Time since first observation (hours)")
        ax.set_ylabel(f"Measurement ({meta.PopBio_units}, supplied units)")
        ax.grid(alpha=.2)
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="lower center", ncol=4, frameon=False)
    fig.tight_layout(rect=(0, .06, 1, 1))
    save_figure(fig, folder, "figure_1_fit_examples")

    fig, axes = plt.subplots(1, 2, figsize=(10, 4), sharey=True)
    subsets = [("All complete comparisons", "All complete comparisons"),
               ("Complete comparisons without numerical flags", "No numerical flags")]
    x = np.arange(3)
    for ax, (subset, label) in zip(axes, subsets):
        table = overall.loc[overall.subset.eq(subset)]
        denominator = int(table.n_curves.iloc[0])
        for criterion, offset, color in [("AICc", -.19, "steelblue"), ("BIC", .19, "darkorange")]:
            values = table.loc[table.criterion.eq(criterion)].set_index("model").loc[MODELS]
            counts = values.n_unique_best.to_numpy()
            bars = ax.bar(x + offset, 100 * counts / denominator, .36, label=criterion, color=color)
            ax.bar_label(bars, labels=[str(int(v)) for v in counts], fontsize=9, padding=3)
        ax.set_title(f"{label} (n = {denominator})", fontsize=10)
        ax.set_xticks(x, MODELS)
        ax.set_ylim(0, 65)
        ax.grid(axis="y", alpha=.2)
        ax.set_axisbelow(True)
    axes[0].set_ylabel("Curves with unique minimum (%)")
    axes[1].legend(frameon=False)
    fig.tight_layout()
    save_figure(fig, folder, "figure_2_model_comparison")

    selected = species.loc[species.subset.eq("All complete comparisons") & species.criterion.eq("AICc")]
    counts = selected.pivot(index="Species", columns="model", values="n_unique_best").reindex(columns=MODELS)
    totals = selected.groupby("Species").n_curves.first().reindex(counts.index)
    proportions = counts.div(totals, axis=0)
    halves = np.array_split(np.arange(len(counts)), 2)
    fig, axes = plt.subplots(1, 2, figsize=(13, 10), layout="constrained")
    for ax, indices in zip(axes, halves):
        part = proportions.iloc[indices]
        im = ax.imshow(part.to_numpy(), cmap="Blues", vmin=0, vmax=1, aspect="auto")
        labels = [textwrap.fill(f"{name} (n={int(totals.loc[name])})", 47) for name in part.index]
        ax.set_yticks(np.arange(len(part)), labels, fontsize=7)
        ax.set_xticks(np.arange(3), MODELS, fontsize=9)
        ax.xaxis.tick_top()
        for i, name in enumerate(part.index):
            for j, model in enumerate(MODELS):
                value = float(part.loc[name, model])
                ax.text(j, i, str(int(counts.loc[name, model])), ha="center", va="center",
                        fontsize=8, color="white" if value > .55 else "black")
    fig.colorbar(im, ax=list(axes), label="Fraction with unique minimum AICc", shrink=.6)
    save_figure(fig, folder, "figure_3_comparison_by_species_label")

    for source, target in [("temperature_growth_rate", "figure_4_temperature_growth_rate"),
                           ("temperature_plateau", "figure_5_temperature_plateau")]:
        for suffix in ["png", "pdf"]:
            shutil.copyfile(results / "temperature_analysis" / f"{source}.{suffix}",
                            folder / f"{target}.{suffix}")

    inventory = []
    for citation, group in catalog.groupby("Citation", sort=True):
        screened = review.loc[review.Citation.eq(citation)]
        study = citation.split(",")[0] + " " + re.search(r"\b(?:19|20)\d{2}\b", citation).group()
        inventory.append({
            "study": study,
            "n_original_curves": len(group),
            "n_screened_curves": len(screened),
            "n_complete_comparisons": int(screened.complete_comparison.astype(str).str.lower().eq("true").sum()),
            "n_species_labels": group.Species.nunique(),
            "minimum_temperature_C": group.Temp.min(),
            "maximum_temperature_C": group.Temp.max(),
            "supplied_units": "; ".join(sorted(group.PopBio_units.unique())),
        })
    pd.DataFrame(inventory).to_csv(folder / "table_1_study_inventory.csv", index=False)
    captions = """Report figure candidates and captions
=====================================
Table 1. Dataset composition and fitting coverage by study. Species labels
and measurement units are retained as supplied. Curve counts describe
experimental series and should not be treated as independent species.

Figure 1. Four illustrative growth trajectories and fitted models.
C041 shows growth and a plateau; C034 includes a decline; C185 does not
reach a plateau; C246 has little net change. Lines evaluate the fitted
equations on a dense time grid. Examples illustrate limitations and were
not selected as a representative random sample. Supplied CFU labels do
not verify whether source measurements were transformed. Several fitted
parameters in C185 and C246 have numerical warnings; their curves are
shown to illustrate the difference between fitting and interpretation.

Figure 2. Relative model preference using AICc and BIC. Bar heights show
percentages of curves with a unique minimum; labels show counts. The
full subset includes 284 complete comparisons. The sensitivity subset
includes 234 comparisons without numerical flags for any candidate
model. Both compare the same three models within each retained curve.
A numerical tie uses absolute tolerance 1e-8. Model preference does not
establish model adequacy or parameter identifiability.

Figure 3. Model preference across the 45 supplied species/strain/community
labels in complete comparisons. Cell numbers are unique AICc minima;
colour shows the corresponding fraction within each row. Row labels give
the number of compared curves. Labels are not taxonomically harmonised,
and differences can reflect study, medium, temperature, sampling or
measurement scale rather than species alone. All complete comparisons,
including numerical warnings, are shown.

Figure 4. Logistic rate estimates across temperature in eight retained
series from the Bae study (TSB, OD595), with at least three temperatures
per series after strict screening. The vertical axis is logarithmic.
Orange points have logistic delta AICc < 2. Lines connect fitted point
estimates and do not represent an inferred thermal response function.
No confidence intervals are shown; screening may introduce selection bias.

Figure 5. Logistic OD plateau estimates for the same retained series.
Axes are scaled separately to show within-series variation. The plateau
is an OD estimate, not a direct cell count. Colours follow Figure 4.

These five figures and one table are candidates; the report uses four
figures and one table. Detailed diagnostic plots and screening tables remain supporting
outputs. Read temperature_analysis_notes.txt for all screening rules.
"""
    (folder / "figure_captions.txt").write_text(captions, encoding="utf-8")
    print("Saved 5 figure candidates, each as PNG and PDF, and 1 study table.")
    print("Saved English captions and interpretation notes.")
    print(f"Output folder: {folder}")


if __name__ == "__main__":
    main()
