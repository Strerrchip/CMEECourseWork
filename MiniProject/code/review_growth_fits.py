"""Combine fitting runs and identify curves that need further review."""

from pathlib import Path

import numpy as np
import pandas as pd


def as_boolean(series):
    """Read boolean values safely from CSV files."""
    return series.astype(str).str.lower().eq("true")


def main():
    root = Path(__file__).resolve().parents[1]
    results = root / "results"
    original_folder = results / "batch"
    retry_folder = results / "retry_failed_10000"
    output_folder = results / "review"
    output_folder.mkdir(parents=True, exist_ok=True)
    keys = ["curve_id", "model"]

    original = pd.read_csv(original_folder / "model_fits.csv")
    retry_path = retry_folder / "model_fits.csv"
    retry = pd.read_csv(retry_path) if retry_path.exists() else original.iloc[:0].copy()
    catalog = pd.read_csv(results / "curve_catalog.csv")

    for table in [original, retry]:
        if table.duplicated(keys).any():
            raise ValueError("Repeated curve-model pairs in a fitting table.")

    old_status = original.set_index(keys)["status"]
    for key in retry[keys].itertuples(index=False, name=None):
        if key not in old_status.index or old_status.loc[key] != "failed":
            raise ValueError("Retry results must replace previously failed pairs.")

    original["fit_run"] = "initial_2000"
    retry["fit_run"] = "retry_10000"
    merged = pd.concat([original, retry], ignore_index=True)
    merged = merged.drop_duplicates(keys, keep="last")
    merged["numerical_review"] = as_boolean(merged["numerical_review"])
    merged["Delta_AICc"] = np.nan

    review_rows = []
    for identifier, group in merged.groupby("curve_id", sort=True):
        converged = group["status"].eq("converged")
        complete = (
            set(group["model"]) == {"Exponential", "Logistic", "Gompertz"}
            and bool(converged.all())
            and bool(np.isfinite(group["AICc"]).all())
        )
        flagged_models = group.loc[group["numerical_review"], "model"].tolist()
        failed_models = group.loc[~converged, "model"].tolist()

        # Rank only when all three models have finite comparison metrics.
        if complete:
            merged.loc[group.index, "Delta_AICc"] = (
                group["AICc"] - group["AICc"].min()
            )

        if not complete:
            category = "Incomplete model comparison"
        elif flagged_models:
            category = "Complete comparison; numerical review needed"
        else:
            category = "Complete comparison; no numerical flags"

        review_rows.append({
            "curve_id": identifier,
            "n_converged_models": int(converged.sum()),
            "complete_comparison": complete,
            "failed_models": "; ".join(failed_models),
            "flagged_models": "; ".join(flagged_models),
            "review_category": category,
        })

    review = pd.DataFrame(review_rows).merge(
        catalog, on="curve_id", how="left", validate="one_to_one"
    )
    merged.to_csv(output_folder / "merged_model_fits.csv", index=False)
    review.to_csv(output_folder / "curve_fit_review.csv", index=False)

    # Keep predictions from the same fitting run as each merged result.
    prediction_tables = []
    for folder, run_name in [
        (original_folder, "initial_2000"),
        (retry_folder, "retry_10000"),
    ]:
        if folder == retry_folder and retry.empty:
            continue
        path = folder / "predictions.csv"
        if path.exists():
            table = pd.read_csv(path)
            table["fit_run"] = run_name
            prediction_tables.append(table)

    if prediction_tables:
        predictions = pd.concat(prediction_tables, ignore_index=True)
        selected = merged.loc[merged["status"].eq("converged"), keys + ["fit_run"]]
        predictions = predictions.merge(
            selected, on=keys + ["fit_run"], how="inner", validate="many_to_one"
        )
        predictions.to_csv(output_folder / "merged_predictions.csv", index=False)

    print("Review of all screened curves:")
    print(review["review_category"].value_counts().to_string())
    print("\nFailed models after retry:")
    print(merged.loc[merged["status"].ne("converged"), keys].to_string(index=False))
    print(f"\nSaved review files to: {output_folder}")
    print("No numerical flags does not guarantee a suitable biological model.")
    print("All screened curves remain in the review, including failed fits.")


if __name__ == "__main__":
    main()
