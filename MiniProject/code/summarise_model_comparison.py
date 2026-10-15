"""Compare three growth models within each curve using AICc and BIC."""

from pathlib import Path

import numpy as np
import pandas as pd


MODELS = {"Exponential", "Logistic", "Gompertz"}


def summarise(table, groups):
    """Count unique minima and models within two units of the minimum."""
    return table.groupby(groups, dropna=False).agg(
        n_curves=("curve_id", "nunique"),
        n_unique_best=("unique_best", "sum"),
        n_within_two=("within_two", "sum"),
        median_delta=("delta", "median"),
    ).reset_index()


def main():
    root = Path(__file__).resolve().parents[1]
    review_folder = root / "results" / "review"
    fits = pd.read_csv(review_folder / "merged_model_fits.csv")
    review = pd.read_csv(review_folder / "curve_fit_review.csv")
    if fits.duplicated(["curve_id", "model"]).any():
        raise ValueError("Repeated curve-model pairs in merged fits.")
    if review["curve_id"].duplicated().any():
        raise ValueError("Repeated curve identifiers in the review table.")

    eligible = []
    for identifier, group in fits.groupby("curve_id"):
        valid = (
            len(group) == 3 and set(group["model"]) == MODELS
            and group["status"].eq("converged").all()
            and np.isfinite(group[["AICc", "BIC"]].to_numpy()).all()
            and group["n"].nunique() == 1
        )
        if valid:
            eligible.append(identifier)

    metadata = ["curve_id", "Citation", "Species", "Temp", "Medium",
                "Rep", "PopBio_units", "review_category"]
    complete = fits.loc[fits["curve_id"].isin(eligible)].merge(
        review[metadata], on="curve_id", validate="many_to_one"
    )
    unflagged = complete.loc[complete["review_category"].eq(
        "Complete comparison; no numerical flags"
    )]

    tables = []
    for subset, table in [("All complete comparisons", complete),
                          ("Complete comparisons without numerical flags", unflagged)]:
        for criterion in ["AICc", "BIC"]:
            selected = table.copy()
            selected["subset"] = subset
            selected["criterion"] = criterion
            selected["score"] = selected[criterion]
            minima = selected.groupby("curve_id")["score"].transform("min")
            selected["delta"] = selected["score"] - minima
            at_minimum = np.isclose(selected["delta"], 0, rtol=0, atol=1e-8)
            selected["at_minimum"] = at_minimum
            n_minima = selected.groupby("curve_id")["at_minimum"].transform("sum")
            selected["unique_best"] = at_minimum & n_minima.eq(1)
            selected["tied_minimum"] = at_minimum & n_minima.gt(1)
            selected["within_two"] = selected["delta"].lt(2)
            tables.append(selected)

    if not tables or complete.empty:
        raise ValueError("No complete comparisons with finite AICc and BIC.")
    selection = pd.concat(tables, ignore_index=True)
    folder = root / "results" / "model_comparison"
    folder.mkdir(parents=True, exist_ok=True)
    columns = metadata + ["subset", "criterion", "model", "score", "delta",
                          "unique_best", "tied_minimum", "within_two",
                          "numerical_review", "RMSE", "fit_run"]
    selection[columns].to_csv(folder / "model_selection_by_curve.csv", index=False)
    overall = summarise(selection, ["subset", "criterion", "model"])
    overall.to_csv(folder / "model_comparison_overall.csv", index=False)
    summarise(selection, ["subset", "criterion", "Species", "model"]).to_csv(
        folder / "model_comparison_by_species.csv", index=False
    )
    summarise(selection, ["subset", "criterion", "Citation", "model"]).to_csv(
        folder / "model_comparison_by_study.csv", index=False
    )
    review.loc[~review["curve_id"].isin(eligible)].to_csv(
        folder / "excluded_comparisons.csv", index=False
    )

    notes = f"""Model comparison notes
======================
Screened curves: {len(review)}
Complete comparisons with finite AICc and BIC: {len(eligible)}
Complete comparisons without numerical flags: {unflagged['curve_id'].nunique()}
Excluded incomplete or non-finite comparisons: {len(review) - len(eligible)}

Models are compared only within the same curve and on the same observations.
AICc is the primary criterion; BIC provides a sensitivity comparison.
The full comparison retains numerical flags. A second summary removes any
curve with a flagged model, keeping the same three-model candidate set.
This numerical sensitivity subset is not a biological validation subset.
Unique minima use an absolute tolerance of 1e-8 for numerical ties.
Within-two counts include every model with delta < 2 and may sum to more
than the number of curves. They describe relative support, not certainty.
Species labels are retained as supplied and may include strain identifiers
or mixed communities. Study contributions are unequal. These counts are
descriptive; curves are not assumed to be independent species replicates.
Raw AICc, BIC, or RMSE values are not averaged across measurement units.
A preferred model can still have structured residuals or unsuitable
parameters. Temperature analysis requires a separate parameter review.
"""
    (folder / "comparison_notes.txt").write_text(notes, encoding="utf-8")
    print(notes.split("Models are compared")[0].strip())
    for subset, table in overall.loc[overall["criterion"].eq("AICc")].groupby("subset"):
        print(f"\nAICc unique minima: {subset}")
        for row in table.itertuples():
            print(f"  {row.model}: {row.n_unique_best} / {row.n_curves}")
    print(f"\nSaved comparison tables to: {folder}")


if __name__ == "__main__":
    main()
