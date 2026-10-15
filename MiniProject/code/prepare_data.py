from pathlib import Path

import numpy as np
import pandas as pd

project_root = Path(__file__).resolve().parents[1]
data = pd.read_csv(project_root / "data" / "LogisticGrowthData.csv")
results_folder = project_root / "results"
results_folder.mkdir(parents=True, exist_ok=True)

group_columns = [
    "Citation", "Species", "Temp", "Medium",
    "Rep", "Time_units", "PopBio_units",
]

# Stop if the numeric fields contain invalid or missing values.
numeric_columns = ["Time", "PopBio", "Temp"]
for column in numeric_columns:
    data[column] = pd.to_numeric(data[column], errors="raise")
    if not np.isfinite(data[column]).all():
        raise ValueError(f"Non-finite values found in {column}.")

prepared_curves = []
summary_rows = []

# This tolerance only flags very small negative times near zero.
time_tolerance = 1e-8

for number, (key, group) in enumerate(
    data.groupby(group_columns, dropna=False, sort=True),
    start=1,
):
    curve = group.sort_values("Time", kind="stable").copy()
    curve_id = f"C{number:03d}"

    curve["curve_id"] = curve_id

    # Keep original times and add a separate time variable for fitting.
    curve["time_since_first"] = curve["Time"] - curve["Time"].min()

    curve["negative_time"] = curve["Time"] < 0
    curve["near_zero_negative_time"] = (
        (curve["Time"] < 0)
        & (curve["Time"] >= -time_tolerance)
    )
    curve["nonpositive_value"] = curve["PopBio"] <= 0
    curve["repeated_time"] = curve["Time"].duplicated(keep=False)

    summary = dict(zip(group_columns, key))
    summary.update({
        "curve_id": curve_id,
        "n_points": len(curve),
        "n_unique_times": curve["Time"].nunique(),
        "time_origin": curve["Time"].min(),
        "duration_hours": curve["time_since_first"].max(),
        "value_min": curve["PopBio"].min(),
        "value_max": curve["PopBio"].max(),
        "n_negative_time": int(curve["negative_time"].sum()),
        "n_near_zero_negative_time": int(
            curve["near_zero_negative_time"].sum()
        ),
        "n_nonpositive_value": int(curve["nonpositive_value"].sum()),
        "n_rows_at_repeated_times": int(curve["repeated_time"].sum()),
    })

    prepared_curves.append(curve)
    summary_rows.append(summary)

prepared = pd.concat(prepared_curves, ignore_index=True)
catalog = pd.DataFrame(summary_rows)

# Export derived files. Do not overwrite the original input data.
prepared.to_csv(results_folder / "prepared_growth_data.csv", index=False)
catalog.to_csv(results_folder / "curve_catalog.csv", index=False)

flagged = prepared.loc[
    prepared["negative_time"]
    | prepared["nonpositive_value"]
    | prepared["repeated_time"]
]
flagged.to_csv(results_folder / "flagged_observations.csv", index=False)

print("Input observations:", len(data))
print("Retained observations:", len(prepared))
print("Candidate curves:", len(catalog))
print("Flagged observations:", len(flagged))
print(
    "Near-zero negative times:",
    int(prepared["near_zero_negative_time"].sum()),
)
print(
    "Other negative times:",
    int((
        prepared["negative_time"]
        & ~prepared["near_zero_negative_time"]
    ).sum()),
)
print("Original input files were not changed.")

# Define a common screening rule before comparing models.
catalog["enough_time_points"] = catalog["n_unique_times"] >= 6
catalog["positive_duration"] = catalog["duration_hours"] > 0

catalog["eligible_for_comparison"] = (
    catalog["enough_time_points"]
    & catalog["positive_duration"]
)

catalog["screening_reason"] = "Eligible for fitting"

catalog.loc[
    ~catalog["enough_time_points"],
    "screening_reason",
] = "Fewer than six distinct time points"

catalog.loc[
    ~catalog["positive_duration"],
    "screening_reason",
] = "No positive time span"

catalog.to_csv(
    results_folder / "fit_screening.csv",
    index=False,
)

print("\nScreening results:")
print(
    catalog["screening_reason"]
    .value_counts()
    .to_string()
)
print("\nScreening does not remove any original observations.")
print("Eligibility does not guarantee a reliable model fit.")