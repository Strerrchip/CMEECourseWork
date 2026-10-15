"""Screen logistic parameters and describe temperature patterns within Bae series."""

from pathlib import Path
import textwrap

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.ticker import FixedLocator, FuncFormatter, MaxNLocator, NullLocator
import numpy as np
import pandas as pd


SERIES = ["Citation", "Species", "Medium", "Rep", "PopBio_units"]


def check_shape(time, observed, fitted, relaxed=False):
    """Apply transparent exploratory rules, not a formal identifiability test."""
    reasons = []
    initial, rate, capacity = fitted.initial_value, fitted.growth_rate, fitted.capacity
    if not np.isfinite([initial, rate, capacity]).all() or min(initial, rate, capacity) <= 0:
        return ["invalid_parameters"], np.nan, np.nan, 0
    if capacity <= initial:
        return ["non_increasing_logistic_fit"], np.nan, np.nan, 0
    prediction = capacity / (1 + (capacity / initial - 1) * np.exp(-rate * time))
    inflection = np.log(capacity / initial - 1) / rate
    transition_n = np.unique(time[(prediction >= .1 * capacity)
                                  & (prediction <= .9 * capacity)]).size
    # Average measurements at repeated times only for this shape diagnostic.
    # The original fits and observations remain unchanged.
    unique = pd.DataFrame({"time": time, "y": observed}).groupby("time")["y"].mean()
    values = unique.to_numpy()
    peak = float(np.median(np.sort(values)[-3:]))
    tail = float(np.median(values[-3:]))
    denominator = peak - values[0]
    decline = (peak - tail) / denominator if denominator > 0 else np.inf
    signal_limit = 3 if relaxed else 5
    plateau_limit = .8 if relaxed else .9
    transition_limit = 2 if relaxed else 3
    decline_limit = .3 if relaxed else .2
    if np.ptp(observed) <= signal_limit * fitted.RMSE:
        reasons.append("weak_signal_relative_to_residual_error")
    if prediction[-1] < plateau_limit * capacity:
        reasons.append("fitted_plateau_not_reached")
    if not 0 <= inflection <= time[-1]:
        reasons.append("inflection_outside_observed_period")
    if transition_n < transition_limit:
        reasons.append("sparse_growth_transition")
    if decline > decline_limit:
        reasons.append("late_decline")
    return reasons, inflection, decline, transition_n


def plot_series(table, parameter, ylabel, filename):
    groups = list(table.groupby("series_id", sort=True))
    if not groups:
        return
    ncols = 2
    nrows = (len(groups) + ncols - 1) // ncols
    fig, axes = plt.subplots(nrows, ncols, figsize=(10, 10), squeeze=False)
    display_names = {
        'Bacillus.pumilus..RDA.R.': 'B. pumilus (RDA-R)',
        'Chryseobacterium.balustinum': 'C. balustinum',
        'Enterobacter.sp.': 'Enterobacter sp.',
        'Klebsiella.pneumonia': 'K. pneumonia',
        'Klebsiella.pneumonia..RDA.R.': 'K. pneumonia (RDA-R)',
        'Pseudomonas.fluorescens.2': 'P. fluorescens (2)',
        'Stenotrophomonas.maltophilia..RDA.R.': 'S. maltophilia (RDA-R)',
        'Stenotrophomonas.maltophilia.2': 'S. maltophilia (2)',
    }
    for ax, (identifier, group) in zip(axes.flat, groups):
        group = group.sort_values("Temp")
        ax.plot(group["Temp"], group[parameter], color="steelblue", marker="o", ms=5)
        supported = group.loc[group["logistic_delta_aicc"].lt(2)]
        ax.scatter(supported["Temp"], supported[parameter], color="darkorange", zorder=3)
        name = str(group.iloc[0]["Species"])
        ax.set_title(display_names.get(name, textwrap.fill(name, 34)), fontsize=11)
        ax.set_xlabel("Temperature (°C)", fontsize=10)
        ax.set_xlim(2, 38)
        ax.set_xticks([5, 15, 25, 35])
        ax.tick_params(labelsize=10)
        ax.set_ylabel(ylabel)
        if parameter == "growth_rate":
            ax.set_yscale("log")
            ticks = np.geomspace(group[parameter].min(), group[parameter].max(), 4)
            ax.yaxis.set_major_locator(FixedLocator(ticks))
            ax.yaxis.set_major_formatter(FuncFormatter(lambda value, _: f"{value:.2g}"))
            ax.yaxis.set_minor_locator(NullLocator())
        else:
            ax.yaxis.set_major_locator(MaxNLocator(nbins=4))
        ax.grid(alpha=.2)
    for ax in list(axes.flat)[len(groups):]:
        ax.set_visible(False)
    title = "Logistic growth rate" if parameter == "growth_rate" else "Logistic plateau height"
    fig.suptitle(f"{title} across temperature", fontsize=14)
    fig.tight_layout(rect=(0, 0, 1, .97), h_pad=1.8, w_pad=2)
    fig.savefig(filename, dpi=200)
    fig.savefig(filename.with_suffix(".pdf"))
    plt.close(fig)


def main():
    root = Path(__file__).resolve().parents[1]
    results = root / "results"
    fits = pd.read_csv(results / "review" / "merged_model_fits.csv")
    review = pd.read_csv(results / "review" / "curve_fit_review.csv")
    data = pd.read_csv(results / "prepared_growth_data.csv")
    if fits.duplicated(["curve_id", "model"]).any() or review.curve_id.duplicated().any():
        raise ValueError("Input identifiers must be unique.")
    metadata = review.set_index("curve_id")
    rows = []
    for fitted in fits.loc[fits.model.eq("Logistic")].itertuples():
        curve = data.loc[data.curve_id.eq(fitted.curve_id)].sort_values("time_since_first")
        time = curve.time_since_first.to_numpy(dtype=float)
        observed = curve.PopBio.to_numpy(dtype=float)
        meta = metadata.loc[fitted.curve_id]
        strict, inflection, decline, transition = check_shape(time, observed, fitted)
        relaxed, _, _, _ = check_shape(time, observed, fitted, relaxed=True)
        common = []
        if fitted.status != "converged":
            common.append("fitting_failed")
        if str(fitted.numerical_review).lower() == "true":
            common.append("numerical_flag")
        # Restrict interpretation to one study and a consistent measurement scale.
        in_scope = (str(meta.Citation).startswith("Bae,")
                    and meta.Medium == "TSB" and meta.PopBio_units == "OD_595")
        if not in_scope:
            common.append("outside_primary_study_scope")
        rows.append({
            "curve_id": fitted.curve_id,
            **{key: meta[key] for key in SERIES + ["Temp"]},
            "initial_value": fitted.initial_value,
            "growth_rate": fitted.growth_rate,
            "capacity": fitted.capacity,
            "RMSE": fitted.RMSE,
            "logistic_delta_aicc": fitted.Delta_AICc,
            "inflection_hours": inflection,
            "late_decline_fraction": decline,
            "n_distinct_transition_times": transition,
            "in_primary_study": in_scope,
            "strict_eligible": not (common + strict),
            "relaxed_eligible": not (common + relaxed),
            "strict_exclusion_reasons": "; ".join(common + strict),
            "relaxed_exclusion_reasons": "; ".join(common + relaxed),
        })
    table = pd.DataFrame(rows)
    if len(table) != len(review):
        raise ValueError("Expected one logistic parameter record per screened curve.")
    keys = table[SERIES].drop_duplicates().sort_values(SERIES).reset_index(drop=True)
    keys["series_id"] = [f"S{i:03d}" for i in range(1, len(keys) + 1)]
    table = table.merge(keys, on=SERIES, validate="many_to_one")
    folder = results / "temperature_analysis"
    folder.mkdir(parents=True, exist_ok=True)
    table.to_csv(folder / "parameter_screening.csv", index=False)

    summaries = []
    for label, column in [("Strict", "strict_eligible"), ("Relaxed", "relaxed_eligible")]:
        selected = table.loc[table[column]].copy()
        selected.to_csv(folder / f"temperature_parameters_{label.lower()}.csv", index=False)
        for identifier, group in selected.groupby("series_id"):
            # No pooling across studies, species labels, media, replicate labels or units.
            group = group.sort_values("Temp")
            n_temperatures = group.Temp.nunique()
            if n_temperatures < 3:
                continue
            slope = np.polyfit(group.Temp, np.log(group.growth_rate), 1)[0]
            first, last = group.iloc[0], group.iloc[-1]
            summaries.append({
                "screening": label, "series_id": identifier,
                **{key: first[key] for key in SERIES},
                "n_temperatures": n_temperatures,
                "minimum_temperature": first.Temp,
                "maximum_temperature": last.Temp,
                "log_rate_slope_per_C": slope,
                "rate_ratio_high_to_low_temperature": last.growth_rate / first.growth_rate,
                "capacity_ratio_high_to_low_temperature": last.capacity / first.capacity,
            })
    summary = pd.DataFrame(summaries)
    summary.to_csv(folder / "temperature_series_summary.csv", index=False)
    if (table.strict_eligible & ~table.relaxed_eligible).any():
        raise ValueError("Relaxed screening must retain every strict-screening curve.")
    table.loc[table.in_primary_study].groupby("Temp").agg(
        n_original_curves=("curve_id", "size"),
        n_strict=("strict_eligible", "sum"),
        n_relaxed=("relaxed_eligible", "sum"),
    ).reset_index().to_csv(folder / "retention_by_temperature.csv", index=False)
    if not summary.empty:
        strict_slopes = summary.loc[summary.screening.eq("Strict"),
                                   ["series_id", "log_rate_slope_per_C"]]
        relaxed_slopes = summary.loc[summary.screening.eq("Relaxed"),
                                    ["series_id", "log_rate_slope_per_C"]]
        strict_slopes.merge(relaxed_slopes, on="series_id", how="outer",
                            suffixes=("_strict", "_relaxed")).to_csv(
            folder / "slope_screening_sensitivity.csv", index=False
        )
    strict_summary = summary.loc[summary.screening.eq("Strict")] if not summary.empty else summary
    ids = strict_summary.series_id if not strict_summary.empty else []
    plotting = table.loc[table.strict_eligible & table.series_id.isin(ids)]
    plot_series(plotting, "growth_rate", "Logistic rate (hours⁻¹)", folder / "temperature_growth_rate.png")
    plot_series(plotting, "capacity", "Logistic plateau (OD595)", folder / "temperature_plateau.png")

    counts = table.loc[table.in_primary_study, "strict_exclusion_reasons"].str.split("; ").explode()
    counts = counts.loc[counts.ne("")].value_counts().rename_axis("reason").reset_index(name="n_curves")
    counts.to_csv(folder / "primary_study_exclusion_counts.csv", index=False)
    notes = f"""Exploratory temperature analysis
===============================
Primary scope: Bae study, TSB medium, OD_595 measurement.
Primary-study curves: {int(table.in_primary_study.sum())}
Strict-screening curves: {int(table.strict_eligible.sum())}
Relaxed-screening curves: {int(table.relaxed_eligible.sum())}
Strict series with at least three temperatures: {len(strict_summary)}

Use one model form (logistic) at every temperature. Its r is a fitted
logistic rate constant and K is the fitted OD plateau. Neither should be
interpreted as a directly measured cell count or physiological rate.
Gompertz rate parameters are not mixed with logistic r.

All selected fits must converge, have no logistic numerical flag, and
increase with an inflection inside the observed period. Strict rules:
observed range > 5 RMSE; final prediction >= 90% of K; at least three
distinct times with fitted values between 10% and 90% of K; late decline
fraction <= 20%. The decline fraction uses the median of the three largest
time-averaged measurements, the median of the last three time-averaged
measurements, and the initial measurement. Repeated times are averaged
only for this diagnostic, not for fitting. Relaxed rules change these
thresholds to 3 RMSE, 80% of K, two transition times, and 30% decline.
These are exploratory analysis choices, not assessment requirements or
formal proofs of parameter identifiability. Report selection attrition.
Exclusion counts overlap: a curve can fail more than one rule. Retention
by temperature is exported to show that screening may change temperature
coverage and introduce selection bias.
The relaxed subset is a sensitivity analysis, not extra independent data.

Series retain exact study, species/strain label, medium, replicate label,
and measurement unit. Replicate labels across temperatures do not prove
that observations are paired. Only series with at least three retained
temperatures are plotted and given descriptive slopes. Other retained
curves stay in the parameter tables. Slopes fit log(r) against temperature
and do not imply monotonicity or establish an optimum temperature.
No inferential p-values or confidence intervals are calculated. This
analysis treats fitted point estimates as uncertain descriptive values.
Logistic delta AICc is recorded and highlighted but is not a screening rule;
model preference and parameter trends are separate questions.
Other studies remain in the full model comparison. Their measurement
scales and experimental conditions need separate source checks before
physiological interpretation. Results here are limited to the primary
study and retained series, not all organisms in the combined dataset.
"""
    (folder / "temperature_analysis_notes.txt").write_text(notes, encoding="utf-8")
    print(notes.split("Use one model")[0].strip())
    if not strict_summary.empty:
        positive = int(strict_summary.log_rate_slope_per_C.gt(0).sum())
        print(f"Positive descriptive log-rate slopes: {positive}/{len(strict_summary)} strict series")
    print(f"\nSaved parameter tables and figures to: {folder}")
    print("Review the screening rules and figures before writing biological conclusions.")


if __name__ == "__main__":
    main()
